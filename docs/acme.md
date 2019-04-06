# SSL for Azure PaaS Services

For a while now I have been looking for a nice way to handle SSL for my PaaS services in Azure, from App Gateways to Azure Functions. There are some older scripts out there and Web Jobs to do it but they didn't feel quite right, then one day I spotted the [ACME Provider](https://www.terraform.io/docs/providers/acme/index.html) for Terraform. 

If you take a look through the link above you will spot that it uses the ACME v2 API which Let's Encrypt supports, as well as a huge range of DNS providers for doing ownership challenges, it also supports PFX certificates (P12) which is what Azure still expects across all of its services, even those that aren't backed by Windows machines.

So all of this sounds great and it is and what's even better is that if you run Terraform during a window where you specify the certificate needs renewing it will do it for you (my mind was actually blown!). So let's take a look at how we get it up and running. 

The first thing we need to do is specify which acme service we would like to use, the one below is the Let's Encrypt production service, they also have a staging service for testing as well.

```
provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
  version = "~>1.1.1"
}
```

Then we need is to create an account with the Let's Encrypt API, to do this we need to generate an account key and the email address we want to register with. 

```
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

# Register with Let's Encrypt
resource "acme_registration" "aks" {
  account_key_pem = "${tls_private_key.private_key.private_key_pem}"
  email_address   = "${var.email}"
}
```

Once we have created our account we can go a head and create our new certificate, I found that the Azure services are a little hit and miss with their consistency around certificates, some expecting the certificates to padded, some not minding, some requiring passwords and others not. Luckily for us the ACME provider now outputs padded base64 encoded PFX certificates and gives us the option to specify a password. Application gateway happens to be one of the services that requires a password, by that I mean it can't be an empty string.

So let's generate a password and then request a new certificate.

You will notice the dns_challenge block, while I have set the provider to dnsimple this can be one of the many providers they support and the [list](https://www.terraform.io/docs/providers/acme/dns_providers/index.html) is big. When this is running I have noticed that it will check for a specific record to ensure ownership, which makes this whole flow insanely simple.

```
# Generate a password for our PFX certificate
resource "random_string" "certpass" {
  length = 24
  special = true
}

# Generate a certificate with Let's Encrypt that we will use 
# on the public endpoint of our Application Gateway (WAF)
resource "acme_certificate" "aks" {
  account_key_pem           = "${acme_registration.aks.account_key_pem}"
  common_name               = "${dnsimple_record.aks.hostname}"
  
  certificate_p12_password = "${random_string.certpass.result}"

  # The DNS challenge allows them to validate we own the domain by checking / creating a temporary record
  dns_challenge {
    provider = "dnsimple" # There are a lot of supported providers so you should be able to switch this to use yours.

    config {
        DNSIMPLE_OAUTH_TOKEN = "${var.dnsimple_auth_token}"
    }    
  }
}
```

Now we have our certificate we can attach it to our application gateway. Luckily this service provides a SSL block, other services it isn't so easy, with Azure Functions requiring it be stored in Key Vault then a certificate to be wrapped up. [Here is an example](https://github.com/JimPaine/emotion-checker/blob/master/env/binding.tf)

Back to our application gateway, our certificate was created for a custom domain which was added as a CNAME that pointed to the FQDN on our public IP address we have used below, also note it is also set to use port 443 and the protocol on the http_listener is case sensitive. 

```
resource "azurerm_application_gateway" "aks" {
  
  ...

  frontend_port {
    name = "https"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "pip"
    public_ip_address_id = "${azurerm_public_ip.gateway.id}"
  }

  ssl_certificate {
    name = "Cert"
    data = "${acme_certificate.aks.certificate_p12}"
    password = "${random_string.certpass.result}"
  }

  http_listener {
    name                           = "http"
    frontend_ip_configuration_name = "pip"
    frontend_port_name             = "https"
    protocol                       = "Https"
    ssl_certificate_name = "Cert"
  }

  ...

}

```