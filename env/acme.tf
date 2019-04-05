# Generate a key we will use to register an account with Let's Encrypt
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

# Register with Let's Encrypt
resource "acme_registration" "aks" {
  account_key_pem = "${tls_private_key.private_key.private_key_pem}"
  email_address   = "${var.email}"
}

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

  # The DNS challenge allows them to validate we own the domain by checking / creating a tempary record
  dns_challenge {
    provider = "dnsimple" # There are a lot of supported providers so you should be able to switch this to use yours.

    config {
        DNSIMPLE_OAUTH_TOKEN = "${var.dnsimple_auth_token}"
    }    
  }
}
