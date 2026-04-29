variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "ecr_repository_uri" {
  description = "ECR repository URI (managed by Jenkins)"
  type        = string
}

