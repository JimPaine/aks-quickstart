# Terraform service principal

In this section we will create a service principal with the required permissions to provision our environment.

## Step 1 - Create Service Principal

Inside https://portal.azure.com open up your Azure Active Directory.

- Firstly under "Properties" make note of the directory ID as we will need this later, also known as the tenant ID.

Now to create a Service Principal we will actually create a new "App" by following these directions:

- Under the Azure AD click on "App registrations"

![App registration](/docs/images/appreg.png)

- Now click "New application registration"

![New App registration](/docs/images/newapp.png)

- Populate the detail in the form and hit "Create"
- You can set the sign-on URL to any valid URL as we won't need it.

![Create App registration](/docs/images/createapp.png)

- Make note of the "Application ID" as this will be used for our "client_ID" later on.

![App ID](/docs/images/appid.png)

## Step 2 - Azure AD Permissions

Once the Service Principal has been created we need to assign it some permissions on the Azure AD tenant to allow it to create other Service Principals.

- Click on "Settings"

![App Settings](/docs/images/appsettings.png)

- Now click "Required permissions"

![Required permissions](/docs/images/permissions.png)

- Then Click "Windows Azure Active Directory"

![Windows Azure Active Directory](/docs/images/windowsaad.png)

- Now we need to enable "Read and write all applications"
- Note it highlights this will need to be granted by an Admin before it is applied

![Enable access](/docs/images/enableaccess.png)

- Now grant the given permissions

![Grant access](/docs/images/grant.png)

Now your service principal to create other service principals, which is key for this demo.

## Step 3 - Keys / Password

Now we need to create a password that our service principal will use to authenticate.

- Still under settings click on "Keys"

![Keys](/docs/images/keys.png)

- Now enter a value for the description and a duration for the expiry

![Set Password](/docs/images/setpass.png)

- Click "Save" and make note of the value that is generated this will be used as our "client_secret" later.

![value](/docs/images/value.png)

## Step 4 - Azure Subscription Access

Within the Azure portal navigate to "Subscriptions" and find the subscription you wish Terraform to have access to.

- Click on "Access control (IAM)"

![IAM](/docs/images/iam.png)

- Now click on "Add a role assignment"

![Add role assignment](/docs/images/addrole.png)

- Select "Owner" for the role
- And search and select your Service Principal

![Fill form](/docs/images/fillform.png)


## Summary

You now have a Service Principal we will use for Terraform that has access to Azure AD to create other Service Principals as well as access to an Azure Subscription to provision the environment in.

You should also have made not of the following which we will use later.

- Application ID
- Directory ID
- Key Password Value
