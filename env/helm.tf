resource "helm_release" "prometheus" {
    name      = "prometheus"
    chart     = "stable/prometheus"
}

resource "helm_release" "grafana" {
    name      = "grafana"
    chart     = "stable/grafana"
}

resource "helm_release" "traefik" {
    name      = "traefik"
    chart     = "stable/traefik"

    namespace = "dev"

    values = [<<VALUES
        loadBalancerIP: 10.1.0.254
        service:
          annotations: 
            service.beta.kubernetes.io/azure-load-balancer-internal: "true"
    VALUES
    ]
}
