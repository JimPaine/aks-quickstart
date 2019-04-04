resource "helm_release" "traefik" {
    depends_on = ["azurerm_role_assignment.aks"]

    name      = "traefik"
    chart     = "stable/traefik"

    namespace = "dev"

    set {
        name = "loadBalancerIP"
        value = "10.2.1.254"
    }

    values = [<<VALUES
        service:
          annotations:
            service.beta.kubernetes.io/azure-load-balancer-internal: "true"
        rbac:
          enabled: true
        dashboard:
          enabled: true
          domain: ${dnsimple_record.aks.hostname}
          serviceType: LoadBalancer
          service:
          annotations:
            service.beta.kubernetes.io/azure-load-balancer-internal: "true"
    VALUES
    ]
}
