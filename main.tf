resource "azurerm_resource_group" "aks" {
  name = "aks-rg"
  location = "eastus"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "example-aks1"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "dvircluster"

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_D2s_v4"
  }



  identity {
    type = "SystemAssigned"
  }


  tags = {
    Environment = "Production"
  }
}

resource "local_file" "kubeconfig" {
    content = azurerm_kubernetes_cluster.aks.kube_config_raw
    filename = "kubeconfig"
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx" # You can choose a different namespace
  create_namespace = true

  # Add any custom values for the Ingress Controller here.
  # For example, to enable a Load Balancer service:
  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }
  set {
    name = "controller.service.type"
    value = "LoadBalancer"
  }
  # More configuration options can be found in the ingress-nginx chart documentation
  # https://kubernetes.github.io/ingress-nginx/chart/

  # Ensure this release is created only after the AKS cluster is ready and kubeconfig is available
  depends_on = [azurerm_kubernetes_cluster.aks, local_file.kubeconfig]
}