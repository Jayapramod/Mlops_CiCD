output "aks_id" {
  description = "AKS Cluster ID"
  value       = azurerm_kubernetes_cluster.main.id
}

output "aks_name" {
  description = "AKS Cluster Name"
  value       = azurerm_kubernetes_cluster.main.name
}

output "kube_config" {
  description = "Kubernetes config"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "kube_config_file" {
  description = "Kubernetes config file"
  value       = "${path.module}/kubeconfig"
  sensitive   = true
}

output "fqdn" {
  description = "AKS FQDN"
  value       = azurerm_kubernetes_cluster.main.fqdn
}

output "client_certificate" {
  description = "Client certificate"
  value       = azurerm_kubernetes_cluster.main.kube_config[0].client_certificate
  sensitive   = true
}
