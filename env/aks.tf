resource "tls_private_key" "demo" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "azurerm_kubernetes_cluster" "demo" {
  name                = "${var.resource_name}${random_id.demo.dec}"
  location            = "${azurerm_resource_group.demo.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"
  dns_prefix          = "${var.resource_name}${random_id.demo.dec}"

  linux_profile {
    admin_username = "clusteradmin"

    ssh_key {
      key_data = "${tls_private_key.demo.public_key_openssh}"
    }
  }

  kubernetes_version = "1.12.4"

  agent_pool_profile {
    name            = "default"
    count           = 3
    vm_size         = "Standard_D1_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30

    vnet_subnet_id = "${azurerm_subnet.demo.id}"
  }

  service_principal {
    client_id     = "${azuread_application.demo.application_id}"
    client_secret = "${azuread_service_principal_password.demo.value}"
  }

  network_profile {
    network_plugin = "azure"
  }

  role_based_access_control {
    enabled = true
  }

  oms_agent {
    enabled = true
    log_analytics_workspace_id = "${azurerm_log_analytics_workspace.demo.workspace_id}"
  }
}
