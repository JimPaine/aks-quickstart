resource "azurerm_kubernetes_cluster" "demo" {
  name                = "${var.resource_name}${random_id.demo.dec}"
  location            = "${azurerm_resource_group.demo.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"
  dns_prefix          = "${var.resource_name}${random_id.demo.dec}"

  linux_profile {
    admin_username = "clusteradmin"

    ssh_key {
      key_data = "${file("id_rsa.pub")}"
    }
  }

  agent_pool_profile {
    name            = "default"
    count           = 3
    vm_size         = "Standard_D1_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = "${azuread_application.demo.application_id}"
    client_secret = "${azuread_service_principal_password.demo.value}"
  }
}
