resource "kubernetes_namespace" "dev" {
  depends_on = ["azurerm_kubernetes_cluster.aks"]

  metadata {
    name = "dev"
  }
}

locals {
  dockercfg = {
    "${azurerm_container_registry.aks.login_server}" = {
      email    = "notneeded@notneeded.com"
      username = "${azurerm_container_registry.aks.admin_username}"
      password = "${azurerm_container_registry.aks.admin_password}"
    }
  }
}

resource "kubernetes_secret" "demo" {
  depends_on = ["kubernetes_namespace.dev"]

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

resource "kubernetes_network_policy" "traefik" {
  depends_on = ["azurerm_kubernetes_cluster.aks"]

  metadata {
    name      = "traefik-network-policy"
    namespace = "dev"
  }

  spec {
    pod_selector {
      match_labels {
        app = "api"
      }
    }

    ingress = [
      {
        from = [
          {
            pod_selector {
              match_labels {
                app = "traefik"
              }
            }
          },
        ]
      },
    ]

    egress = [{}] # single empty rule to allow all egress traffic

    policy_types = ["Ingress", "Egress"]
  }
}