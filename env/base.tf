resource "azurerm_resource_group" "aks" {
  name     = "${var.resource_name}"
  location = "westeurope"
}

resource "random_id" "aks" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${azurerm_resource_group.aks.name}"
  }

  byte_length = 2
}
