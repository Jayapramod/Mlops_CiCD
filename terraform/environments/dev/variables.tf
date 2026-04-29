variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "agrox"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_az1_cidr" {
  description = "CIDR block for public subnet in AZ1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_az2_cidr" {
  description = "CIDR block for public subnet in AZ2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.10.0/24"
}

variable "container_name" {
  description = "Container name in ECS task definition"
  type        = string
  default     = "agrox-app"
}

variable "container_port" {
  description = "Port exposed by container"
  type        = number
  default     = 8000
}

variable "ecr_repository_uri" {
  description = "ECR repository URI (without tag)"
  type        = string
  default     = "687222805896.dkr.ecr.ap-south-1.amazonaws.com/agrox"
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}

variable "task_cpu" {
  description = "Fargate CPU units (256, 512, 1024, 2048, 4096)"
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "Fargate memory in MB (512, 1024, 2048, 3072, 4096, etc.)"
  type        = string
  default     = "512"
}

variable "desired_task_count" {
  description = "Desired number of running ECS tasks"
  type        = number
  default     = 1
}

variable "max_tasks" {
  description = "Maximum number of tasks for auto-scaling"
  type        = number
  default     = 2
}

variable "log_retention_days" {
  description = "CloudWatch logs retention in days"
  type        = number
  default     = 7
}
