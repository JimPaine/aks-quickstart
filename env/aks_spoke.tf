resource "azurerm_virtual_network" "aks" {
  name                = "${var.resource_name}-network"
  location            = "${azurerm_resource_group.demo.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"
  address_space       = ["10.1.0.0/16"]
}


resource "azurerm_subnet" "aks" {
  name                 = "aks"
  resource_group_name  = "${azurerm_resource_group.demo.name}"
  address_prefix       = "10.1.0.0/24"
  virtual_network_name = "${azurerm_virtual_network.aks.name}"
}