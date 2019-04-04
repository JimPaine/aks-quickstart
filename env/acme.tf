resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "aks" {
  account_key_pem = "${tls_private_key.private_key.private_key_pem}"
  email_address   = "${var.email}"
}

resource "random_string" "certpass" {
  length = 24
  special = true
}

resource "acme_certificate" "aks" {
  account_key_pem           = "${acme_registration.aks.account_key_pem}"
  common_name               = "${dnsimple_record.aks.hostname}"
  
  certificate_p12_password = "${random_string.certpass.result}"

  dns_challenge {
    provider = "dnsimple"

    config {
        DNSIMPLE_OAUTH_TOKEN = "${var.dnsimple_auth_token}"
    }    
  }
}
