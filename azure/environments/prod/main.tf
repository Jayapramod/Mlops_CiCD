module "networking" {
  source = "../../modules/networking"

  environment      = var.environment
  project_name     = var.project_name
  location         = var.location
  vnet_cidr        = var.vnet_cidr
  aks_subnet_cidr  = var.aks_subnet_cidr
  acr_subnet_cidr  = var.acr_subnet_cidr
}

module "acr" {
  source = "../../modules/acr"

  environment         = var.environment
  project_name        = var.project_name
  location            = var.location
  resource_group_name = module.networking.resource_group_name
  acr_sku             = var.acr_sku
}

module "keyvault" {
  source = "../../modules/keyvault"

  environment         = var.environment
  project_name        = var.project_name
  location            = var.location
  resource_group_name = module.networking.resource_group_name
  acr_admin_username  = module.acr.acr_admin_username
  acr_admin_password  = module.acr.acr_admin_password
}

module "aks" {
  source = "../../modules/aks"

  environment         = var.environment
  project_name        = var.project_name
  location            = var.location
  resource_group_name = module.networking.resource_group_name
  aks_subnet_id       = module.networking.aks_subnet_id
  acr_id              = module.acr.acr_id
  kubernetes_version  = var.kubernetes_version
  node_count          = var.node_count
  vm_size             = var.vm_size
  os_disk_size_gb     = var.os_disk_size_gb
  service_cidr        = var.service_cidr
  dns_service_ip      = var.dns_service_ip
  client_id           = var.client_id
  client_secret       = var.client_secret
}
