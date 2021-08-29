terraform {
  
  required_version = ">= 0.12.26"
}


#Main Resource Group 
resource "azurerm_resource_group" "aks_rg" {
  name     = "${var.resource_group_name}-rg"
  location = "West Europe"

  tags = {
    environment = "Demo"
  }
}
# Create Virtual Network
resource "azurerm_virtual_network" "aksvnet" {
  name                = "aks-network"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  address_space       = var.address_space                                        ["10.0.0.0/8"]
}

# Create a Subnet for AKS
resource "azurerm_subnet" "aks-default" {
  name                 = "aks-default-subnet"
  virtual_network_name = azurerm_virtual_network.aksvnet.name
  resource_group_name  = azurerm_resource_group.aks_rg.name
  address_prefixes     = var.subnet_adress_prefixes                    # ["10.240.0.0/16"]
}


# Creates the Kubernetes cluster.                      
resource "azurerm_kubernetes_cluster" "akscluster" {
  name                = "${var.cluster_name}-aks"
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