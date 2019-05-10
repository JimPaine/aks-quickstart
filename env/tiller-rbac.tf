# Create a Service Account to run tiller as
# This is specific to our namespace as well
resource "kubernetes_service_account" "tiller" {
  metadata {
    name = "tiller"
    namespace = "dev"
  }
}

# Generate a cluster role with specific permissions
resource "kubernetes_cluster_role" "tiller" {
    metadata {
        name = "tiller-manager"
    }
    
    rule {
        api_groups = ["", "batch", "extensions", "apps", "clusterroles"]
        resources  = ["*"]
        verbs      = ["*"]
    }
}

# Assign our new cluster role to the Tiller Service Account
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

# Some services need to be installed at a cluster level
# So we have a seperate service account in the kube-system
# namespace with cluster admin role
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
