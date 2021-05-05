terraform {
  backend "azurerm" {
    resource_group_name  = "tedopstfstates"
    storage_account_name = "tedopstf"
    container_name       = "tfstatedevops"
    key                  = "terraformgithubexample.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x.
  # If you're using version 1.x, the "features" block is not allowed.
  features {}
}

data "azurerm_client_config" "current" {}

#Create Resource Group
resource "azurerm_resource_group" "main" {
  name     = "tedops"
  location = "eastus2"
}

resource "azurerm_virtual_network" "main" {
  name                = "tedops-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "tedops-pip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Dynamic"
  domain_name_label   = "automationdemo-tedops"
  reverse_fqdn        = "automationdemo-tedops.eastus2.cloudapp.azure.com."
}

resource "azurerm_network_interface" "main" {
  name                = "tedops-nic1"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface" "internal" {
  name                = "tedops-nic2"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "k3sserver" {
  name                = "ingress_k3sserver"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "https"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "443"
    destination_address_prefix = azurerm_network_interface.main.private_ip_address
  }
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "http"
    priority                   = 101
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "80"
    destination_address_prefix = azurerm_network_interface.main.private_ip_address
  }
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.internal.id
  network_security_group_id = azurerm_network_security_group.k3sserver.id
}

resource "azurerm_managed_disk" "master" {
  name                 = tedops-data
  resource_group_name  = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
}

resource "azurerm_virtual_machine_data_disk_attachment" "master" {
  managed_disk_id    = azurerm_managed_disk.master.id
  virtual_machine_id = azurerm_linux_virtual_machine.main.id
  lun                = "10"
  caching            = "ReadWrite"
}

data "template_file" "master-cloud-init" {
  template = file("../scripts/master-cloud-init.txt")
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = "tedops-vm"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  custom_data         = base64encode(data.template_file.master-cloud-init.rendered)

  network_interface_ids = [
    azurerm_network_interface.main.id,
    azurerm_network_interface.internal.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("/github/workspace/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}

output "public_ip" {
  value = azurerm_linux_virtual_machine.main.public_ip_address
}

output "utility_ip" {
  value = azurerm_linux_virtual_machine.main.private_ip_address
}

output "fqdn" {
  value = azurerm_public_ip.pip.fqdn
}