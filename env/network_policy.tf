resource "kubernetes_network_policy" "traefik" {
  depends_on = ["azurerm_kubernetes_cluster.aks"]

  metadata {
    name      = "traefik-network-policy"
    namespace = "dev"
  }

  spec {
    pod_selector {
      match_labels = {
        app = "api"
        namespace = "dev"
      }
    }

    ingress = [
      {
        ports = [
          {
            port = "http"
            protocol = "TCP"
          },
          {
            port = "443"
            protocol = "TCP"
          }
        ]
        from = [
          {
            pod_selector {
              match_labels = {
                app = "traefik"
                namespace = "dev"
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
