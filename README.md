# aks-quickstart

Currently under a massive re-write

[![Build Status](https://dev.azure.com/jimpaine-msft/github%20pipelines/_apis/build/status/JimPaine.aks-quickstart?branchName=master)](https://dev.azure.com/jimpaine-msft/github%20pipelines/_apis/build/status/JimPaine.aks-quickstart?branchName=master)

Currently includes
- RBAC Cluster
- Includes Advanced Networking using CNI, allowing external cluster IPs to be private and on a local vnet
- Service Account for Helm and Tiller with custom roles and bindings
    - With namespace specific instances
- Generation of SSH Keys
- No dashboard access
- Traefik for Ingress
- Application Gateway v2 with WAF on custom domain and SSL https://aks.jim.cloud

TODO
- Demo apps
- Azure AD SPs for Container Registry RBAC. Reader for cluster and Contributer for DevOps Pipeline
- Dev Spaces
- Pod Identity
- Pictures
- Documentation
