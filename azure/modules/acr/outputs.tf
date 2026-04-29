output "acr_login_server" {
  description = "ACR Login Server"
  value       = azurerm_container_registry.main.login_server
}

output "acr_id" {
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

output "acr_fqdn" {
  description = "ACR FQDN"
  value       = azurerm_container_registry.main.login_server
}
