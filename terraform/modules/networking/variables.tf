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

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_az1_cidr" {
  description = "Public subnet AZ1 CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_az2_cidr" {
  description = "Public subnet AZ2 CIDR"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_cidr" {
  description = "Private subnet CIDR"
  type        = string
  default     = "10.0.10.0/24"
}

variable "az1" {
  description = "Availability Zone 1"
  type        = string
}

variable "az2" {
  description = "Availability Zone 2"
  type        = string
}

variable "container_port" {
  description = "Container port for ECS tasks"
  type        = number
  default     = 8000
}
