output "resource_group_id" {
  description = "Resource Group ID"
  value       = azurerm_resource_group.main.id
}

output "resource_group_name" {
  description = "Resource Group Name"
  value       = azurerm_resource_group.main.name
}

output "vnet_id" {
  description = "Virtual Network ID"
  value       = azurerm_virtual_network.main.id
}

output "aks_subnet_id" {
  description = "AKS Subnet ID"
  value       = azurerm_subnet.aks.id
}

output "acr_subnet_id" {
  description = "ACR Subnet ID"
  value       = azurerm_subnet.acr.id
}

output "aks_nsg_id" {
  description = "AKS Network Security Group ID"
  value       = azurerm_network_security_group.aks.id
}
