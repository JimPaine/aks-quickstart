# Private clusters for AKS

Before getting started it is only fair to mention there are a few gaps with "private" managed Kubernetes clusters, with Azure for example the management API is still exposed on a public IP, you'll obviously have this protected with service accounts and RBAC for reducing access further and the road map clearly shows lots being worked on to help lock this down further.

[IP White listing](https://feedback.azure.com/forums/914020-azure-kubernetes-service-aks/suggestions/35010421-secure-aks-api-from-public-internet)
[Management API on a private IP](https://azure.microsoft.com/en-gb/updates/aks-private-cluster/)

That being said there is loads we can do already, like:

- Attach Kubernetes to a pre-defined virtual network
- Expose services on private IP addresses rather than the default behavior of public IPs
- Put exposed services behind a firewall / WAF

So lets take a look at how we go a head and implement AKS with CNI.

## Create a subnet 

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

## Exposing a Service

So now we have AKS sitting in a subnet we have created and we have given the cluster permission to create a load balancer, what we need to do now is provision a service on a private IP address rather than a public one. In this example I have decided to put all my own services on ClusterIPs, meaning they aren't exposed outside of Kubernetes, then use an ingress controller such as Traefik or Nginx to expose specific services.

### It's all in the annotations

The first thing you need is to add an ingress controller like I mentioned earlier and add an annotation telling it to use a private IP address and an Azure load balancer, here is a snippet from my [terraform](/env/traefik.tf)

Here we are saying the service should create and use an Azure load balancer, hence the Network Contributor role we needed to set [here](/docs/rbac.md)

```
service:
          annotations:
            service.beta.kubernetes.io/azure-load-balancer-internal: "true"
```

I am also giving it a specific private IP within the range of the defined subnet, allowing me to setup my Application Gateway rules.

```
  set {
        name = "loadBalancerIP"
        value = "10.2.1.254"
    }
```

Now that our ingress controller is setup on a private IP address we need to add an ingress rule for what we would like to expose. [Here](/apps/deployment.yaml) is my example for my demo app.

```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: api
  namespace: dev
  annotations:
    kubernetes.io/ingress.class: traefik
    traefik.frontend.passHostHeader: "true"
spec:
  rules:
  - host: aks.jim.cloud
    http:
      paths:
      - path: /values
        backend:
          serviceName: api
          servicePort: 80
```

You can see it is using the Kubernetes kind and schema to define a rule along with a couple of specific annotations specific to my ingress implementation, in this case Traefik.

Now our service is avaiable on https://aks.jim.cloud/values and this specific service on https://aks.jim.cloud/values/api/values

The reason is is exposed over ssl and not on port 80 is because I have an application gateway with WAF sat in front of my ingress controller with ssl offload. 

