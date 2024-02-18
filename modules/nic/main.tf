data "azurerm_resource_group" "rg1" {
  name = var.resource_group_name
}

resource "azurerm_network_interface" "this" {
  name                = var.network_interface_name
  location            = data.azurerm_resource_group.rg1.location
  resource_group_name = data.azurerm_resource_group.rg1.name
  dns_servers                   = var.dns_servers

  ip_configuration {
    name                          = var.ip_configuration.name
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_address_allocation
    
  }
}