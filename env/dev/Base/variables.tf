
# General settings

variable "resource_group_name" {
  type = string
  default = "genpact-demo-rg1"
}

variable "location" {
  default = "eastus"
}

# VNet settings

variable "virtual_network_name" {
  default = "mytf-vnet"
}

variable "address_space" {
description = "The address prefix for the virtual network"
default = ["10.3.0.0/23"]
}

variable "dns_servers" {
    type = list
    default = ["8.8.8.8"]
}

variable "subnets" {
  description = "(Optional) The virtual network subnets with their properties:<br></br><ul><li>[map key] used as `name`: (Required) The name of the subnet. </li><li>`address_prefixes`: (Optional) The address prefixes to use for the subnet. </li><li>`pe_enable`: (Optional) Enable or Disable network policies for the private link endpoint & private link service on the subnet. </li><li>`service_endpoints`: (Optional) The list of Service endpoints to associate with the subnet. Possible values include: `Microsoft.AzureActiveDirectory`, `Microsoft.AzureCosmosDB`, `Microsoft.ContainerRegistry`, `Microsoft.EventHub`, `Microsoft.KeyVault`, `Microsoft.ServiceBus`, `Microsoft.Sql`, `Microsoft.Storage` and `Microsoft.Web`. </li><li>`delegation` </li><ul><li>`name`: (Required) A name for this delegation. </li><li>`service_delegation` </li><ul><li>`name`: (Required) The name of service to delegate to. Possible values include `Microsoft.ApiManagement/service`, `Microsoft.AzureCosmosDB/clusters`, `Microsoft.BareMetal/AzureVMware`, `Microsoft.BareMetal/CrayServers`, `Microsoft.Batch/batchAccounts`, `Microsoft.ContainerInstance/containerGroups`, `Microsoft.ContainerService/managedClusters`, `Microsoft.Databricks/workspaces`, `Microsoft.DBforMySQL/flexibleServers`, `Microsoft.DBforMySQL/serversv2`, `Microsoft.DBforPostgreSQL/flexibleServers`, `Microsoft.DBforPostgreSQL/serversv2`, `Microsoft.DBforPostgreSQL/singleServers`, `Microsoft.HardwareSecurityModules/dedicatedHSMs`, `Microsoft.Kusto/clusters`, `Microsoft.Logic/integrationServiceEnvironments`, `Microsoft.MachineLearningServices/workspaces`, `Microsoft.Netapp/volumes`, `Microsoft.Network/managedResolvers`, `Microsoft.PowerPlatform/vnetaccesslinks`, `Microsoft.ServiceFabricMesh/networks`, `Microsoft.Sql/managedInstances`, `Microsoft.Sql/servers`, `Microsoft.StoragePool/diskPools`, `Microsoft.StreamAnalytics/streamingJobs`, `Microsoft.Synapse/workspaces`, `Microsoft.Web/hostingEnvironments`, and `Microsoft.Web/serverFarms`. </li><li>`actions`:(Optional) A list of Actions which should be delegated. This list is specific to the service to delegate to. Possible values include `Microsoft.Network/networkinterfaces/*`, `Microsoft.Network/virtualNetworks/subnets/action`, `Microsoft.Network/virtualNetworks/subnets/join/action`, `Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action` and `Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action`.</ul></ul> "
  type = map(object({
    address_prefixes  = list(string)
    pe_enable         = bool
    service_endpoints = list(string)
    delegation = list(object({
      name = string
      service_delegation = list(object({
        name    = string
        actions = list(string)
      }))
    }))
  }))
  default = {
    "application-snet" = {
      address_prefixes  = ["10.3.1.0/24"]
      pe_enable         = false
      service_endpoints = ["Microsoft.Sql", "Microsoft.ServiceBus", "Microsoft.Web"]
      delegation        = []
    },
    "vm-snet" = {
      address_prefixes  = ["10.3.0.0/27"]
      service_endpoints = []
      pe_enable         = false
      delegation        = []
    },
    "pe-snet" = {
      address_prefixes  = ["10.3.0.32/27"]
      pe_enable         = true
      service_endpoints = []
      delegation        = []
    }
  }
  }


#storageaccount

variable storage_account_name {
  default = "st1genpactdemo"
}
 
variable "st1_containers" { 

  default = {
    container1 = {
    name                  = "container1"
    container_access_type = "private"
    storage_account_name = "st1genpactdemo"
  }
  container2 = {
    name                  = "container2"
    container_access_type = "private"
    storage_account_name = "st1genpactdemo"
  }
  }
 }

 variable "st1_file_shares" { 
  default = {
    fileshare1 = {
    name                  = "fileshare1"
    quota                 = 50
    share_access_type     = "private"
  } 
 }
}
 
 

variable account_tier {
  default = "Standard"
}

variable account_kind {
  default = "StorageV2"
}

variable storage_account_access_tier {
  default = "Hot"
}

variable storage_account_allow_blob_public_access {
  default = true
}

variable large_file_share_enabled {
  default = true
}
variable https_enabled  {
  default = true
}

variable nfsv3_enabled {
  default = false
}

 variable nested_items {
  default = true
 }

variable min_Tls_version {
  default = "TLS1_2"
}

variable  "st_network_acls" {
  default = {  
    default_action             = "Allow"                     # (Required) The Default Action to use when no rules match from ip_rules / virtual_network_subnet_ids. Possible values are Allow and Deny.
    ip_rules                   =  ["180.148.48.25",""]# (Optional) One or more Public IP Addresses, or CIDR Blocks which should be able to access the Storage Account.
    virtual_network_subnet_ids = []               # (Optional) One or more Subnet ID's which should be able to access this Storage Account.
    bypass                     = ["None"]                   # (Required) Specifies which traffic can bypass the network rules. Valid options are any combination of Logging, Metrics, AzureServices, or None.
  }
}

#ms-sql

variable "sql_admin_username"{
  default = "sqladmin"
  type = string
}

variable "sql_password" {
default = "Password1234!"
type = string
}

variable "db_name"{
  default = "tfsqldb"
  type = string
}

variable "start_ip_address" {
  default = "10.0.0.0/8"
}

variable "end_ip_address" {
  default = "192.168.0.0/16"
}

variable max_size_gb{
  default = 5
  type = number
}

variable "elastic_pool_max_size_gb" {
    type        = number    
    description = "The max size of the elastic pool in gigabytes."
    default = 100
}

#linux_vm

variable "name" {
  default = "linuxvm"
  type = string
}

variable "size" {
  default = "Standard_B2s"
}

variable "admin_username" {
  default = "azureuser"
  type = string
}

variable "admin_password" {
  type        = string
  default     = "Password1234!"
  description = "(Optional) The Password which should be used for the local-administrator on this Virtual Machine Required when using Windows Virtual Machine. Changing this forces a new resource to be created. When an `admin_password` is specified `disable_password_authentication` must be set to `false`. One of either `admin_password` or `admin_ssh_key` must be specified."
  sensitive   = true
}

variable "license_type" {
  default = "Windows_Server"
}

variable "is_windows" {
  default = true
}

variable "nb_instances"{
  default = 1
  type = number
}

#mssql

variable "authentication_type" {
  type        = string
  default = "ADPassword"
}

variable "azuread_administrator" {
  description = "Azure AD administrator configuration."
  type = object({
    login_username              = string
    object_id                   = string
    tenant_id                   = string
    azuread_authentication_only = bool
  })
   default = {
    login_username              = "example@domain.com"
    object_id                   = "00000000-0000-0000-0000-000000000000"
    tenant_id                   = "00000000-0000-0000-0000-000000000000"
    azuread_authentication_only = true
  } 
}

variable "administrator_login" {
  type        = string
  description = "The administrator login name for the new server."
  default      = "azureuser"
  validation {
    condition     = can(regex("^[\\s\\S]{8,128}$", var.administrator_login)) && can(regex("^[a-zA-Z]+", var.administrator_login))
    error_message = "Valid values for administrator_login must be betwen 8 and 128 characters in length and must start with a letter."
  }
}

variable "administrator_login_password" {
  type        = string
  description = "The password associated with the administrator_login."
  default       =  "P@ssw0rd1234"
  sensitive = true
}

variable "enable_firewall_rules" {
  description = "Manage an Azure SQL Firewall Rule"
  default     = true
}

variable "firewall_rules" {
  description = "Range of IP addresses to allow firewall connections."
  type = list(object({
    name             = string
    start_ip_address = string
    end_ip_address   = string
  }))
  default = []
}


variable "enable_private_endpoint" {
  description = "Manages a Private Endpoint to SQL database"
  default     = true
}

variable "db_version" {
  type        = string
  description = "The version for the new server."
  validation {
    condition     = contains(["2.0", "12.0"], lower(var.db_version))
    error_message = "Valid values for db_version are \"2.0\", or \"12.0\"."
  }
  default = "12.0"
}


variable "elasticpool_name" {
  description = "The name of the elastic pool to create."
  type        = string
  default     = "genpactmyelasticpool"
}

 variable "elastic_pool_sku" {
  description = "The SKU settings for the elastic pool."
  type = object({
    name     = string
    tier     = string
    capacity = number
    family   = string
  })
  default = {
    name     = "GP_Gen5"
    tier     = "GeneralPurpose"
    capacity = 100
    family   = "Gen5"
  }
}

variable "sku_name" {
  type = string
  description = "pecifies the name of the SKU used by the database. For example, GP_S_Gen5_2,HS_Gen4_1,BC_Gen5_2, ElasticPool, Basic,S0, P2 ,DW100c, DS100"
  default = "ElasticPool"
}

variable "virtual_network_id" {
    type        = string    
    description = "The ID of the virtual network to which this server belongs."
    default = "/subscriptions/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/resourceGroups/genpact-demo2/providers/Microsoft.Network/virtualNetworks/vm-vnet"
}

variable "read_scale" {
  description = "This property is only settable for Hyperscale edition databases."
  type = bool
  default= false
}

variable "restore_point_in_time" {
  type = string
  description = "Specifies the point in time (ISO8601 format) of the source database that will be restored to create the new database. This property is only settable for create_mode= PointInTimeRestore databases."
  default = "2021-07-01T00:00:00Z"
}

variable "create_mode" {
  type = string
  default = "Default"
}

variable "transparent_data_encryption_enabled" {
  description = "Specifies whether to use transparent data encryption."
  type        = bool
  default     = true
}

variable "is_elastic_pool" {
  description = "Indicates whether the database is an elastic pool"
  type        = bool
  default     = true
}

variable "is_single_db" {
  description = "Indicates whether the database is a single database or elastic pool database."
  type        = bool
  default     = false
}

variable "elastic_pool_per_database_settings" {
  description = "The elastic pool per database settings."
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default = {
    min_capacity = 0
    max_capacity = 50
  }
}