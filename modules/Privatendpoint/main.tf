
resource azurerm_private_endpoint "adl_sql_pe" {
  count                = var.module_enabled && var.is_private_endpoint ? 1 : 0
  name                 = azurerm_mssql_server.adl_sql[0].name
  location             = data.azurerm_resource_group.rg1.location
  resource_group_name  = data.azurerm_resource_group.rg1.name
  subnet_id            = var.subnet_id
  private_service_connection {
    name                           = azurerm_mssql_server.adl_sql[0].name
    is_manual_connection           = false
    private_connection_resource_id = azurerm_mssql_server.adl_sql[0].id
    subresource_names              = ["sqlServer"]
  }
  tags = var.tags
}

resource "azurerm_private_dns_zone" "dns_zone" {
  count               = var.module_enabled && var.is_private_endpoint ? 1 : 0
  name                = var.private_dns_zone_name
  resource_group_name = data.azurerm_resource_group.rg1.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "adl_sql_privatedns_vnetlink" {
  count               = var.module_enabled && var.is_private_endpoint ? 1 : 0
  name                = "${azurerm_private_dns_zone.private_dns_zone.name}-vnet-link"
  resource_group_name = data.azurerm_resource_group.rg1.name
  virtual_network_id  = var.vnet_id
  registration_enabled = true
  tags                = var.tags
}

resource "azurerm_private_dns_a_record" "adl_sql_privatedns_record" {
  count               = var.module_enabled && var.is_private_endpoint ? 1 : 0
  name                = azurerm_mssql_server.adl_sql[0].name
  resource_group_name = data.azurerm_resource_group.rg1.name
  ttl                 = 300
  records             = [azurerm_mssql_server.adl_sql[0].private_endpoint_connections[0].private_ip_address]
  zone_name           = azurerm_private_dns_zone.adl_sql_privatedns[0].name
  tags                = var.tags
}