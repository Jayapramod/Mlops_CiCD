variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
}

variable "keyvault_sku" {
  description = "Key Vault SKU"
  type        = string
  default     = "standard"
}

variable "acr_admin_username" {
  description = "ACR Admin Username"
  type        = string
  sensitive   = true
}

variable "acr_admin_password" {
  description = "ACR Admin Password"
  type        = string
  sensitive   = true
}
