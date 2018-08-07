data "azurerm_client_config" "demo" {}

output "id" {
  value = "${azurerm_kubernetes_cluster.demo.id}"
}

output "kube_config" {
  value = "${azurerm_kubernetes_cluster.demo.kube_config_raw}"
}

output "client_key" {
  value = "${azurerm_kubernetes_cluster.demo.kube_config.0.client_key}"
}

output "client_certificate" {
  value = "${azurerm_kubernetes_cluster.demo.kube_config.0.client_certificate}"
}

output "cluster_ca_certificate" {
  value = "${azurerm_kubernetes_cluster.demo.kube_config.0.cluster_ca_certificate}"
}

output "host" {
  value = "${azurerm_kubernetes_cluster.demo.kube_config.0.host}"
}

output "acr_server" {
  value = "${azurerm_container_registry.demo.login_server}"
}

output "acr_username" {
  value = "${azurerm_container_registry.demo.admin_username}"
}

output "acr_password" {
  value = "${azurerm_container_registry.demo.admin_password}"
}