# 1. Terraform Block - Defines required providers and their versions
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

# 2. Provider Configuration Blocks
#    These tell Terraform how to authenticate and interact with Azure, Helm, and Kubernetes.

provider "azurerm" {
  features {}
}

provider "helm" {
  kubernetes {
    config_path = local_file.kubeconfig.filename # Path to the generated kubeconfig file
  }
}

provider "kubernetes" {
  config_path = local_file.kubeconfig.filename # Path to the generated kubeconfig file
}

# 3. Resource Group - Container for all Azure resources
resource "azurerm_resource_group" "aks" {
  name     = "aks-rg"
  location = "eastus"
}

# 4. Azure Kubernetes Service (AKS) Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "bitcoin-aks"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "dvircluster"

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_D2s_v4"
  }

  # **IMPORTANT: Network Profile for Calico Network Policy Support**
  # This block is crucial for enabling Network Policies (Calico) on the AKS cluster.
  network_profile {
    network_plugin    = "azure"    # Common CNI for AKS. Use "kubenet" if preferred, but Azure CNI is recommended for advanced features.
    network_policy    = "calico"   # This enables Network Policy enforcement using Calico.
  }

  identity {
    type = "SystemAssigned" # System-assigned Managed Identity for AKS cluster
  }

  tags = {
    Environment = "Production"
  }
}

# 5. Local File for Kubeconfig
# This resource saves the generated kubeconfig to a local file, allowing kubectl to connect.
resource "local_file" "kubeconfig" {
    content  = azurerm_kubernetes_cluster.aks.kube_config_raw
    filename = "kubeconfig" # The file will be named 'kubeconfig' in the current directory
}

# 6. Helm Release for NGINX Ingress Controller
# This resource deploys the NGINX Ingress Controller using the Helm provider.
resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx" # Deploy Ingress Controller in its own namespace
  create_namespace = true            # Create the namespace if it doesn't exist

  # Custom values for the Ingress Controller Helm chart
  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }
  set {
    name  = "controller.service.type"
    value = "LoadBalancer" # Expose the Ingress Controller via an Azure Load Balancer
  }
  
  # Ensure Helm release happens only after AKS is fully provisioned and kubeconfig is available
  depends_on = [azurerm_kubernetes_cluster.aks, local_file.kubeconfig]
}