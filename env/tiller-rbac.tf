resource "kubernetes_service_account" "tiller" {
  metadata {
    name = "tiller"
    namespace = "dev"
  }
}

resource "kubernetes_cluster_role" "tiller" {
    metadata {
        name = "tiller-manager"
    }

    rule {
        api_groups = ["", "batch", "extensions", "apps"]
        resources  = ["*"]
        verbs      = ["*"]
    }
}

resource "kubernetes_cluster_role_binding" "tiller" {
    metadata {
        name = "tiller-binding"
    }
    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind = "ClusterRole"
        name = "tiller-manager"
    }
    subject {
        kind = "ServiceAccount"
        name = "tiller"
        namespace = "dev"
        api_group = ""
    }
}

resource "kubernetes_service_account" "clustertiller" {
  metadata {
    name = "clustertiller"
    namespace = "kube-system"
  }
}
resource "kubernetes_cluster_role_binding" "clustertiller" {
    metadata {
        name = "clustertiller-binding"
    }
    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind = "ClusterRole"
        name = "cluster-admin"
    }
    subject {
        kind = "ServiceAccount"
        name = "clustertiller"
        namespace = "kube-system"
        api_group = ""
    }
}
