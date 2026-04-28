variable "aws_region" {
  description = "AWS region to deploy all resources into."
  type        = string
  default     = "ap-south-1"
}

variable "cluster_name" {
  description = "Name of the ECS cluster."
  type        = string
  default     = "agrox-cluster"
}

variable "container_name" {
  description = "Name of the container in ECS task definition"
  type        = string
  default     = "agrox-app"
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 8000
}

variable "ecr_repository_uri" {
  description = "ECR repository URI for the Docker image"
  type        = string
  default     = "687222805896.dkr.ecr.ap-south-1.amazonaws.com/agrox"
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}

variable "task_cpu" {
  description = "CPU units for ECS task (256, 512, 1024, 2048, 4096)"
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "Memory in MB for ECS task (512, 1024, 2048, 3072, 4096, etc.)"
  type        = string
  default     = "512"
}

variable "desired_task_count" {
  description = "Desired number of ECS tasks running"
  type        = number
  default     = 1
}

variable "max_tasks" {
  description = "Maximum number of tasks for autoscaling"
  type        = number
  default     = 2
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}
