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
  name                = "RK-vault2"  # Replace with the name of your Key Vault
  resource_group_name = var.resource_group_name
}

# Create the Azure Key Vault if it doesn't exist
resource "azurerm_key_vault" "create" {
  count               = length(data.azurerm_key_vault.existing) > 0 ? 0 : 1
  name                = "RK-vault2"  # Replace with the name of your Key Vault
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = "9a0b7dd4-2e84-4ea4-8e61-ccb1fe3dc746"  # Replace with your tenant_id
  sku_name            = "standard"
  enabled_for_deployment = true
  enabled_for_disk_encryption = true
  enabled_for_template_deployment = true
}

# Create the Azure Key Vault secrets if it exists
resource "azurerm_key_vault_secret" "admin-username" {
  count = length(data.azurerm_key_vault.existing) > 0 ? 1 : 0
  name         = "admin-username"
  key_vault_id = data.azurerm_key_vault.existing.id
  value        = "rishik"  # Replace with the actual value
}

resource "azurerm_key_vault_secret" "admin-password" {
  count = length(data.azurerm_key_vault.existing) > 0 ? 1 : 0
  name         = "admin-password"
  key_vault_id = data.azurerm_key_vault.existing.id
  value        = "Temp@1234"  # Replace with the actual value
}

# Separate the output values
output "tenant_id" {
  value = length(data.azurerm_key_vault.existing) > 0 ? data.azurerm_key_vault.existing.tenant_id : null
}

output "admin_username" {
  value = length(data.azurerm_key_vault.existing) > 0 ? azurerm_key_vault_secret.admin-username[0].value : null
}

output "admin_password" {
  value = length(data.azurerm_key_vault.existing) > 0 ? azurerm_key_vault_secret.admin-password[0].value : null
}
