terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.3"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.53.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.1.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.40.0"
    }
  }
}

data "azurerm_kubernetes_cluster" "default" {
  depends_on          = [module.aks-cluster] # refresh cluster state before reading
  name                = local.cluster_name
  resource_group_name = local.cluster_name
}

provider "kubernetes" {
  host = data.azurerm_kubernetes_cluster.default.kube_config.0.host
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "/home/freshchris/.asdf/shims/kubelogin"
    args = [
      "get-token",
      "--login",
      "spn",
      "--environment",
      "AzurePublicCloud",
      "--tenant-id",
      var.tenant_id,
      "--server-id",
      var.aad_server_id,
      "--client-id",
      var.client_id,
      "--client-secret",
      var.client_secret
    ]
  }
}

provider "helm" {
  kubernetes {
    host = data.azurerm_kubernetes_cluster.default.kube_config.0.host
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.cluster_ca_certificate)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "/home/freshchris/.asdf/shims/kubelogin"
      args = [
        "get-token",
        "--login",
        "spn",
        "--environment",
        "AzurePublicCloud",
        "--tenant-id",
        var.tenant_id,
        "--server-id",
        var.aad_server_id,
        "--client-id",
        var.client_id,
        "--client-secret",
        var.client_secret
      ]
    }
  }
}

provider "kubectl" {
  host = data.azurerm_kubernetes_cluster.default.kube_config.0.host
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "/home/freshchris/.asdf/shims/kubelogin"
    args = [
      "get-token",
      "--login",
      "spn",
      "--environment",
      "AzurePublicCloud",
      "--tenant-id",
      var.tenant_id,
      "--server-id",
      var.aad_server_id,
      "--client-id",
      var.client_id,
      "--client-secret",
      var.client_secret
    ]
  }
}

provider "azurerm" {
  features {}
}

module "aad" {
  source = "./aad"
}

module "aks-cluster" {
  depends_on             = [module.aad]
  source                 = "./aks-cluster"
  cluster_name           = local.cluster_name
  location               = var.location
  cluster_admin_group_id = module.aad.admin_group_id
}

module "kubernetes-config" {
  depends_on   = [module.aks-cluster]
  source       = "./kubernetes-config"
  cluster_name = local.cluster_name
}
