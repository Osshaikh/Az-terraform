terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.79.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "AKS-LAB"
    storage_account_name = "esseldatalakedemo"
    container_name       = "tfstate"
    key                  = "Tce9wOyo7/4ExC9ulJBmreEpKerzMYREYUFypt6eu1tmtM2l8zn3YkJmoNe7gymt/BtcXVEAEE2C+AStJL8nMw=="
  }
}

  provider "azurerm" {
    skip_provider_registration = true
  features {}


}
