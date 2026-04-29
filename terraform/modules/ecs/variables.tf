variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "container_name" {
  description = "Name of the container"
  type        = string
  default     = "agrox-app"
}

variable "container_port" {
  description = "Port exposed by container"
  type        = number
  default     = 8000
}

variable "ecr_repository_uri" {
  description = "ECR repository URI"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "task_cpu" {
  description = "CPU units for task (256, 512, 1024, 2048, 4096)"
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "Memory MB for task (512, 1024, 2048, 3072, 4096, etc.)"
  type        = string
  default     = "512"
}

variable "desired_task_count" {
  description = "Desired number of running tasks"
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

variable "private_subnet_id" {
  description = "Private subnet ID for ECS tasks"
  type        = string
}

variable "ecs_tasks_security_group_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

variable "target_group_arn" {
  description = "Target group ARN from ALB"
  type        = string
}

variable "alb_listener_arn" {
  description = "ALB listener ARN"
  type        = string
}
