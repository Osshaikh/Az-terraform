# - Storage Account settings

variable storage_account_name {
  description = "(Required) Specifies the name of the Storage Account. Changing this forces a new resource to be created."
  type        = string
  default     = "genpactdemoaccount12"
}

variable location {
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  type        = string
  default     = "eastus"
}

variable account_tier {
  description = "(Optional) Defines the Tier to use for this Storage Account.<br></br>&#8226; Possible values are `Standard` and `Premium`."
  type        = string
  default     = "Standard"
}

variable "sku" {
  type        = string
  description = "(Optional) `sku` is the combination of the `account_tier` and the `account_replication_type`. For example: for an `account_tier = Standard` and an `account_replication_type = LRS`, the value should be `Standard_LRS`."
  default     = "Standard_LRS"
}
variable "account_kind" {
  type        = string
  description = "(Optional) Defines the Kind of Storage Account.<br></br>&#8226; Possible values are: `BlobStorage`, `BlockBlobStorage`, `FileStorage`, `Storage` and `StorageV2`."
  default     = "StorageV2"
}
variable "access_tier" {
  type        = string
  description = "(Optional) Defines the Access Tier for the Storage Account.<br></br>&#8226; Possible values are: `Cool`, `Hot`."
  default     = "Hot"
}
variable "assign_identity" {
  type        = bool
  description = "(Optional) Set to `true`, the Storage Account will be assigned an identity."
  default     = false
}
variable "large_file_share_enabled" {
  type        = bool
  description = "(Optional) Set to `true`, the Storage Account will be enabled for large file shares."
  default     = false
}
variable "nfsv3_enabled" {
  type        = bool
  description = "Set to `true`, the `NFSV3` protocol will be enabled."
  default     = true
}
variable "is_log_storage" {
  type        = bool
  description = "Set to `true`, if the `storage account` created to store `platform logs`."
  default     = false
}

variable "public_access" {
  type        = bool
  description = "(Optional) Specifies whether or not public access is allowed for all blobs or containers in the storage account.<br></br>&#8226; Possible values are `Blob`, `Container` and `None`."
  default     = "true"
}

variable  allow_nested_items_to_be_public {
  type        = bool
  description = "(Optional) Specifies whether or not public access is allowed for all blobs or containers in the storage account.<br></br>&#8226; Possible values are `Blob`, `Container` and `None`."
  default     = true
}

variable enable_https_traffic_only {
  type        = bool
  description = "(Optional) Specifies whether Traffic to the Storage Account should be forced to use `HTTPS` or not."
  default     = true
}

variable Tls_version {
  type        = string
  description = "(Optional) Specifies the minimum `TLS` version to use for the Storage Account.<br></br>&#8226; Possible values are `TLS1_0`, `TLS1_1`, `TLS1_2` and `TLS1_2`. Defaults to `TLS1_2`."
  default     = "TLS1_2"
}

variable "resource_group_name" {
  type = string
  default = "genpact-demo-rg1"
}

variable container_name {
  type = string
  default = "genpactdemocontainer"
}
variable is_hns_enabled  {
  type = bool
  default = false
}

variable "container_access_type"{
  type = string
  default = "private"
}

variable "additional_tags" {
  description = "(Optional) Additional tags for the storage account."
  type        = map(string)
  default     = null
}

#--------------------------------------------------
#  - Resources within the Storage Account variables
#--------------------------------------------------
variable "containers" {
  description = "(Optional) Map of the Containers in the Storage Account.<br></br><ul><li>`name`: (Required) The name of the Container which should be created within the Storage Account."
  type = map(object({
    name                  = string
    container_access_type = string
  }))
  default = {
    "container1" = {
      name                  = "container3"
      container_access_type = "private"
    },
    "container2" = {
      name                  = "container4"
      container_access_type = "private"
    }
  }
}
variable "blobs" {
  description = "(Optional) Map of the Storage Blobs in the Containers.<br></br><ul><li>`name`: (Required) The name of the storage blob. Must be unique within the storage container the blob is located, </li><li>`storage_container_name`: (Required) The name of the storage container in which this blob should be created, </li><li>`type`: (Required) The type of the storage blob to be created. Possible values are `Append`, `Block` or `Page`, </li><li>`size`: (Optional) Used only for page blobs to specify the size in bytes of the blob to be created. Must be a multiple of 512, </li><li>`content_type`: (Optional) The content type of the `storage blob`. Cannot be defined if `source_uri` is defined, </li><li>`parallelism`: (Optional) The number of workers per CPU core to run for concurrent uploads, </li><li>`source_uri`: (Optional) The URI of an existing blob, or a file in the Azure File service, to use as the source contents for the blob to be created, </li><li>`metadata`: (Optional) A map of custom blob metadata."
  type = map(object({
    name                   = string
    storage_container_name = string
    type                   = string
    size                   = number
    content_type           = string
    parallelism            = number
    source_uri             = string
    metadata               = map(any)
  }))
  default = {
    blob1 = {
    name                   = "blob1incontainer1"
    storage_container_name = "container1"
    type                   = "Block"
    size                   = 1024
    content_type           = null
    source_uri             = null
    metadata               = {}
    parallelism            = 8
  }
  }

  # Requires a "Storage Blob Data *" role assigned to see blobs in Portal

}

variable "queues" {
  description = "(Optional) Map of the Storage Queues.<br></br><ul><li>`name`: (Required) The name of the Queue which should be created within the Storage Account. Must be unique within the storage account the queue is located, </li><li>`metadata`: (Optional) A mapping of MetaData which should be assigned to this Storage Queue."
  type = map(object({
    name     = string
    metadata = map(any)
  }))
  default = {
    queue1 = {
    name     = "queue1"
    metadata = {}
  }
  }
}

variable "file_shares" {
  description = "(Optional) Map of the Storage File Shares.<br></br><ul><li>`name`: (Required) The name of the share. Must be unique within the storage account where the share is located, </li><li>`quota`: (Optional) The maximum size of the share, in gigabytes. For Standard storage accounts, this must be greater than 0 and less than 5120 GB (5 TB). For Premium FileStorage storage accounts, this must be greater than 100 GB and less than 102400 GB (100 TB), </li><li>`enabled_protocol`: (Optional) The protocol used for the share. Possible values are `SMB` and `NFS`, </li><li>`metadata`: (Optional) A mapping of MetaData for this File Share."
  type = map(object({
    name             = string
    quota            = number
    enabled_protocol = string
    metadata         = map(any)
    access_tier      = string
  }))
  default = {
    share1 = {
    name             = "share1"
    quota            = "100"
    metadata         = {}
    enabled_protocol = null
    access_tier      = "Cool"
  }
  }
}
variable "tables" {
  description = "(Optional) Map of the Storage Tables.<br></br><ul><li>`name`: (Required) The name of the storage table. Must be unique within the storage account the table is located."
  type = map(object({
    name = string
  }))
  default = {}
}


#---------------------------------------------------
#Storage account Security
#-----------------------------------------------------
variable "network_rules" {
  description = "(Optional) Networking settings for the Storage Account:<br></br><ul><li>`default_action`: (Required) The Default Action to use when no rules match ip_rules / virtual_network_subnet_ids. Possible values are `\"Allow\"` and `\"Deny\"`,</li><li>`bypass`: (Optional) Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Valid options are any combination of [`\"Logging\"`, `\"Metrics\"`, `\"AzureServices\"`, `\"None\"`],</li><li>`ip_rules`: (Optional) One or more <b>Public IP Addresses or CIDR Blocks</b> which should be able to access the Storage Account,</li><li>`virtual_network_subnet_ids`: (Optional) One or more Subnet IDs which should be able to access the Storage Account.</li></ul>"
  type = object({
    default_action             = string
    bypass                     = list(string)
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })
  default = {
    default_action             = "Allow"
    ip_rules                   = []
    virtual_network_subnet_ids = []
    bypass                     = ["AzureServices"]
  }
}