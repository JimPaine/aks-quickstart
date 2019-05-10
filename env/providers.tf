provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  version         = "~> 1.27"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

provider "azuread" {
  version = "~>0.1.0"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
  subscription_id = "${var.subscription_id}"
}

provider "random" {
  version = "~> 1.3"
}

provider "kubernetes" {
  version                = "~> 1.1"
  host                   = "${azurerm_kubernetes_cluster.aks.kube_config.0.host}"
  client_certificate     = "${base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)}"
  client_key             = "${base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)}"
  cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)}"
}

provider "dnsimple" {
  token = "${var.dnsimple_auth_token}"
  account = "${var.dnsimple_account}"
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
  version = "~>1.1.1"
}

provider "tls" {
  version = "~> 1.2"
}

provider "helm" {
  version = "~> 0.9"
  service_account = "tiller"
    kubernetes {
      host                   = "${azurerm_kubernetes_cluster.aks.kube_config.0.host}"
      client_certificate     = "${base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)}"
      client_key             = "${base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)}"
      cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)}"
    }
}
