resource "aws_instance" "app_server" {
  ami                  = data.aws_ami.amazon_linux.id
  instance_type        = var.instance_type
  subnet_id            = element(data.aws_subnets.default.ids, 0) # Place in the first default subnet
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # Root volume for OS and Docker runtime
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Update OS
              dnf update -y
              
              # Install Docker
              dnf install -y docker
              systemctl enable docker
              systemctl start docker
              
              # Add ssm-user to docker group for Session Manager access
              usermod -aG docker ssm-user
              usermod -aG docker ec2-user
              
              # Prepare persistent directory for H2
              mkdir -p /mnt/h2-data
              
              # Wait for the attached EBS volume to become available
              # In Amazon Linux 2023, /dev/sdf often maps to /dev/nvme1n1
              while [ ! -b /dev/nvme1n1 ]; do sleep 5; done
              
              # Format the drive if it doesn't already have a filesystem
              file -s /dev/nvme1n1 | grep ext4 || mkfs -t ext4 /dev/nvme1n1
              
              # Mount it
              mount /dev/nvme1n1 /mnt/h2-data
              
              # Ensure it mounts on reboot
              echo '/dev/nvme1n1 /mnt/h2-data ext4 defaults,nofail 0 2' >> /etc/fstab
              
              # Set permissions so docker containers can read/write to it
              chmod -R 777 /mnt/h2-data
              EOF

  tags = {
    Name = "${var.project_name}-server"
  }
}

# Separate Persistent EBS Volume for H2 Database Data
resource "aws_ebs_volume" "db_data" {
  availability_zone = aws_instance.app_server.availability_zone
  size              = 10
  type              = "gp3"

  tags = {
    Name = "${var.project_name}-db-volume"
  }
}

# Attach EBS Volume to the EC2 instance
resource "aws_volume_attachment" "db_data_att" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.db_data.id
  instance_id = aws_instance.app_server.id
}
