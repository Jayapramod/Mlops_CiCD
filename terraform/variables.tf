variable "aws_region" {
  description = "AWS region to deploy all resources into."
  type        = string
  default     = "ap-south-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = "agrox-cluster"
}

variable "ecr_repo_name" {
  description = "Name of the ECR repository."
  type        = string
  default     = "agrox"
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS managed node group."
  type        = string
  default     = "t3.medium"
}

variable "node_desired" {
  description = "Desired number of worker nodes."
  type        = number
  default     = 2
}

variable "node_min" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 1
}

variable "node_max" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 3
}
