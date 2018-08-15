resource "azurerm_key_vault" "demo" {
  name                = "${var.resource_name}${random_id.demo.dec}vault"
  location            = "${azurerm_resource_group.demo.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"
  tenant_id           = "${data.azurerm_client_config.demo.tenant_id}"

  sku {
    name = "standard"
  }

  access_policy {
    tenant_id = "${data.azurerm_client_config.demo.tenant_id}"

    object_id = "${data.azurerm_client_config.demo.service_principal_object_id}"

    key_permissions = []

    secret_permissions = [
      "list",
      "set",
      "get",
    ]
  }
}
resource "azurerm_key_vault_secret" "kubeconfig" {
  name      = "kubeconfig"
  value     = "${azurerm_kubernetes_cluster.demo.kube_config_raw}"
  vault_uri = "${azurerm_key_vault.demo.vault_uri}"
}

resource "azurerm_key_vault_secret" "acrserver" {
  name      = "acrserver"
  value     = "${azurerm_container_registry.demo.login_server}"
  vault_uri = "${azurerm_key_vault.demo.vault_uri}"
}
resource "azurerm_key_vault_secret" "acrusername" {
  name      = "acrusername"
  value     = "${azurerm_container_registry.demo.admin_username}"
  vault_uri = "${azurerm_key_vault.demo.vault_uri}"
}

resource "azurerm_key_vault_secret" "acrpassword" {
  name      = "acrpassword"
  value     = "${azurerm_container_registry.demo.admin_password}"
  vault_uri = "${azurerm_key_vault.demo.vault_uri}"
}
