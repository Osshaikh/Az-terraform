# - Dependencies data resource

data "azurerm_resource_group" "rg1" {
  name = var.resource_group_name
}

#-----------------------
# - Generate the locals
#-----------------------
locals {
  enabled_for_all_network = {
    bypass                     = ["AzureServices"]
    default_action             = "Allow"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
  network_rules = var.network_rules.default_action == "Allow" ? local.enabled_for_all_network : var.network_rules

  tags = merge(
    data.azurerm_resource_group.rg1.tags,
    var.additional_tags
  )
 
}

resource "azurerm_storage_account" "st1" {
  name                     = var.storage_account_name
  resource_group_name      = data.azurerm_resource_group.rg1.name
  location                 = var.location
  account_tier             = var.account_kind == "StorageV2" ? "Standard" : split("_", var.sku)[0]
  account_replication_type = var.account_kind == "StorageV2" ? "LRS" : split("_", var.sku)[1]
  account_kind             = var.account_kind
  access_tier              = var.access_tier
  large_file_share_enabled = var.large_file_share_enabled
  nfsv3_enabled            = var.is_hns_enabled ? var.nfsv3_enabled : false
  allow_nested_items_to_be_public = true    #Disable anonymous public read access to containers and blobs
  enable_https_traffic_only       = true     #Require secure transfer (HTTPS) to the storage account for REST API Operations
  min_tls_version                 = var.Tls_version     #Configure the minimum required version of Transport Layer Security (TLS) for a storage account and require TLS Version1.2
  public_network_access_enabled   = var.public_access    #Disable public access to all blobs or containers in the storage account
  is_hns_enabled                  = false

  blob_properties {
    delete_retention_policy {
      days = var.is_log_storage == false ? 365 : 7
    }
    container_delete_retention_policy {
      days = var.is_log_storage == false ? 365 : 7
    }
    versioning_enabled  = false
    change_feed_enabled = false
  }

  dynamic "identity" {
    for_each = var.assign_identity == false ? [] : tolist([var.assign_identity])
    content {
      type = "SystemAssigned"
    }
  }
}


################################  Store data in Storage Account  ################################
#------------------------------
# - Containers
#------------------------------
# Create containers in storage account

resource "azurerm_storage_container" "st1" {
  for_each             = var.containers
  name                  = each.value["name"]
  storage_account_name  = azurerm_storage_account.st1.name
  container_access_type = var.container_access_type
}

#-------------------------------
# - File Shares
#-------------------------------
resource "azurerm_storage_share" "st1" {
  for_each             = var.file_shares

  name                 = each.value["name"]
  storage_account_name = azurerm_storage_account.st1.name
  quota                = coalesce(lookup(each.value, "quota"), 500)
  enabled_protocol     = lookup(each.value, "enabled_protocol", "SMB")
  metadata             = lookup(each.value, "metadata", null)
  access_tier          = lookup(each.value, "access_tier", "TransactionOptimized") #default = TransactionOptimized. Other= Hot, Cool
}


#------------------------------------
# - Storage Account Networking rules
#------------------------------------
resource "azurerm_storage_account_network_rules" "st1" {
  # Prevents locking the Storage Account before all resources are created
  depends_on = [
    azurerm_storage_container.st1
  ]

  storage_account_id = azurerm_storage_account.st1.id
  default_action             = local.network_rules.default_action
  ip_rules                   = local.network_rules.ip_rules
  virtual_network_subnet_ids = local.network_rules.virtual_network_subnet_ids
  bypass                     = local.network_rules.bypass
}
