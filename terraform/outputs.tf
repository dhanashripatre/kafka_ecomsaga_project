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
