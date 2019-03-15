resource "azurerm_virtual_network" "aks" {
  name                = "${var.resource_name}-aks-network"
  location            = "${azurerm_resource_group.demo.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"
  address_space       = ["10.2.0.0/16"]
}

resource "azurerm_subnet" "aks" {
  name                 = "aks"
  resource_group_name  = "${azurerm_resource_group.demo.name}"
  address_prefix       = "10.2.1.0/24"
  virtual_network_name = "${azurerm_virtual_network.aks.name}"
  route_table_id       = "${azurerm_route_table.demo.id}"
}

resource "azurerm_route_table" "demo" {
  name                          = "hubrouter"
  location                      = "${azurerm_resource_group.demo.location}"
  resource_group_name           = "${azurerm_resource_group.demo.name}"
  disable_bgp_route_propagation = false
  
  route {
    name           = "hub"
    address_prefix = "10.1.1.0/24"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = "${azurerm_firewall.demo.ip_configuration.0.private_ip_address}"
  }
}

resource "azurerm_subnet_route_table_association" "demo" {
  subnet_id      = "${azurerm_subnet.aks.id}"
  route_table_id = "${azurerm_route_table.demo.id}"
}

resource "azurerm_virtual_network_peering" "hubtoaks" {
  name                      = "hubtoaks"
  resource_group_name       = "${azurerm_resource_group.demo.name}"
  virtual_network_name      = "${azurerm_virtual_network.hub.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.aks.id}"
}

resource "azurerm_virtual_network_peering" "akstohub" {
  name                      = "akstohub"
  resource_group_name       = "${azurerm_resource_group.demo.name}"
  virtual_network_name      = "${azurerm_virtual_network.aks.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.hub.id}"
}