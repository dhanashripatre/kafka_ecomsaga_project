# Security Group for the Monitoring Server
resource "aws_security_group" "monitoring_sg" {
  name        = "${var.project_name}-monitoring-sg"
  description = "Security Group for Prometheus, Grafana, and Loki"
  vpc_id      = data.aws_vpc.default.id

  # Grafana UI accessible from anywhere
  ingress {
    description = "Grafana UI"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Prometheus UI accessible from anywhere (Optional but useful for debugging)
  ingress {
    description = "Prometheus UI"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow internal VPC traffic for Loki log ingestion (Port 3100)
  ingress {
    description = "Internal traffic for Loki"
    from_port   = 3100
    to_port     = 3100
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-monitoring-sg"
  }
}

# Monitoring EC2 Instance
resource "aws_instance" "monitoring_server" {
  ami                  = data.aws_ami.amazon_linux.id
  instance_type        = var.monitoring_instance_type
  subnet_id            = element(data.aws_subnets.default.ids, 0)
  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y docker
              systemctl enable docker
              systemctl start docker
              usermod -aG docker ssm-user
              usermod -aG docker ec2-user
              
              mkdir -p /opt/monitoring
              cd /opt/monitoring

              # Create Prometheus config
              cat << 'PROMETHEUS' > prometheus.yml
              global:
                scrape_interval: 15s
              scrape_configs:
                - job_name: 'order-service'
                  metrics_path: '/api/order/actuator/prometheus'
                  static_configs:
                    - targets: ['${aws_instance.app_server.private_ip}:8080']
                - job_name: 'inventory-service'
                  metrics_path: '/api/inventory/actuator/prometheus'
                  static_configs:
                    - targets: ['${aws_instance.app_server.private_ip}:8081']
                - job_name: 'payment-service'
                  metrics_path: '/api/payment/actuator/prometheus'
                  static_configs:
                    - targets: ['${aws_instance.app_server.private_ip}:8082']
                - job_name: 'notification-service'
                  metrics_path: '/api/notification/actuator/prometheus'
                  static_configs:
                    - targets: ['${aws_instance.app_server.private_ip}:8083']
              PROMETHEUS

              # Create Loki config
              cat << 'LOKI' > loki-config.yaml
              auth_enabled: false
              server:
                http_listen_port: 3100
              ingester:
                lifecycler:
                  address: 127.0.0.1
                  ring:
                    kvstore:
                      store: inmemory
                    replication_factor: 1
                chunk_idle_period: 5m
                chunk_retain_period: 30s
                wal:
                  dir: /tmp/loki/wal
              schema_config:
                configs:
                  - from: 2020-10-24
                    store: boltdb
                    object_store: filesystem
                    schema: v11
                    index:
                      prefix: index_
                      period: 24h
              storage_config:
                boltdb:
                  directory: /tmp/loki/index
                filesystem:
                  directory: /tmp/loki/chunks
              limits_config:
                enforce_metric_name: false
                reject_old_samples: true
                reject_old_samples_max_age: 168h
              LOKI

              # Start monitoring stack (using standard docker run commands)
              docker network create monitoring-network
              
              docker run -d --name prometheus --network monitoring-network -p 9090:9090 \
                -v /opt/monitoring/prometheus.yml:/etc/prometheus/prometheus.yml \
                prom/prometheus:latest
              
              docker run -d --name loki --network monitoring-network -p 3100:3100 \
                -v /opt/monitoring/loki-config.yaml:/etc/loki/local-config.yaml \
                grafana/loki:2.9.2 -config.file=/etc/loki/local-config.yaml
              
              docker run -d --name grafana --network monitoring-network -p 3000:3000 \
                -e GF_SECURITY_ADMIN_PASSWORD=admin \
                grafana/grafana:latest
              EOF

  tags = {
    Name = "${var.project_name}-monitoring-server"
  }
}
