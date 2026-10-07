output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "ecr_repository_urls" {
  description = "The URLs of the ECR repositories for pushing Docker images"
  value       = { for k, v in aws_ecr_repository.services : k => v.repository_url }
}

output "ec2_instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "ec2_public_ip" {
  description = "The Public IP of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "monitoring_public_ip" {
  description = "The Public IP of the Monitoring Server (Grafana)"
  value       = aws_instance.monitoring_server.public_ip
}

output "monitoring_private_ip" {
  description = "The Private IP of the Monitoring Server (Loki)"
  value       = aws_instance.monitoring_server.private_ip
}

resource "null_resource" "print_urls" {
  # Trigger it to run every time we run apply
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "bash print_urls.sh"
    environment = {
      ALB_URL       = aws_lb.main.dns_name
      EC2_IP        = aws_instance.app_server.public_ip
      MONITORING_IP = aws_instance.monitoring_server.public_ip
    }
  }
}
