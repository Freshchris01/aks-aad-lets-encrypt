resource "azurerm_dns_zone" "app" {
  name                = "fs557.org"
  resource_group_name = var.rg-name
}


resource "azurerm_dns_cname_record" "example" {
  name                = "www"
  zone_name           = azurerm_dns_zone.app.name
  resource_group_name = var.rg-name
  ttl                 = 300
  record              = "lb-373ea02e-cddf-473d-ba08-b56d5358f5ac.westeurope.cloudapp.azure.com"
}