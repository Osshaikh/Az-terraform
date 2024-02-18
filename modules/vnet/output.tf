#
# Copyright 2023 BBL & Microsoft. All rights reserved.
#

#----------------------------
# - OUTPUTS VNet, Subnets
#----------------------------

#---------
# - VNet
#---------
output "vnet" {
  value       = azurerm_virtual_network.this
  description = "Details of the Virtual network."
}

output "id" {
  value       = azurerm_virtual_network.this.id
  description = "The Virtual network ID."
}

output "name" {
  value       = azurerm_virtual_network.this.name
  description = "The name of the Virtual network."
}

output "location" {
  value       = azurerm_virtual_network.this.location
  description = "The location of the Virtual network."
}

output "resource_group_name" {
  value       = azurerm_virtual_network.this.resource_group_name
  description = "The name of Resource group in which the Virtual Network has been created."
}

#-----------
# - Subnets
#-----------
output "subnet_ids_map" {
  value = {for s in azurerm_subnet.this : s.name => s.id}
}

output "map_subnet_ids" {
  value       = { for x in azurerm_subnet.this : x.name => x.id }
  description = "Map of the subnet IDs."
}

output "subnets_with_service_endpoints" {
  value       = [for s in azurerm_subnet.this : s.id if length(coalesce(s.service_endpoints, [])) > 0]
  description = "Subnets with Service Endpoints enabled."
}

output "map_subnets_service_endpoints" {
  value       = { for x in azurerm_subnet.this : x.name => x.id if length(coalesce(x.service_endpoints, [])) > 0 }
  description = "Map of Subnets with Service Endpoints enabled."
}

output "subnets_enabled_for_private_endpoints" {
  value       = distinct([for s in azurerm_subnet.this : s.id if(s.enforce_private_link_endpoint_network_policies == true && s.enforce_private_link_service_network_policies == true)])
  description = "Subnets with Private Link Endpoint AND Private Link Service policies enabled."
}

