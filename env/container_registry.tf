resource "azurerm_storage_account" "demo" {
  name                     = "${var.resource_name}${random_id.demo.dec}storage"
  resource_group_name      = "${azurerm_resource_group.demo.name}"
  location                 = "${azurerm_resource_group.demo.location}"
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_container_registry" "demo" {
  name                = "${var.resource_name}${random_id.demo.dec}registry"
  resource_group_name = "${azurerm_resource_group.demo.name}"
  location            = "${azurerm_resource_group.demo.location}"
  admin_enabled       = true
  sku                 = "Classic"
  storage_account_id  = "${azurerm_storage_account.demo.id}"
}
