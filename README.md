# AKS real world quick start

This quick start is aimed to take the provisioning of AKS beyond a simple "az aks create" command and to include the minimum that most of my customers have required for a production workload. I am also working on a different deployment model for AKS to sit in a hub and spoke architecure and will update with a link to the repository when it is complete. This example already includes a range of useful features which should help most people move forward with producing a production like environment.

![architecture](/docs/images/arch.PNG)

[![Build Status](https://dev.azure.com/jimpaine-msft/github%20pipelines/_apis/build/status/JimPaine.aks-quickstart?branchName=master)](https://dev.azure.com/jimpaine-msft/github%20pipelines/_apis/build/status/JimPaine.aks-quickstart?branchName=master)

## Current features

- RBAC cluster
- Helm and Tiller included in the cluster
    - Tiller per namespace with relevant Service Account and role bindings
- Generation of SSH keys
- Traefik for ingress
- Cluster on a dedicated VNet
- Created Service Principal for cluster nodes
- Service Principal assigned as Network Contributor with Resource Group
- Application Gateway V2 with WAF in front of Traefik
- Custom domain on App Gateway
- Creation and assignment of DNS record
- Creation and assignment of Let's Encrypt certificate to App Gateway
- Monitoring solutions installed
    - Prometheus
    - Grafana
    - Container Insights through Azure Monitor



## Backlog

- Switch to use Nginx (Used by more customers)
- Include Pod Identity
- Once Pod Identity is included switch to use App Gateway as ingress controller
- Demo apps
- Azure AD SPs for Container Registry RBAC. Reader for cluster and Contributor for DevOps Pipeline
- Dev Spaces
- Policies
- Move Service Principal role assignment to Subnet rather than the whole Resource Group

## To run

Start by cloning or forking this repository.

### Terraform Service Principal

### Storage account for Terraform State

### Variable Groups

Create the two variable groups in Azure Dev Ops as described below

#### Terraform client

| Name          | Value                                       |
| ------------- | ------------------------------------------- |
| client_id     | The app Id from the previous step           |
| client_secret | The password created from the previous step |
| tenant_id     | The Azure AD tenant ID                      |

#### State storage

| Name                       | Value                                                    |
| -------------------------- | -------------------------------------------------------- |
| tfstate_resource_group     | The resource group where you created the storage account |
| tfstate_storage_account    | The name of the storage account                          |
| tfstate_container          | The name of the BLOB container                           |

### Pipeline variables

| Name                | Value                                                               |
| ------------------- | ------------------------------------------------------------------- |
| subscription_id     | The id of the subscription you want to deploy to                    |
| domain              | The existing domain you want to add a CNAME record to eg. jim.cloud |
| email               | An email address used to create an ACME Let's Encrypt account       |
| dnsimple_account    | The account number for the dnsimple account to use.                 |
| dnsimple_auth_token | The auth token for access to the dnsimple account                   |
