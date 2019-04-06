# Terraform State

When running Terraform it will by default store the state in a file in the location you execute terraform from. While this is great for ad-hoc workloads it isn't great when working with other people who all need to have access to a shared state file, or when you use the hosted Azure agents that get torn down each time they are used. 

So to work round this we can use what Terraform refers to as a "backend" you will see in the example below, which is actually from backend.tf I have commented out the properties and their values because these are actually set from our pipeline.

## Important

It should be noted that the state file contains sensitive information, including keys so it is recommended you follow the best practices detailed by Hashicorp and Microsoft for locking down access to this file. In blob storage this would include

- Making sure the BLOB container is set for private access only
- Where possible setting firewall and network rules on the storage account.

```
terraform {
  backend "azurerm" {
    #example properties
    #resource_group_name  = ""
    #storage_account_name = ""
    #container_name       = ""
    #key                  = ""
    #access_key           = ""
  }
}
```

The init block for terraform using the backend and the remote storage to run the first and further runs of the apply and plan commands.

```
  terraform init \
       -backend-config="resource_group_name=$(tfstate_resource_group)" \
       -backend-config="storage_account_name=$(tfstate_storage_account)" \
       -backend-config="container_name=$(tfstate_container)" \
       -backend-config="key=$(tfstate_key)" \
       -backend-config="access_key=$(tfstate_access_key)"
```

So this is the concepts of it covered, seeing that I am using the AzureRM backend lets go a head and create a storage account we can use to store the state.

## Blob storage account

To create the blow storage account follow these steps making sure you capture the following details:

- Resource Group Name
- Storage Account Name
- BLOB container name
- Storage Account Key

- Start by searching for and creating a new storage account

![new storage](/docs/images/newstorage.png)

- Populate the details, capturing the ones mentioned above.

![storage details](/docs/images/storagedetails.png)

- Capture the storage access key

![storage key](/docs/images/storekeys.png)

- Create a new blob container

![new container](/docs/images/container.png)