resource "helm_release" "prometheus" {
    name      = "prometheus"
    chart     = "stable/prometheus"
}

resource "helm_release" "grafana" {
    name      = "grafana"
    chart     = "stable/grafana"
}

resource "helm_release" "nginx" {
    name      = "nginxdev"
    chart     = "stable/nginx-ingress"

    namespace = "dev"

    values = [<<VALUES
        controller:
          service:
            type: LoadBalancer
            loadBalancerIP: 10.1.0.254
            annotations: 
              service.beta.kubernetes.io/azure-load-balancer-internal: "true"
    VALUES
    ]
}
