resource "helm_release" "traefik" {
    name      = "traefik"
    chart     = "stable/traefik"

    namespace = "dev"

    set {
        name = "loadBalancerIP"
        value = "10.1.0.254"
    }

    values = [<<VALUES
        service:
          annotations:
            service.beta.kubernetes.io/azure-load-balancer-internal: "true"
    VALUES
    ]
}

resource "kubernetes_service_account" "traefik" {
  metadata {
    name = "traefik"
    namespace = "dev"
  }
}

resource "kubernetes_cluster_role" "traefik" {
    metadata {
        name = "traefik-controller"
    }

    rule {
        api_groups = ["extensions"]
        resources  = ["ingresses"]
        verbs      = ["get", "list", "watch"]
    }
}

resource "kubernetes_cluster_role_binding" "traefik" {
    metadata {
        name = "traefik-controller-binding"
    }
    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind = "ClusterRole"
        name = "traefik-controller"
    }
    subject {
        kind = "ServiceAccount"
        name = "traefik"
        namespace = "dev"
        api_group = ""
    }
}
