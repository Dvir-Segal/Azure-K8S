terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0" # Use a compatible version for the helm provider
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0" # Required by the helm provider to interact with the cluster
    }
  }
}

provider "azurerm" {
  subscription_id = "7f1c641d-c699-4627-8c17-26ab625689b3"
  client_id       = "f855c8a4-9829-4650-b192-5924301d831a"
  client_secret   = "NQb8Q~cEYL6Apc4BFInh.fQXj86_GBgA-oJvqckp"
  tenant_id       = "37f1fc7c-26d4-4039-9d53-30c8c9301f7b"
  features {}
}

provider "helm" {
  kubernetes {
    config_path = local_file.kubeconfig.filename
  }
}

provider "kubernetes" {
  config_path = local_file.kubeconfig.filename
}