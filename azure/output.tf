output "parent_id" {
	value = azurerm_user_assigned_identity.cert_identity.id
}

output "identity_client_id" {
	value = azurerm_user_assigned_identity.cert_identity.client_id
}