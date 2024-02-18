terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.79.0"
    }
  }
  backend "local" {}
}

  provider "azurerm" {
    skip_provider_registration = true
  features {}
  client_id = "2a806653-2eea-4b70-8d2d-d0ee01801131"
  tenant_id = "2f9a5637-5993-4e63-a7b2-729e73eb844b"
  subscription_id = "08fe4261-2508-4d2f-8c81-f570ad6b3bf1"

}
