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
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.vnet_name}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "internal" {
  name                 = var.vnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
  domain_name_label   = var.domainname
  reverse_fqdn        = "${var.domainname}.${var.location}.cloudapp.azure.com."
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}-nic-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = var.tags
  count               = "3"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "k3sserver" {
  name                = "ingress_k3sserver"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
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

data "template_file" "master-cloud-init" {
  template = file("../scripts/master-cloud-init.txt")
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "${var.vm_name}-vm-1"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_B2s"
  network_interface_ids           = azurerm_network_interface.nic.1.id
  admin_username                  = "adminuser"
  custom_data                     = base64encode(data.template_file.master-cloud-init.rendered)

  os_disk {
    name                 = "osdisk-1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  resource "azurerm_managed_disk" "managed_disk" {
    name                 = datadisk-1
    location             = azurerm_resource_group.rg.location
    resource_group_name  = azurerm_resource_group.rg.name
    storage_account_type = "Standard_LRS"
    create_option        = "Empty"
    disk_size_gb         = 10
    tags                 = var.tags
  }

  resource "azurerm_virtual_machine_data_disk_attachment" "managed_disk_attach" {
    managed_disk_id    = azurerm_managed_disk.managed_disk.1.id
    virtual_machine_id = azurerm_linux_virtual_machine.vm.1.id
    lun                = 10
    caching            = "ReadWrite"

  tags = var.tags
}

output "fqdn" {
  value = azurerm_public_ip.pip.fqdn
}