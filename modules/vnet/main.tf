# - Dependencies data resource


data "azurerm_resource_group" "rg1" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "this" {
  name                = var.virtual_network_name
  location            = data.azurerm_resource_group.rg1.location
  resource_group_name = data.azurerm_resource_group.rg1.name
  address_space       = var.address_space
  dns_servers         = var.dns_servers

  tags = var.tags
}

#------------------------------
# - Create the Subnets
#------------------------------
resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                                           = each.key
  resource_group_name                            = data.azurerm_resource_group.rg1.name
  address_prefixes                               = each.value["address_prefixes"]
  enforce_private_link_endpoint_network_policies = lookup(each.value, "pe_enable", false)
  enforce_private_link_service_network_policies  = lookup(each.value, "pe_enable", false)
  virtual_network_name                           = azurerm_virtual_network.this.name

  dynamic "delegation" {
    for_each = lookup(each.value, "delegation", [])
    content {
      name = lookup(delegation.value, "name", null)
      dynamic "service_delegation" {
        for_each = lookup(delegation.value, "service_delegation", [])
        content {
          name    = lookup(service_delegation.value, "name", null)
          actions = lookup(service_delegation.value, "actions", null)
        }
      }
    }
  }

  depends_on = [azurerm_virtual_network.this]
}


# NSG association 
