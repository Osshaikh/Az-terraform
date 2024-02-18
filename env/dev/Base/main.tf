data "azurerm_resource_group" "rg1" {
  name = var.resource_group_name
}

resource "random_id" "vm" {
  byte_length = 4
}



data "azurerm_client_config" "current" {}

module "vnet"{
source = "../../../modules/vnet/"
  resource_group_name = data.azurerm_resource_group.rg1.name
  address_space                     = var.address_space
  location = var.location
  virtual_network_name = var.virtual_network_name
  subnets = var.subnets
}


module "storage"{
  source = "../../../modules/storage/"
  resource_group_name = data.azurerm_resource_group.rg1.name
  location = data.azurerm_resource_group.rg1.location
  storage_account_name = var.storage_account_name
  account_tier = var.account_tier
  account_kind = var.account_kind
  containers           = var.st1_containers
  large_file_share_enabled = var.large_file_share_enabled
  nfsv3_enabled            = var.nfsv3_enabled
  allow_nested_items_to_be_public = var.nested_items    #Disable anonymous public read access to containers and blobs
  enable_https_traffic_only       = var.https_enabled     #Require secure transfer (HTTPS) to the storage account for REST API Operations
  network_rules = var.st_network_acls
 
}

 module "mssql"{
  source                = "../../../modules/mssql/"
  resource_group_name   = data.azurerm_resource_group.rg1.name
  is_elastic_pool = true
  location              = data.azurerm_resource_group.rg1.location
  name               = "${var.db_name}-${random_id.vm.hex}-1"
  max_size_gb   = var.elastic_pool_max_size_gb
elastic_pool_sku = {
    name     = "GP_Gen5"  // Example SKU, adjust according to your needs
    tier     = "GeneralPurpose"
    family   = "Gen5"
    capacity = 80
  }

  create_mode           = var.create_mode
  administrator_login = var.administrator_login
  administrator_login_password = var.administrator_login_password
  azuread_administrator = var.azuread_administrator
  enable_private_endpoint      = var.enable_private_endpoint
  subnet_id                    = "/subscriptions/08fe4261-2508-4d2f-8c81-f570ad6b3bf1/resourceGroups/genpact-demo2/providers/Microsoft.Network/virtualNetworks/vm-vnet/subnets/pe-snet"
  enable_firewall_rules       = var.enable_firewall_rules
  firewall_rules = var.firewall_rules
  virtual_network_id = "/subscriptions/08fe4261-2508-4d2f-8c81-f570ad6b3bf1/resourceGroups/genpact-demo2/providers/Microsoft.Network/virtualNetworks/vm-vnet"
 }




