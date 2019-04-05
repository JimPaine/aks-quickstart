resource "dnsimple_record" "aks" {
  domain = "${var.domain}"
  name   = "aks"
  value  = "${azurerm_public_ip.gateway.fqdn}"
  type   = "CNAME"
  ttl    = 3600

  # This is horrid, but from test runs I believe the DNSimple API is running as an async call
  # so even when the record returns complete if you try to check it to soon after it fails
  # and a re-run of Terraform would be required.
  provisioner "local-exec" {
    command = "sleep 30s"
  }
}