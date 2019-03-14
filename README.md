# aks-quickstart

Currently under a massive re-write

[![Build Status](https://dev.azure.com/jimpaine-msft/github%20pipelines/_apis/build/status/JimPaine.aks-quickstart?branchName=master)](https://dev.azure.com/jimpaine-msft/github%20pipelines/_apis/build/status/JimPaine.aks-quickstart?branchName=master)

Currently includes
- RBAC Cluster
- Includes Advanced Networking, allowing external cluster IPs to be private and on a local vnet
- SA for Helm and Tiller with custom roles and bindings
- Generation of SSH Keys
- Dashboard rol binding for demo ressons

To Add:
- Istio
- Monitoring
- Demo apps
- Azure AD SPs for Container Registry RBAC. Reader for cluster and Contributer for DevOps Pipeline
- Dev Spaces
- Pod Identity

## Environment Architecture

![architecture](https://raw.githubusercontent.com/JimPaine/images/master/architecture.PNG)
