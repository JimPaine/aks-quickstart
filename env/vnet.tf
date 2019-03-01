resource "azurerm_virtual_network" "demo" {
  name                = "${var.resource_name}-network"
  location            = "${azurerm_resource_group.demo.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = "${azurerm_resource_group.demo.name}"
  address_prefix       = "10.1.0.0/24"
  virtual_network_name = "${azurerm_virtual_network.demo.name}"
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
    subnet_id            = "${azurerm_subnet.firewall.id}"
    public_ip_address_id = "${azurerm_public_ip.demo.id}"
  }
}

resource "azurerm_firewall_network_rule_collection" "demo" {
  name                = "inboundk8s"
  azure_firewall_name = "${azurerm_firewall.demo.name}"
  resource_group_name = "${azurerm_resource_group.demo.name}"
  priority            = 100
  action              = "Allow"

  rule {
    name = "inboundk8s"

    source_addresses = [
      "*",
    ]

    destination_ports = [
      "80",
    ]

    destination_addresses = [
      "10.1.0.254",
    ]

    protocols = [
      "TCP",
    ]
  }
}