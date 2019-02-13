resource "azurerm_azuread_application" "demo" {
  name                       = "${var.resource_name}${random_id.demo.dec}"
  homepage                   = "http://homepage${random_id.demo.dec}"
  identifier_uris            = ["http://uri${random_id.demo.dec}"]
  reply_urls                 = ["http://replyurl${random_id.demo.dec}"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
}

resource "azurerm_azuread_service_principal" "demo" {
  application_id = "${azurerm_azuread_application.demo.application_id}"
}

resource "random_string" "demo" {
  length  = "32"
  special = true
}

resource "azurerm_azuread_service_principal_password" "demo" {
  service_principal_id = "${azurerm_azuread_service_principal.demo.id}"
  value                = "${random_string.demo.result}"
  end_date             = "2020-01-01T01:02:03Z"
}

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
