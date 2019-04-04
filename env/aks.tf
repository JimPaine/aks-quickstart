resource "tls_private_key" "aks" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.resource_name}${random_id.aks.dec}"
  location            = "${azurerm_resource_group.aks.location}"
  resource_group_name = "${azurerm_resource_group.aks.name}"
  dns_prefix          = "${var.resource_name}${random_id.aks.dec}"

  linux_profile {
    admin_username = "clusteradmin"

    ssh_key {
      key_data = "${tls_private_key.aks.public_key_openssh}"
    }
  }

  kubernetes_version = "1.12.6"

  agent_pool_profile {
    name            = "default"
    count           = 3
    vm_size         = "Standard_D1_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30

    vnet_subnet_id = "${azurerm_subnet.aks.id}"
  }

  service_principal {
    client_id     = "9b6a83fc-e60e-4301-becc-5aa65fd5ae8e"
    client_secret = "7ymcPp5vbGKFrqDCxPiLlnI6X4rzQKop8LKP7dJ9nPA="
  }

  network_profile {
    network_plugin = "azure"
    dns_service_ip = "10.2.2.254"
    service_cidr = "10.2.2.0/24"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  role_based_access_control {
    enabled = true
  }

  addon_profile {
    oms_agent {
      enabled = true
      log_analytics_workspace_id = "${azurerm_log_analytics_workspace.aks.id}"
    }
  }  
}
