
# Generate the SSH key that will be used for the Linux account on the worker nodes
resource "tls_private_key" "aks" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.resource_name}${random_id.aks.dec}"
  location            = "${azurerm_resource_group.aks.location}"
  resource_group_name = "${azurerm_resource_group.aks.name}"
  dns_prefix          = "${var.resource_name}${random_id.aks.dec}"

  # set the Linux profile details using the ssh key we just generated. 
  # Not that it should be used to access the VM directly, hence why I don't 
  # store it in Azure Key Vault
  linux_profile {
    admin_username = "clusteradmin"

    ssh_key {
      key_data = "${tls_private_key.aks.public_key_openssh}"
    }
  }

  kubernetes_version = "1.14.0"

  agent_pool_profile {
    name            = "default"
    count           = 1
    vm_size         = "Standard_B2s"
    os_type         = "Linux"
    os_disk_size_gb = 30
    type = "VirtualMachineScaleSets"

    # Attach the AKS cluster to the subnet within the VNet we have created
    vnet_subnet_id = "${azurerm_subnet.aks.id}"
  }

   agent_pool_profile {
    name            = "default"
    count           = 1
    vm_size         = "Standard_B2s"
    os_type         = "Windows"
    os_disk_size_gb = 30
    type = "VirtualMachineScaleSets"

    # Attach the AKS cluster to the subnet within the VNet we have created
    vnet_subnet_id = "${azurerm_subnet.aks.id}"
  }

  service_principal {
    client_id     = "${azuread_application.aks.application_id}"
    client_secret = "${azuread_service_principal_password.aks.value}"
  }

  network_profile {
    network_plugin = "azure"
    dns_service_ip = "10.2.2.254"
    service_cidr = "10.2.2.0/24"
    docker_bridge_cidr = "172.17.0.1/16"
    network_policy = "azure"
  }

  # Enabled RBAC
  role_based_access_control {
    enabled = true
  }

  addon_profile {

    # Add the OMS Agent which will generate and collect all the logs to put into
    # Azure Monitor for Container Insights
    oms_agent {
      enabled = true
      log_analytics_workspace_id = "${azurerm_log_analytics_workspace.aks.id}"
    }
  }  
}
