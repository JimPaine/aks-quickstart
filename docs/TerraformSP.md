# Terraform service principal

In this section we will create a service principal with the required permissions to provision our environment.

## Step 1 - Create Service Principal

Inside https://portal.azure.com open up your Azure Active Directory.

- Firstly under "Properties" make note of the directory ID as we will need this later, also known as the tenant ID.

Now to create a Service Principal we will actually create a new "App" by following these directions:

- Under the Azure AD click on "App registrations"

![App registration](images/appreg.PNG)

- Now click "New application registration"

![New App registration](images/newapp.PNG)

- Populate the detail in the form and hit "Create"
- You can set the sign-on URL to any valid URL as we won't need it.

![Create App registration](images/createapp.PNG)

- Make note of the "Application ID" as this will be used for our "client_ID" later on.

![App ID](images/appid.PNG)

## Step 2 - Azure AD Permissions

Once the Service Principal has been created we need to assign it some permissions on the Azure AD tenant to allow it to create other Service Principals.

- Click on "Settings"

![App Settings](images/appsettings.PNG)

- Now click "Required permissions"

![Required permissions](images/permissions.PNG)

- Then Click "Windows Azure Active Directory"

![Windows Azure Active Directory](images/windowsaad.PNG)

- Now we need to enable "Read and write all applications"
- Note it highlights this will need to be granted by an Admin before it is applied

![Enable access](images/enableaccess.PNG)

- Now grant the given permissions

![Grant access](images/grant.PNG)

Now your service principal to create other service principals, which is key for this demo.

## Step 3 - Keys / Password

Now we need to create a password that our service principal will use to authenticate.

- Still under settings click on "Keys"

![Keys](images/keys.PNG)

- Now enter a value for the description and a duration for the expiry

![Set Password](images/setpass.PNG)

- Click "Save" and make note of the value that is generated this will be used as our "client_secret" later.

![value](images/value.PNG)

## Step 4 - Azure Subscription Access

Within the Azure portal navigate to "Subscriptions" and find the subscription you wish Terraform to have access to.

- Click on "Access control (IAM)"

![IAM](images/iam.PNG)

- Now click on "Add a role assignment"

![Add role assignment](images/addrole.PNG)

- Select "Owner" for the role
- And search and select your Service Principal

![Fill form](images/fillform.PNG)


## Summary

You now have a Service Principal we will use for Terraform that has access to Azure AD to create other Service Principals as well as access to an Azure Subscription to provision the environment in.

You should also have made not of the following which we will use later.

- Application ID
- Directory ID
- Key Password Value