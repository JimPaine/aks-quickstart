#Azure DevOps Pipeline

## Variable Groups

Create the two variable groups in Azure Dev Ops as described below

### Terraform client

| Name          | Value                                       |
| ------------- | ------------------------------------------- |
| client_id     | The app Id from the previous step           |
| client_secret | The password created from the previous step |
| tenant_id     | The Azure AD tenant ID                      |

### State storage

| Name                       | Value                                                    |
| -------------------------- | -------------------------------------------------------- |
| tfstate_resource_group     | The resource group where you created the storage account |
| tfstate_storage_account    | The name of the storage account                          |
| tfstate_container          | The name of the BLOB container                           |

## Pipeline variables

| Name                | Value                                                               |
| ------------------- | ------------------------------------------------------------------- |
| subscription_id     | The id of the subscription you want to deploy to                    |
| domain              | The existing domain you want to add a CNAME record to eg. jim.cloud |
| email               | An email address used to create an ACME Let's Encrypt account       |
| dnsimple_account    | The account number for the dnsimple account to use.                 |
| dnsimple_auth_token | The auth token for access to the dnsimple account                   |