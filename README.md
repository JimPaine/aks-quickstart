# aks-quickstart

Using this repo and a combination of steps in VSTS you can automate the process of creating an AKS cluster, with a private Azure Container Registry, Helm / Teller, Azure Key Vault and all the identities, ssh keys and secrets generated at build time.

## Environment Architecture

![architecture](https://raw.githubusercontent.com/JimPaine/images/master/architecture.PNG)

## Step 1 - Create a Service Principal and set permissions

This will be used to run the Terraform client which will provision the resources in the required environment.

Go into the Azure portal, select Azure Active Directory and then App Registrations.

Create a new application and make note of the application id, sign-on URL can be http://localhost

![newapp](https://raw.githubusercontent.com/JimPaine/images/master/newapp.PNG)

Open the application, click settings, keys and create a new password and make note of it

![secret](https://raw.githubusercontent.com/JimPaine/images/master/secret.PNG)

Then select Required permissions and match the image below

![permissions](https://raw.githubusercontent.com/JimPaine/images/master/permissions.PNG)

Still on the Required permissions pane click grant permissions (You will need to be an admin for this). These permissions are needed to create a Service Principal that will be used by AKS.

![grant](https://raw.githubusercontent.com/JimPaine/images/master/grant.PNG)

Go back to the Overview pane of Active directory, select properties and make note of the Directory ID (Also know as the tenant ID).

### Enusre access to create permissions on the subscription

You will also need to update the subscription to give the new Service Principcal access to create resources. In the portal go to subscriptions -> Access Control (IAM)

## Step 2 - Fork or clone this GitHub repo

## Step 3 - Build pipeline

Create a new pipeline
Select your GitHub repo as the source
Continue
Start with an Empty Process rather than an existing template.
Add a Copy files task and configure like below:

![copytask](https://raw.githubusercontent.com/JimPaine/images/master/copytask.PNG)

Add a publish task and configure like so:

![publish](https://raw.githubusercontent.com/JimPaine/images/master/publish.PNG)

Click on Process and change the Agent to Hosted Ubtuntu 1604

Under triggers - configure as desired.
Rename and save.

## Step 4 - Release pipeline

This is where the fun happens! While VSTS is great and has loads of great integrations into Azure, that doesn't help us when the environment doesn't even exist yet :) Hence the fun!

- Under releases create a new pipeline
- Start with an empty process, instead of an existing template
- Under add artifact select select build, then the project and then the source build

![artifact](https://raw.githubusercontent.com/JimPaine/images/master/artifact.PNG)

Next we are going to intialize the environment and for this we need to create a bunch of variables to use within our script, so under variables create the following using the values you captured at the start of the process:

| Name            | Value                              | Secret   |
| --------------- |:----------------------------------:| --------:|
| client_id       | {application id}                   | No       |
| client_secret   | {application password}             | Yes      |
| resource_name   | aksdemo                            | No       |
| subscription_id | {subscription id}                  | No       |
| tenant_id       | {tenant / directory id}            | No       |

Then in tasks add another command line task and set the display name to "Initialize environment" and paste in the script below:

```
ssh-keygen -t rsa -C "email@email.com" -N "somepassphrase" -f id_rsa
public_key=$(<id_rsa.pub)
private_key=$(<id_rsa)

terraform init

terraform apply -auto-approve \
    -var "subscription_id=$(subscription_id)" \
    -var "resource_name=$(resource_name)" \
    -var "client_id=$(client_id)" \
    -var "client_secret=$(client_secret)" \
    -var "tenant_id=$(tenant_id)" \
    -var "public_key=$public_key" \
    -var "private_key=$private_key"
```

Setting the working directory to the lowest directory of the build artifact

This is a slightly tweaked version of the script from [here](https://github.com/JimPaine/aks-quickstart/blob/master/scripts/run.sh) which is basically doing the same as the release pipeline but targeting local users / dev use.

Now Trigger a build and watch the magic happen

While that is happening, lets run through what we actually have

## Some of that looks a little funky, what is it actually doing?

First we are creating an sshkey for our linux VMs within the cluster, while this is great for a demo I'd recommended generating these before and pulling them from an organisation shared key vault. The public and private keys are injected in and as well as being used for the VMs are also placed in a newly generated Azure Key Vault.

```
ssh-keygen -t rsa -C "email@email.com" -N "somepassphrase" -f id_rsa
public_key=$(<id_rsa.pub)
private_key=$(<id_rsa)
```

## Next steps

- Tweak so Terraform uses remotestate so we can modify and re-run on changes
- Generate ssh keys and work with them in a slightly nicer way