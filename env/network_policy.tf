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
      }
    }

    ingress = [
      {
        from = [
          {
            namespace_selector { }
            
            pod_selector {
              match_labels = {
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
