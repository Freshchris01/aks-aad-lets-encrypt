resource "azurerm_dns_zone" "app" {
  name                = var.domain_name
  resource_group_name = var.rg_name
}


resource "azurerm_dns_cname_record" "example" {
  name                = "www"
  zone_name           = azurerm_dns_zone.app.name
  resource_group_name = var.rg_name
  ttl                 = 300
  record              = "lb-373ea02e-cddf-473d-ba08-b56d5358f5ac.westeurope.cloudapp.azure.com"
}

resource "azurerm_user_assigned_identity" "cert_identity" {
  location            = var.location
  name                = "cert-identity"
  resource_group_name = var.rg_name
}

resource "azurerm_role_assignment" "cert_assignment" {
	scope = azurerm_dns_zone.app.id
	role_definition_name = "DNS Zone Contributor"
	principal_id         = azurerm_user_assigned_identity.cert_identity.principal_id
}