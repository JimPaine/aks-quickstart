resource "azurerm_log_analytics_workspace" "demo" {
  name                = "${var.resource_name}${random_id.demo.dec}logs"
  location            = "${azurerm_resource_group.demo.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"
  sku                 = "PerNode"
  retention_in_days   = 30
}