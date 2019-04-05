# The application gateway needs its own subnet as the only things that can be in 
# the same subnet as an application gateway our other application gateways.
resource "azurerm_subnet" "gateway" {
  name                 = "gateway"
  resource_group_name  = "${azurerm_resource_group.aks.name}"
  address_prefix       = "10.2.2.0/24"
  virtual_network_name = "${azurerm_virtual_network.aks.name}"
}

resource "azurerm_public_ip" "gateway" {
  name                = "fw"
  location            = "${azurerm_resource_group.aks.location}"
  resource_group_name = "${azurerm_resource_group.aks.name}"
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label = "aks${random_id.aks.dec}" # Create a domain label which we can use for our CNAME for our custom domain
}

resource "azurerm_application_gateway" "aks" {
  name                = "${var.resource_name}-appgateway"
  resource_group_name = "${azurerm_resource_group.aks.name}"
  location            = "${azurerm_resource_group.aks.location}"

  sku {
    name     = "WAF_V2"
    tier     = "WAF_V2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gatewayconfig"
    subnet_id = "${azurerm_subnet.gateway.id}"
  }

  frontend_port {
    name = "https"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "pip"
    public_ip_address_id = "${azurerm_public_ip.gateway.id}"
  }

  ssl_certificate {
    name = "Cert"
    data = "${acme_certificate.aks.certificate_p12}"
    password = "${random_string.certpass.result}"
  }

  # Set the Kubernetes ingress entry point at the backend pool
  # this is set in traefik.tf
  backend_address_pool {
    name = "k8s"
    ip_addresses = ["10.2.1.254"]
  }

  backend_http_settings {
    name                  = "http"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
    probe_name = "dashboardprobe"
  }

  # This is the route that traefik publishs for helth
  # so this would need to be changed if you switched to
  # Nginx for ingress
  probe {
      interval = 15
      name = "dashboardprobe"
      protocol = "Http"
      path = "/health"
      timeout = 1
      unhealthy_threshold = 3
      host = "${dnsimple_record.aks.hostname}" # The host name will be the fqdn of our custom domain, in my case aks.jim.cloud
  }

  http_listener {
    name                           = "http"
    frontend_ip_configuration_name = "pip"
    frontend_port_name             = "https"
    protocol                       = "Https"
    ssl_certificate_name = "Cert"
  }

  request_routing_rule {
    name                       = "httplistener"
    rule_type                  = "Basic"
    http_listener_name         = "http"
    backend_address_pool_name  = "k8s"
    backend_http_settings_name = "http"
  }
}
