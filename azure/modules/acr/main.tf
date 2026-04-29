resource "azurerm_container_registry" "main" {
  name                = "${replace(var.project_name, "-", "")}${replace(var.environment, "-", "")}acr"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.acr_sku
  admin_enabled       = true

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

output "acr_login_server" {
  description = "ACR Login Server"
  value       = azurerm_container_registry.main.login_server
}

output "acr_registry_id" {
  description = "ACR Registry ID"
  value       = azurerm_container_registry.main.registry_id
}

output "acr_admin_username" {
  description = "ACR Admin Username"
  value       = azurerm_container_registry.main.admin_username
  sensitive   = true
}

output "acr_admin_password" {
  description = "ACR Admin Password"
  value       = azurerm_container_registry.main.admin_password
  sensitive   = true
}
