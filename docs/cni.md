# Private clusters for AKS

Before getting started it is only fair to mention there are a few gaps with "private" managed Kubernetes clusters, with Azure for example the management API is still exposed on a public IP, you'll obviously have this protected with service accounts and RBAC for reducing access further and the road map clearly shows lots being worked on to help lock this down further.

[IP White listing](https://feedback.azure.com/forums/914020-azure-kubernetes-service-aks/suggestions/35010421-secure-aks-api-from-public-internet)
[Management API on a private IP](https://azure.microsoft.com/en-gb/updates/aks-private-cluster/)

That being said there is loads we can do already, like:

- Attach Kubernetes to a pre-defined virtual network
- Expose services on private IP addresses rather than the default behavior of public IPs
- Put exposed services behind a firewall / WAF

So lets take a look at how we go a head and implement AKS with CNI.

## Create a subent 

It is worth reading through the [prerequisites](https://docs.microsoft.com/en-us/azure/aks/configure-azure-cni#prerequisites) as there are a few things to keep in mind, especially around planning for IPs.

Creating the VNet and a subnet is easy, just make sure you make the address space big enough, as nodes, pods and services will all want an IP.

```
resource "azurerm_virtual_network" "aks" {
  name                = "${var.resource_name}-aks-network"
  location            = "${azurerm_resource_group.aks.location}"
  resource_group_name = "${azurerm_resource_group.aks.name}"
  address_space       = ["10.2.0.0/16"]
}

resource "azurerm_subnet" "aks" {
  name                 = "aks"
  resource_group_name  = "${azurerm_resource_group.aks.name}"
  address_prefix       = "10.2.1.0/24"
  virtual_network_name = "${azurerm_virtual_network.aks.name}"
}
```

## Permissions

Because we are implementing our own networking we also need to make sure that the Service Principal has "Network Contributor" permissions on at least the subnet that AKS is provisioned in.

So to do this we use the "azurerm_role_assignment" resource within Terraform, which allows us to take the id of the service principal we have created and used to provision AKS

```

resource "azuread_service_principal" "aks" {
  application_id = "${azuread_application.aks.application_id}"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.resource_name}${random_id.aks.dec}"
  location            = "${azurerm_resource_group.aks.location}"
  resource_group_name = "${azurerm_resource_group.aks.name}"
  dns_prefix          = "${var.resource_name}${random_id.aks.dec}"

  ...

  service_principal {
    client_id     = "${azuread_application.aks.application_id}"
    client_secret = "${azuread_service_principal_password.aks.value}"
  }

  agent_pool_profile {
    ...
    
    vnet_subnet_id = "${azurerm_subnet.aks.id}"
  }

  network_profile {
    network_plugin = "azure"
    dns_service_ip = "10.2.2.254"
    service_cidr = "10.2.2.0/24"
    docker_bridge_cidr = "172.17.0.1/16"
  }
}

resource "azurerm_role_assignment" "aks" {
  scope              = "${azurerm_subnet.aks.id}"
  role_definition_name = "Network Contributor"
  principal_id       = "${azuread_service_principal.aks.id}"
}
```