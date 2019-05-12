resource "helm_release" "keda" {
    depends_on = ["azurerm_role_assignment.aks"]

    name      = "keda"
    chart     = "kedacore/keda-edge"

    namespace = "keda"

    devel = "true"

    set {
        name = "logLevel"
        value = "debug"
    }

}