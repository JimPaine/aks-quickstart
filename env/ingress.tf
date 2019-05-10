resource "helm_release" "nginx" {
    depends_on = ["azurerm_role_assignment.aks"]

    name      = "nginx"
    chart     = "stable/nginx-ingress"

    namespace = "dev"

    # The annotations here are key, for any service you would like exposed outside
    # of the cluster on a private IP need the annotation telling Kubernetes to use an
    # internal Azure load balancer. This is why we gave the service prinicipal network
    # permissions so that it can create a new instance of a load balancer.
    values = [<<VALUES
      controller:
        stats:
          enabled: "true"
        metrics:
          enabled: "true"
        service:
          loadBalancerIP: 10.2.1.254
          annotations:
            service.beta.kubernetes.io/azure-load-balancer-internal: "true"
      rbac: "true"
    VALUES
    ]
}
