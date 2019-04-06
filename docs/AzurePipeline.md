# Azure DevOps Pipeline

## Variable Groups

Create the two variable groups in Azure Dev Ops as described below, we have these defined directly in the pipeline rather than the azure-pipeline.yml file because these are sensitive and we obviously don't want them stored in GitHub :)

To create the variables groups follow these steps:

- Once you are in an Azure DevOps project click through to "Library"

![Library](/docs/images/library.png)

- Now click "+ Variable Group"

![New Group](/docs/images/newgroup.png)

- Populate the group as detailed below, ensuring the group name and the variable names match.

![Group](/docs/images/group.png)

### Terraform client

- Group Name "Terraform Service Prinicpal (AAD Sandbox)"

Feel free to change the group name, but make sure you also change it in the azure-pipeline.yml file as well.

| Name          | Value                                       |
| ------------- | ------------------------------------------- |
| client_id     | The app Id from the previous step           |
| client_secret | The password created from the previous step |
| tenant_id     | The Azure AD tenant ID                      |

### State storage

Follow the steps above again for this second variable group.

- Group Name "Terraform State", again feel free to change this name but ensure you change the azure-pipeline.yml file as well.

| Name                       | Value                                                    |
| -------------------------- | -------------------------------------------------------- |
| tfstate_resource_group     | The resource group where you created the storage account |
| tfstate_storage_account    | The name of the storage account                          |
| tfstate_container          | The name of the BLOB container                           |


## Create the pipeline

Now we have the core variables all defined we can start by creating the Azure DevOps Pipeline, if you aren't using Azure DevOps then feel free to grab the Terraform commands out of the "azure-pipelines.yml" file and run them in your preferred tool.

- Start by going to Pipelines > Builds

![Builds](/docs/images/build.png)

- Then "New Pipeline"

![new build](/docs/images/newbuild.png)

- Select the repository the source is stored in, for me this is GitHub.

![GitHub repo](/docs/images/github.png)

![Repo](/docs/images/repo.png)

- This will now automatically load the azure-pipelines.yml
- You will need to click Run and then cancel, this sounds crazy but at this stage it doesn't give us the option to add pipeline variables or link the groups we have already created.

![Run and cancel](/docs/images/run.png)

- Now under the list of build pipelines make sure your new one is selected and click "Edit"

![Edit](/docs/images/edit.png)

- You can then select the 3 dots and then variables and add the variables detailed below.

![variables](/docs/images/dots.png)

### Pipeline variables

This is based on the assumption you are also using DNSimple for DNS, if you are using a different provider please look at the Terraform Provider documentation for specifics to your provider.

| Name                | Value                                                               |
| ------------------- | ------------------------------------------------------------------- |
| subscription_id     | The id of the subscription you want to deploy to                    |
| domain              | The existing domain you want to add a CNAME record to eg. jim.cloud |
| email               | An email address used to create an ACME Let's Encrypt account       |
| dnsimple_account    | The account number for the dnsimple account to use.                 |
| dnsimple_auth_token | The auth token for access to the dnsimple account                   |

Once you have added these click "Save and Queue" and it should build out the entire environment for you.
