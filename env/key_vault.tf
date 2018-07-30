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
