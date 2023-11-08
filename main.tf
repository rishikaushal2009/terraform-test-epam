# Specify the Azure provider and enable features
provider "azurerm" {
  features {}
}

# Create the Azure Resource Group
resource "azurerm_resource_group" "my_rg" {
  name     = "amdemo"
  location = "South India"  # Corrected the location
}

# Define the secrets module
module "secrets" {
  source    = "./secrets"
  location  = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name
}

# Create the Azure Virtual Network and Subnet
resource "azurerm_virtual_network" "my_vnet" {
  name                = "amdemo-network"
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "my_subnet" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.my_rg.name
  virtual_network_name = azurerm_virtual_network.my_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create the Azure Public IP
resource "azurerm_public_ip" "my_public_ip" {
  name                = "example-publicip"
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name
  allocation_method   = "Static"
}

# Create the Azure Network Interface
resource "azurerm_network_interface" "my_network_interface" {
  name                = "example-nic"
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.my_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id           = azurerm_public_ip.my_public_ip.id
  }
}

# Create the Azure Virtual Machine
resource "azurerm_virtual_machine" "my_vm" {
  name                  = "my-vm"
  location              = azurerm_resource_group.my_rg.location
  resource_group_name   = azurerm_resource_group.my_rg.name
  network_interface_ids = [azurerm_network_interface.my_network_interface.id]
  vm_size               = "Standard_DS2_v2"

  storage_os_disk {
    name              = "example-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "my-vm"
    admin_username = module.secrets.admin_username
    admin_password = module.secrets.admin_password
  }

  # Copy a local script to the VM
  os_profile {
    custom_data = base64encode(file("userdata/bootstrap.sh"))
  }
}

# Create the Azure Virtual Machine Extension for Custom Script
resource "azurerm_virtual_machine_extension" "custom_script" {
  name                 = "custom_script"
  virtual_machine_id   = azurerm_virtual_machine.my_vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
    {
      "script": "sudo /tmp/bootstrap.sh"
    }
  SETTINGS
}
