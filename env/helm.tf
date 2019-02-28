resource "helm_release" "prometheus" {
    name      = "prometheus"
    chart     = "stable/prometheus"
}

resource "helm_release" "grafana" {
    name      = "grafana"
    chart     = "stable/grafana"
}

resource "helm_release" "corednsetcd" {
    name      = "etcdoperator"
    chart     = "stable/etcd-operator"

    set {
        name = "cluster.enabled"
        value = "true"
    }
}
