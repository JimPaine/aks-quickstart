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

resource "helm_release" "nginxingress" {
    name      = "nginx-ingress"
    chart     = "stable/nginx-ingress"

    set_string {
        name = "controller.service.annotations"
        value = "${ jsonencode(local.annotations) }"
    }

    set_string {
        name = "controller.service.loadBalancerIP"
        value = "10.1.0.254"
    }
}