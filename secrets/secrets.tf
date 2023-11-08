provider "azurerm" {
  features {}
}

# Declare the input variables
variable "location" {
  description = "The location of the Azure Key Vault"
}

variable "resource_group_name" {
  description = "The name of the Azure Resource Group where the Key Vault should be created"
}

# Check if the Azure Key Vault exists
data "azurerm_key_vault" "existing" {
  name                = "RK-vault1"  # Replace with the name of your Key Vault
  resource_group_name = var.resource_group_name
}

# Create the Azure Key Vault secrets if it exists
resource "azurerm_key_vault_secret" "admin-username" {
  count = length(keys(data.azurerm_key_vault.existing)) > 0 ? 1 : 0
  name         = "admin-username"
  key_vault_id = data.azurerm_key_vault.existing.id
  value        = "rishik"  # Replace with the actual value
}

resource "azurerm_key_vault_secret" "admin-password" {
  count = length(keys(data.azurerm_key_vault.existing)) > 0 ? 1 : 0
  name         = "admin-password"
  key_vault_id = data.azurerm_key_vault.existing.id
  value        = "Temp@1234"  # Replace with the actual value
}

# Separate the output values
output "tenant_id" {
  value = length(keys(data.azurerm_key_vault.existing)) > 0 ? data.azurerm_key_vault.existing.tenant_id : null
}

output "admin_username" {
  value = tostring(azurerm_key_vault_secret.admin-username[*].value)
}

output "admin_password" {
  value = tostring(azurerm_key_vault_secret.admin-password[*].value)
}

