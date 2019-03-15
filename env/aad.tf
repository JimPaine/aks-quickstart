resource "azuread_application" "demo" {
  name                       = "${var.resource_name}${random_id.demo.dec}"
  homepage                   = "https://homepage${random_id.demo.dec}"
  identifier_uris            = ["https://uri${random_id.demo.dec}"]
  reply_urls                 = ["https://uri${random_id.demo.dec}"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
}

resource "azuread_service_principal" "demo" {
  application_id = "${azuread_application.demo.application_id}"
}

resource "random_string" "demo" {
  length  = "32"
  special = true
}

resource "azuread_service_principal_password" "demo" {
  service_principal_id = "${azuread_service_principal.demo.id}"
  value                = "${random_string.demo.result}"
  end_date             = "2020-01-01T01:02:03Z"
}

resource "azurerm_role_assignment" "demo" {
  scope                = "${azurerm_virtual_network.aks.id}"
  role_definition_name = "Network Contributor"
  principal_id         = "${azuread_service_principal.demo.id}"
}