variable "appId" {
  description = "Azure Kubernetes Service Cluster service principal"
}

variable "password" {
  description = "Azure Kubernetes Service Cluster password"
}
variable "cluster_name" {
  description = "Azure Kubernetes Service Cluster Name"
}

variable "dns_prefix" {
  description = "Azure Kubernetes Service Cluster Dns Prefix"
}
variable "address_space" {
  description = "Azure Kubernetes Service Cluster Adress Space"
}

variable "network_name" {
  description = "Azure Kubernetes Service Cluster Network Name"
}
variable "vm_size" {
  description = "Azure Kubernetes Service Cluster VM Size"
}

variable "os_disk_size_gb" {
  description = "Azure Kubernetes Service Cluster Disk Size"
}
variable "enable_role_based_access" {
  description = "Azure Kubernetes Service Cluster Enable Role based access"
}
variable "subnet_adress_prefixes" {
  description = "Azure Kubernetes Service Cluster subnet address prefixes"
}
variable "subnet_name" {
  description = "Azure Kubernetes Service Cluster subnet name"
}
variable "resource_group_name" {
  description = "Azure Kubernetes Service Cluster resource group name"
}
variable "ingress_class" {
  description = "kubernetes.io/ingress.class"
}