variable "name" {
  type        = string
  description = "Basename of the module."
  default     = "mssql-demos"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags which should be assigned to the deployed resource."
  default = {
    Environment = "Development"
    Project     = "ProjectName"
    Owner       = "osama"
    Department  = "IT"
  }
}

variable "module_enabled" {
  type        = bool
  description = "Variable to enable or disable the module."
  default     = true
}

variable "create_mode" {
  type        = string
  description = "The create mode for the resource."
  default     = "Default"
  validation {
    condition     = can(regex("^[a-zA-Z]+$", var.create_mode))
    error_message = "Valid values for create_mode must be alphabetic characters only."
  }
}

variable "sample_name" {
  type        = string
  description = "The name of the sample database to create inside the server."
  default     = "AdventureWorksLT"
}


variable "collation" {
  type        = string
  description = "The name of the collation."
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

variable "zone_redundant" {
  type        = bool
  description = "Whether or not this database is zone redundant, which means the database will be backed up to multiple availability zones."
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name."
  default     = "genpact-demo3"
  validation {
    condition     = can(regex("^[-\\w\\.\\(\\)]{1,90}$", var.resource_group_name)) && can(regex("[-\\w\\(\\)]+$", var.resource_group_name))
    error_message = "Resource group names must be between 1 and 90 characters and can only include alphanumeric, underscore, parentheses, hyphen, period (except at end)"
  }
}

variable "location" {
  type        = string
  description = "Location of the resource group."
  default      = "eastus"
}

variable "is_private_endpoint" {
  type        = bool
  description = "Whether private endpoints are enabled to access the resource."
  default     = true
}


variable "subnet_id" {
  type        = string
  description = "The ID of the subnet from which private IP addresses will be allocated for this Private Endpoint."
  default     = ""
}

variable "subnet_name" {
  type        = string
  description = "The name of the subnet from which private IP addresses will be allocated for this Private Endpoint." 
  default     = "pe-snet"
}


variable "private_dns_zone_ids" {
  type        = list(string)
  description = "Specifies the list of Private DNS Zones to include."
  default     = []
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

variable "minimum_tls_version" {
  type        = string
  description = "The Minimum TLS Version for all SQL Database and SQL Data Warehouse databases associated with the server."
  validation {
    condition     = contains(["1.0", "1.1", "1.2", "disabled"], lower(var.minimum_tls_version))
    error_message = "Valid values for sku are \"1.0\", \"1.1\", \"1.2\", or \"Disabled\"."
  }
  default = "1.2"
}

variable "azuread_administrator" {
  type = object({
    login_username              = string
    object_id                   = string
    tenant_id                   = string
    azuread_authentication_only = bool
  })
  description = <<EOT
    "
        login_username - The login username of the Azure AD Administrator of this SQL Server.
        object_id - The object id of the Azure AD Administrator of this SQL Server.
        tenant_id - The tenant id of the Azure AD Administrator of this SQL Server.
        azuread_authentication_only - Specifies whether only AD Users and administrators (like azuread_administrator.0.login_username) can be used to login, or also local database users (like administrator_login). When true, the administrator_login and administrator_login_password properties can be omitted.
    "
  EOT
}
variable "sku_name_test" {
  description = "The SKU settings for the mssql."
  type = object({
    name     = string
    tier     = string
    capacity = number
    family   = string
  })
  default = {
    name     = "Standard"
    tier     = "Standard"
    capacity = 100
    family   = "Gen5"
  }
}
variable "sku_name" {
  description = "The SKU name for the database"
  type        = string
  default     = "GP_S_Gen5_1"  # replace this with your desired SKU name
}

variable storage_mb {    
    type        = number    
    description = "The max storage allowed for a server."    
    default = 5120
}

variable start_ip_address  {
    type        = string    

    description = "The starting IP address to allow connections from for this firewall rule. Must be IPv4 format. Use value"
    default = "192.168.1.1"
}
variable end_ip_address {
    type        = string    
    description = "The ending IP address to allow connections to for this firewall rule. Must be IPv4 format. Must be greater than or equal to start_ip_address. Use value"
    default = "10.0.0.1"
}
variable "db_name" {
  type        = string
  description = "The name of the database to create inside the server."
  default     = "mydatabase"
}

variable "max_size_gb" {
    type        = number    
    description = "The max size of the database in gigabytes."
    default = 5
}

variable "elastic_pool_max_size_gb" {
    type        = number    
    description = "The max size of the elastic pool in gigabytes."
    default = 100
}

variable "license_type" {
    type        = string    
    description = "The license type to apply for this database. Possible values are LicenseIncluded and BasePrice."
    default = "LicenseIncluded"
}


variable authentication_type {
    type        = string    
    description = "The type of authentication used to connect to the SQL Server. Possible values are SQL and AD."
    default = "SQL"
}

variable "enable_firewall_rules" {
  description = "Manage an Azure SQL Firewall Rule"
  default     = false
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
  default     = false
}

variable "virtual_network_name" {
    type        = string    
    description = "The name of the virtual network to which this server belongs."
    default = "vm-vnet"
}

variable "vnet_resource_group_name" {
    type        = string    
    description = "The name of the resource group to which the virtual network belongs."
    default = "genpact-demo2"
}
variable "private_dns_zone_name" {
    type        = string    
    description = "The name of the private DNS zone."
    default = "privatelink.database.windows.net"
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
    capacity = 10
    family   = "Gen5"
  }
}

variable "is_elastic_pool" {
  description = "Indicates whether the database is an elastic pool"
  type        = bool
  default     = true
}

variable "elasticpool_name" {
  description = "The name of the elastic pool to create."
  type        = string
  default     = "genpactmyelasticpool"
}
variable "virtual_network_id" {
    type        = string    
    description = "The ID of the virtual network to which this server belongs."
    default = "/subscriptions/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/resourceGroups/genpact-demo2/providers/Microsoft.Network/virtualNetworks/vm-vnet"
}

variable "connection_policy" {
    type        = string    
    description = "The connection policy used for this server. Possible values are Default, Proxy, Redirect."
    default = "Default"
}



variable "retention_days" {
  description = "The number of days to retain backups for the SQL Database."
  type        = number
  default     = 7
}

variable "backup_retention_days" {
  description = "The number of days to retain backups for the SQL Database."
  type        = number
  default     = 7
}

variable "ltr_weekly_retention" {
  description = "The long-term retention policy for weekly backups."
  type        = string
  default     = "P1W"
}

variable "ltr_monthly_retention" {
  description = "The long-term retention policy for monthly backups."
  type        = string
  default     = "P1M"
}


variable "ltr_yearly_retention" {
  description = "The long-term retention policy for yearly backups."
  type        = string
  default     = "P1Y"
}

variable "ltr_week_of_year" {
  description = "The week of the year to retain the yearly backup."
  type        = number
  default     = 1
}

variable "maintenance_configuration_name" {
  description = "The name of the maintenance configuration."
  type        = string
  default     = "SQL_Default"
}
variable "transparent_data_encryption_enabled" {
  description = "Specifies whether to use transparent data encryption."
  type        = bool
  default     = true
}

variable "read_scale" {
  description = "This property is only settable for Hyperscale edition databases."
  type = bool
  default= false
}

variable "restore_point_in_time" {
  type = string
  description = "Specifies the point in time (ISO8601 format) of the source database that will be restored to create the new database. This property is only settable for create_mode= PointInTimeRestore databases."
  default = "2023-01-01T00:00:00Z"
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

