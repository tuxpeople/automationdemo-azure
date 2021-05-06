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

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vnet_name}"
  location            = "${var.location}"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "10.0.0.0/24"
}

resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.vm_name}-nic-${count.index}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  tags                = "${var.tags}"
  count               = "3"

  ip_configuration {
    name                          = "testconfiguration${count.index}"
    subnet_id                     = "${azurerm_subnet.subnet1.id}"
    private_ip_address_allocation = "dynamic"
  }
}