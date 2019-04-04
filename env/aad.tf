resource "azuread_application" "aks" {
  name                       = "${var.resource_name}${random_id.aks.dec}"
  homepage                   = "https://homepage${random_id.aks.dec}"
  identifier_uris            = ["https://uri${random_id.aks.dec}"]
  reply_urls                 = ["https://replyurl${random_id.aks.dec}"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
}

resource "azuread_service_principal" "aks" {
  application_id = "${azuread_application.aks.application_id}"
}

resource "random_string" "aks" {
  length  = "32"
  special = true
}

resource "azuread_service_principal_password" "aks" {
  service_principal_id = "${azuread_service_principal.aks.id}"
  value                = "${random_string.aks.result}"
  end_date             = "2020-01-01T01:02:03Z"
}