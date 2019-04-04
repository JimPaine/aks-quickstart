resource "helm_release" "prometheus" {
    name      = "prometheus"
    chart     = "stable/prometheus"
}

resource "helm_release" "grafana" {
    name      = "grafana"
    chart     = "stable/grafana"
}

resource "helm_release" "helm" {
    name      = "grafana"
    chart     = "https://github.com/Azure/aad-pod-identity/archive/master.zip"
    values = [
        "${file("values.yaml")}"
    ]
}