resource "kubernetes_namespace" "demo" {
  metadata {
    name = "dev"
  }
}

locals {
  dockercfg = {
    "${azurerm_container_registry.demo.login_server}" = {
      email    = "notneeded@notneeded.com"
      username = "${azurerm_container_registry.demo.admin_username}"
      password = "${azurerm_container_registry.demo.admin_password}"
    }
  }
}

resource "kubernetes_secret" "demo" {
  metadata {
    name      = "registry"
    namespace = "dev"
  }

  # terraform states this is a map of the variables here, it actual wants a structured json object
  # https://github.com/terraform-providers/terraform-provider-kubernetes/issues/81
  data {
    ".dockercfg" = "${ jsonencode(local.dockercfg) }"
  }

  type = "kubernetes.io/dockercfg"
}
