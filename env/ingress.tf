resource "helm_release" "traefik" {
    depends_on = ["azurerm_role_assignment.aks"]

    name      = "traefik"
    chart     = "stable/traefik"

    namespace = "dev"

    # Assign a private IP for Traefik
    # The IP needs to be from the subnet that AKS is sitting on.
    set {
        name = "loadBalancerIP"
        value = "10.2.1.254"
    }

    # The annotations here are key, for any service you would like exposed outside
    # of the cluster on a private IP need the annotation telling Kubernetes to use an
    # internal Azure load balancer. This is why we gave the service prinicipal network
    # permissions so that it can create a new instance of a load balancer.
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
