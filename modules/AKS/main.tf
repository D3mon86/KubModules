terraform {
  
  required_version = ">= 0.12.26"
}

#Ideally from terraform recomendations this should be moved to main.
provider "azurerm" {
  version = "=2.13.0"

  features {
  }
}

provider "helm" {
  version = "1.2.2"
  kubernetes {
    host = azurerm_kubernetes_cluster.cluster.kube_config[0].host

    client_key             = base64decode(azurerm_kubernetes_cluster.aks_rg.kube_config[0].client_key)
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks_rg.kube_config[0].client_certificate)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks_rg.kube_config[0].cluster_ca_certificate)
    load_config_file       = false
  }
}
#Main Resource Group 
resource "azurerm_resource_group" "aks_rg" {
  name     = "rg-${var.resource_group_name}"
  location = "West Europe"

  tags = {
    environment = "Demo"
  }
}
# Create Virtual Network
resource "azurerm_virtual_network" "aksvnet" {
  name                = "aks-${var.network_name}"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  address_space       = var.address_space                                        #["10.0.0.0/8"]
}

# Create a Subnet for AKS
resource "azurerm_subnet" "aks-default" {
  name                 = "aks-${var.subnet_name}"
  virtual_network_name = azurerm_virtual_network.aksvnet.name
  resource_group_name  = azurerm_resource_group.aks_rg.name
  address_prefixes     = var.subnet_adress_prefixes                    # ["10.240.0.0/16"]
}


# Creates the Kubernetes cluster.                      
resource "azurerm_kubernetes_cluster" "akscluster" {
  name                = "aks-${var.cluster_name}"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "${var.dns_prefix}-k8s"

  default_node_pool {
    name            = var.default_node_pool_name   //default
    node_count      = var.node_count                  //2
    vm_size         = var.vm_size      //"Standard_D2_v2"
    os_disk_size_gb = var.os_disk_size_gb //30
  }

  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  role_based_access_control {
    enabled = var.enable_role_based_access           //true
  }

  tags = {
    environment = "Demo"
  }
}
#Create Nginx Ingress Controler 
resource "helm_release" "ingress" {
  name  = "ingress"
  chart = "stable/nginx-ingress"

  set {
    name  = "rbac.create"
    value = "true"
  }
}