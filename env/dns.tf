resource "dnsimple_record" "aks" {
  domain = "${var.domain}"
  name   = "aks"
  value  = "${azurerm_public_ip.gateway.fqdn}"
  type   = "CNAME"
  ttl    = 3600

  provisioner "local-exec" {
    command = "sleep 30s"
  }
}