
variable "resource_group_name" {
  description = "Name of the resource group."
  default = "genpact-demo-rg1"
}

variable "location" {
  description = "Location of the cluster."
    default = "eastus"
}

variable "virtual_network_name"{
    default = "vnet"
    description = "The name of the virtual network"
}

variable "address_space" {
description = "The address prefix for the virtual network"
default = ["10.3.0.0/23"]
}


#   Subnets
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
      address_prefixes  = ["10.3.2.0/24"]
      service_endpoints = null
      pe_enable         = false
      delegation        = []
    },
    "pe-snet" = {
      address_prefixes  = ["10.3.3.0/24"]
      pe_enable         = true
      service_endpoints = null
      delegation        = []
    }
  }
  }



variable tags {
    type = map
    default = {
        environment = "dev"
        costcenter = "it"
    }
}

variable "dns_servers" {
    type = list
    default = ["8.8.8.8"]
}

variable "vnet_name" {
    type = string
    default = "vnet-tf"
}


variable "nsg_ids" {
  type = map(string)
  default = {}
  description = "A map of subnet name to Network Security Group IDs"
}

variable "route_tables_ids" {
  type        = map(string)
  default     = {}
  description = "A map of subnet name to Route table ids"
}