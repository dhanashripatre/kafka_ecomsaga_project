variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type (using c7i-flex.large as baseline for 4 Java apps)"
  type        = string
  default     = "c7i-flex.large"
}

variable "monitoring_instance_type" {
  description = "EC2 instance type for the monitoring server"
  type        = string
  default     = "t3.micro"
}

variable "project_name" {
  description = "Name of the project for tagging and resource naming"
  type        = string
  default     = "kafka-ecomsaga"
}
