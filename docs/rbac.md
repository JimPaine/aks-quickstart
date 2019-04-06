# RBAC Learnings

Straight out the gate I wanted to have everything as locked down as I could by default. So with this in mind I started by trying to use the Azure AD integration for AKS RBAC enabled clusters. Getting it up and running was actually really easy, all I needed was to follow this [guide](https://docs.microsoft.com/en-us/azure/aks/aad-integration) to create the account then add the following:

```
resource "azurerm_kubernetes_cluster" "example" {

    ...

    role_based_access_control {
        enabled = true

        azure_active_directory {
            client_app_id = ""
            server_app_id = ""
            server_app_secret = ""
            tenant_id = ""
        }
    }
}

```

| Name              | What it is                                                |
| ----------------- | --------------------------------------------------------- |
| client_app_id     | The id of the client that is consuming the Kubernetes API | 
| server_app_id     | The id of the app that represents Kubernetes              |
| server_app_secret | The secret for the Kubernetes Service Principal           |
| tenant_id         | The Directory ID where the Service Principals live        |

So all great right? No, no not great, because the only flow that the Azure AD RBAC implementation actually supports it a user flow. Which is alright if you have users interacting directly with your cluster through the cli or the dashboard. But if you want to automate any flows like running an apply for a deployment from a DevOps Pipeline then you have to revert back to using the Admin credentials from the kubeconfig.

This might work for you, but I am waiting on [this user voice](https://feedback.azure.com/forums/914020-azure-kubernetes-service-aks/suggestions/35146387-support-non-interactive-login-for-aad-integrated-c) to be implemented before I switch over.

So with that in mind I am using the native Service Accounts and Roles from within Kubernetes.

## Implementing RBAC via Terraform

- Create a Service Account

This one is an easy one, pick and name and a namespace we want the service account to be in. In this demo we create a service account per namespace for tiller, while this might be overkill the idea is that I can have different credentials for deploying into my namespaces, not that I would do this in production, but lets say I had a shared cluster for Dev and Production by having two service accounts I can ensure that there is no accidental deployments between environments.

```
resource "kubernetes_service_account" "demo" {
  metadata {
    name = "serviceAccountName"
    namespace = "namespace"
  }
}
```

- Custom Role

Now we have the option to create a custom role for our service account, the example below is what is shown on the official documentation (at the time of writing) states is needed for Tiller. What is key to note here is the level of granularity we can go with the role. [This doc](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#default-roles-and-role-bindings) is a great document for showing the options around customising roles as well as the built in roles.

```
resource "kubernetes_cluster_role" "demo" {
    metadata {
        name = "roleName"
    }

    rule {
        api_groups = ["", "batch", "extensions", "apps"]
        resources  = ["*"]
        verbs      = ["*"]
    }
}
```

- Assign the role to the user

Now we have the Service Account and the custom role we can assign the role to our service account, simply by changing the role_ref.name and subject.name you should also match the namespace to the namespace of the service account if you have limited this. At the time of writing I had to set subject.api_group to an empty string for the Terraform Apply to succeed.

```
resource "kubernetes_cluster_role_binding" "demo" {
    metadata {
        name = "bindingName"
    }
    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind = "ClusterRole"
        name = "roleName"
    }
    subject {
        kind = "ServiceAccount"
        name = "serviceAccountName"
        namespace = "namespace"
        api_group = ""
    }
}
```

## Using the Service Account

Now we have our Service account with its assigned custom role we need to create a kubeconfig for this specific account, unfortunately this isn't something I could find a simple way to achieve, I had to hand crank my own file, these links came in handy and I won't attempt to re-write them here.

- [Create kubeconfig for specific service account](https://stackoverflow.com/questions/47770676/how-to-create-a-kubectl-config-file-for-serviceaccount)
- [Creating a kubeconfig for a self hosted cluster](http://docs.shippable.com/deploy/tutorial/create-kubeconfig-for-self-hosted-kubernetes-cluster/)