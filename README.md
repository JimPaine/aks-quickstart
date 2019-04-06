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
- [Demo App](https://aks.jim.cloud/values/swagger)
    - [yaml](/apps/deployment.yaml)


## Backlog

- Switch to use Nginx (Used by more customers)
- Include Pod Identity
- Once Pod Identity is included switch to use App Gateway as ingress controller
- Azure AD SPs for Container Registry RBAC. Reader for cluster and Contributor for DevOps Pipeline
- Dev Spaces
- Policies
- Move Service Principal role assignment to Subnet rather than the whole Resource Group

## Learnings

- [RBAC](/docs/rbac.md)
- Private IP
    - Role Assignment
    - Service Annotations
    - Link to IP limit details
- [SSL With ACME & Let's Encrypt](/docs/acme.md)

## Get up and running

Start by cloning or forking this repository, we will then setup Terraform with a Service Principal and a remote storage account, so we can automate the provisioning of the environment.

### Steps

- [1. Terraform Service Principal](/docs/TerraformSP.md)
- [2. Terraform State](/docs/TerraformState.md)
- [3. Azure DevOps Pipelines](/docs/AzurePipeline.md)
