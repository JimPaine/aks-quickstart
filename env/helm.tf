resource "helm_release" "prometheus" {
    name      = "prometheus"
    chart     = "stable/prometheus"
}

resource "helm_release" "grafana" {
    name      = "grafana"
    chart     = "stable/grafana"
}

locals {
  annotations = {
    "service.beta.kubernetes.io/azure-load-balancer-internal" = "true"
  }
}
