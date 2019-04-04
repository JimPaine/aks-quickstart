resource "azurerm_container_registry" "aks" {
  name                = "${random_id.aks.dec}registry"
  resource_group_name = "${azurerm_resource_group.aks.name}"
  location            = "${azurerm_resource_group.aks.location}"
  admin_enabled       = true
  sku                 = "Premium"
}
