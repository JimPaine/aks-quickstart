resource "azurerm_log_analytics_workspace" "aks" {
  name                = "${random_id.aks.dec}logs"
  location            = "${azurerm_resource_group.aks.location}"
  resource_group_name = "${azurerm_resource_group.aks.name}"
  sku                 = "PerNode"
  retention_in_days   = 30
}

resource "azurerm_log_analytics_solution" "aks" {
  solution_name         = "ContainerInsights"
  location              = "${azurerm_resource_group.aks.location}"
  resource_group_name   = "${azurerm_resource_group.aks.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.aks.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.aks.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}