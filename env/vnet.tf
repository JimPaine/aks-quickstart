resource "azurerm_route_table" "demo" {
  name                = "${var.resource_name}-routetable"
  location            = "${azurerm_resource_group.demo.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"

  route {
    name                   = "default"
    address_prefix         = "10.100.0.0/14"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.1.1"
  }
}

resource "azurerm_virtual_network" "demo" {
  name                = "${var.resource_name}-network"
  location            = "${azurerm_resource_group.demo.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "demo" {
  name                 = "internal"
  resource_group_name  = "${azurerm_resource_group.demo.name}"
  address_prefix       = "10.1.0.0/24"
  virtual_network_name = "${azurerm_virtual_network.demo.name}"

  # this field is deprecated and will be removed in 2.0 - but is required until then
  route_table_id = "${azurerm_route_table.demo.id}"
}

resource "azurerm_subnet_route_table_association" "demo" {
  subnet_id      = "${azurerm_subnet.demo.id}"
  route_table_id = "${azurerm_route_table.demo.id}"
}

resource "azurerm_public_ip" "demo" {
  name                = "pip"
  location            = "${azurerm_resource_group.demo.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "demo" {
  name                = "firewall"
  location            = "${azurerm_resource_group.demo.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = "${azurerm_subnet.demo.id}"
    public_ip_address_id = "${azurerm_public_ip.demo.id}"
  }
}