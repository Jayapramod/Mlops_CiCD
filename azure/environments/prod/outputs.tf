output "resource_group_name" {
  description = "Resource Group Name"
  value       = module.networking.resource_group_name
}

output "aks_cluster_name" {
  description = "AKS Cluster Name"
  value       = module.aks.aks_name
}

output "aks_fqdn" {
  description = "AKS FQDN"
  value       = module.aks.fqdn
}

output "acr_login_server" {
  description = "ACR Login Server"
  value       = module.acr.acr_login_server
}

output "key_vault_name" {
  description = "Key Vault Name"
  value       = module.keyvault.key_vault_name
}

output "kube_config" {
  description = "Kubernetes Config (for kubeconfig)"
  value       = module.aks.kube_config
  sensitive   = true
}
