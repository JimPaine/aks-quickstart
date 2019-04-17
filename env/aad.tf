# Create an application which we will assign to the nodes within our cluster
resource "azuread_application" "aks" {
  name                       = "${var.resource_name}${random_id.aks.dec}"
  homepage                   = "https://homepage${random_id.aks.dec}"
  identifier_uris            = ["https://uri${random_id.aks.dec}"]
  reply_urls                 = ["https://uri${random_id.aks.dec}"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
}

# We need to wrap it up in a service principal so we can assign it credentials
resource "azuread_service_principal" "aks" {
  application_id = "${azuread_application.aks.application_id}"
}

# Generate a password for our service principal
resource "random_string" "aks" {
  length  = "32"
  special = true
}

# Set the password of the service principal
resource "azuread_service_principal_password" "aks" {
  service_principal_id = "${azuread_service_principal.aks.id}"
  value                = "${random_string.aks.result}"
  end_date             = "2020-01-01T01:02:03Z"
}

# When using Advanced networking in AKS or Container Networking Interface (CNI)
# we need our Service Principal to have access to create resources within the 
# Subnet AKS is attached to.
resource "azurerm_role_assignment" "aks" {
  scope              = "${azurerm_resource_group.aks.id}"
  role_definition_name = "Network Contributor"
  principal_id       = "${azuread_service_principal.aks.id}"
}