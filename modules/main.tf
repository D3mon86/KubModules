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
}

module "kubernetes-config" {
  depends_on   = [module.aks-cluster]
  source       = "./Kubernetes"
  cluster_name = var.cluster_name
  kubeconfig   = data.azurerm_kubernetes_cluster.aks_rg.kube_config_raw
}