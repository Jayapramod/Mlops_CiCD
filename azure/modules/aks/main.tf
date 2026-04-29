resource "azurerm_kubernetes_cluster" "main" {
  name                = "${var.environment}-${var.project_name}-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.environment}-${var.project_name}"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name            = "nodepool1"
    node_count      = var.node_count
    vm_size         = var.vm_size
    os_disk_size_gb = var.os_disk_size_gb

    vnet_subnet_id = var.aks_subnet_id

    max_pods = 110

    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = var.service_cidr
    dns_service_ip    = var.dns_service_ip
  }

  addon_profile {
    http_application_routing {
      enabled = false
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope              = var.acr_id
  role_definition_name = "AcrPull"
  principal_id       = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}

resource "azurerm_role_assignment" "aks_acr_push" {
  scope              = var.acr_id
  role_definition_name = "AcrPush"
  principal_id       = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}
