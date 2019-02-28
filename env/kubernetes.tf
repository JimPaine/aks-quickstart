resource "kubernetes_namespace" "dev" {
  metadata {
    name = "dev"
  }
}

locals {
  dockercfg = {
    "${azurerm_container_registry.demo.login_server}" = {
      email    = "notneeded@notneeded.com"
      username = "${azurerm_container_registry.demo.admin_username}"
      password = "${azurerm_container_registry.demo.admin_password}"
    }
  }
}

resource "kubernetes_secret" "demo" {
  metadata {
    name      = "registry"
    namespace = "dev"
  }

  # terraform states this is a map of the variables here, it actual wants a structured json object
  # https://github.com/terraform-providers/terraform-provider-kubernetes/issues/81
  data {
    ".dockercfg" = "${ jsonencode(local.dockercfg) }"
  }

  type = "kubernetes.io/dockercfg"
}

#kubectl create clusterrolebinding kubernetes-dashboard -n kube-system --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard

resource "kubernetes_cluster_role_binding" "admindashboard" {
    metadata {
        name = "kubernetes-dashboard"
    }
    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind = "ClusterRole"
        name = "cluster-admin"
    }
    subject {
        kind = "ServiceAccount"
        name = "kubernetes-dashboard"
        namespace = "kube-system"
        api_group = ""
    }
}