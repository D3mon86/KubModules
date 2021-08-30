terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.4.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.42"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.1.0"
    }
  }
}

data "azurerm_kubernetes_cluster" "aks_rg" {
  depends_on          = [module.aks-cluster] # refresh cluster state before reading
  name                = var.cluster_name
  resource_group_name = var.resource_group_name
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.aks_rg.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks_rg.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.aks_rg.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks_rg.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.aks_rg.kube_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks_rg.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.aks_rg.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks_rg.kube_config.0.cluster_ca_certificate)
  }
}

provider "azurerm" {
  features {}
}

module "aks-cluster" {
  source       = "./AKS"
  cluster_name = var.cluster_name
  location     = var.location
  appId=var.appId
  password=var.password
  dns_prefix=var.dns_prefix
  address_space=var.address_space
  network_name=var.network_name
  vm_size=var.vm_size
  os_disk_size_gb=var.os_disk_size_gb
  enable_role_based_access=var.enable_role_based_access
  subnet_adress_prefixes=var.subnet_adress_prefixes
  subnet_name=var.subnet_name
  resource_group_name=var.resource_group_name
  ingress_class=var.ingress_class
}

module "kubernetes-config" {
  depends_on   = [module.aks-cluster]
  source       = "./Kubernetes"
  cluster_name = var.cluster_name
  ingress_class = var.ingress_class
  kubeconfig   = data.azurerm_kubernetes_cluster.aks_rg.kube_config_raw
}