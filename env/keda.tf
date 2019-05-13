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

resource "helm_release" "osiris" {
    depends_on = ["azurerm_role_assignment.aks"]

    name      = "osiris"
    chart     = "osiris/osiris-edge"

    namespace = "keda"

    devel = "true"
}