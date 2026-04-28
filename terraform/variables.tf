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
  description = "EC2 instance type for EKS managed node group. AWS Free Tier: t3.micro"
  type        = string
  default     = "t3.micro"
}

variable "ecr_repo_url" {
  description = "ECR repository URL. Managed by Jenkins, not Terraform. Format: <ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/<REPO_NAME>"
  type        = string
  default     = "687222805896.dkr.ecr.ap-south-1.amazonaws.com/agrox"
}

variable "node_desired" {
  description = "Desired number of worker nodes. Free tier: 1 node"
  type        = number
  default     = 1
}

variable "node_min" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 1
}

variable "node_max" {
  description = "Maximum number of worker nodes. Free tier: max 2"
  type        = number
  default     = 2
}
