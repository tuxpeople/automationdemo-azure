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
      version = "2.42.0"
    }
  }

  required_version = "~> 0.14"
}

provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x.
  # If you're using version 1.x, the "features" block is not allowed.
  features {}
}

data "azurerm_client_config" "current" {}

resource "random_pet" "prefix" {}

resource "azurerm_resource_group" "default" {
  name     = "${random_pet.prefix.id}-rg"
  location = "East US"

  tags = {
    environment = "Demo"
  }
}