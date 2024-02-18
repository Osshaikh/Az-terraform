# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sql_server


data "azurerm_resource_group" "rg1" {
  name = var.resource_group_name
}


data "azurerm_virtual_network" "vnet01" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = var.virtual_network_name
  resource_group_name = var.vnet_resource_group_name
}

data "azurerm_subnet" "subnet01" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet01[0].name
  resource_group_name = data.azurerm_virtual_network.vnet01[0].resource_group_name
}

resource "azurerm_mssql_server" "adl_sql" {
  name                         = "sqlsvrs-${var.name}"
  resource_group_name          = data.azurerm_resource_group.rg1.name
  location                     = data.azurerm_resource_group.rg1.location
  version                      = var.db_version
  administrator_login            = var.administrator_login
  administrator_login_password = var.administrator_login_password
  minimum_tls_version          = var.minimum_tls_version
  public_network_access_enabled = true
  connection_policy             = var.connection_policy
  

  tags = var.tags

  count = var.module_enabled ? 1 : 0
}

resource "azurerm_mssql_firewall_rule" "fw01" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.adl_sql[0].id
  start_ip_address = var.start_ip_address
  end_ip_address   = var.end_ip_address

  count = var.module_enabled && var.is_private_endpoint ? 0 : 1
}

resource "azurerm_mssql_firewall_rule" "fw02" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.adl_sql[0].id
  start_ip_address = var.start_ip_address
  end_ip_address   = var.end_ip_address

  count = var.module_enabled && var.is_private_endpoint ? 0 : 1
}

resource "azurerm_mssql_database" "adl_sqldb" {
   count               = var.is_single_db ? 1 : 0
    name                   = "$(azurerm_mssql_server.adl_sql[0].name)-database"
    server_id           = azurerm_mssql_server.adl_sql[0].id
    collation           = var.collation
    sku_name   = var.sku_name
    read_scale          = var.read_scale
    max_size_gb         = var.max_size_gb
    zone_redundant      = var.zone_redundant
    auto_pause_delay_in_minutes = "60"
    create_mode         = var.create_mode
    sample_name         = var.sample_name
    maintenance_configuration_name =      var.maintenance_configuration_name
    transparent_data_encryption_enabled = var.transparent_data_encryption_enabled
    restore_point_in_time  =              var.create_mode == "PointInTimeRestore" ? var.restore_point_in_time : null

   short_term_retention_policy {
    retention_days =             var.backup_retention_days
  }

  long_term_retention_policy {
    weekly_retention  = var.ltr_weekly_retention
    monthly_retention = var.ltr_monthly_retention
    yearly_retention  = var.ltr_yearly_retention
    week_of_year      = var.ltr_week_of_year
  }


    tags                = var.tags
    
    #count = var.module_enabled ? 1 : 0

    depends_on = [
        azurerm_mssql_server.adl_sql
    ]
}

resource "azurerm_mssql_elasticpool" "adl_sqldb_elasticpool" {
  count = var.module_enabled && var.is_elastic_pool ? 1 : 0
  name                = "${azurerm_mssql_server.adl_sql[0].name}-elasticpool"
  resource_group_name = azurerm_mssql_server.adl_sql[0].resource_group_name
  location            = azurerm_mssql_server.adl_sql[0].location
  server_name         = azurerm_mssql_server.adl_sql[0].name
  max_size_gb         = var.elastic_pool_max_size_gb

   sku {
    name     = var.elastic_pool_sku.name
    tier     = var.elastic_pool_sku.tier
    family  = var.elastic_pool_sku.family
    capacity = var.elastic_pool_sku.capacity
  }

  per_database_settings {
    min_capacity = var.elastic_pool_per_database_settings.min_capacity
    max_capacity = var.elastic_pool_per_database_settings.max_capacity
  }

  #count = var.module_enabled && var.is_elastic_pool ? 1 : 0

  depends_on = [
    azurerm_mssql_server.adl_sql
  ]
}



resource "azurerm_sql_active_directory_administrator" "aad_admin" {
  count = var.azuread_administrator == null ? 0 : 1

  login                       = var.azuread_administrator.login_username
  object_id                   = var.azuread_administrator.object_id
  resource_group_name         = var.resource_group_name
  server_name                 = azurerm_mssql_server.adl_sql[0].name
  tenant_id                   = var.azuread_administrator.tenant_id
  azuread_authentication_only = var.azuread_administrator.azuread_authentication_only
}


  

resource azurerm_private_endpoint "adl_sql_pe" {
  count                = var.module_enabled && var.is_private_endpoint ? 1 : 0
  name                 = azurerm_mssql_server.adl_sql[0].name
  location             = data.azurerm_resource_group.rg1.location
  resource_group_name  = data.azurerm_resource_group.rg1.name
  subnet_id            = data.azurerm_subnet.subnet01[0].id

  private_service_connection {
    name                           = azurerm_mssql_server.adl_sql[0].name
    is_manual_connection           = false
    private_connection_resource_id = azurerm_mssql_server.adl_sql[0].id
    subresource_names              = ["sqlServer"]
  }
  tags = var.tags
}

data "azurerm_private_endpoint_connection" "adl_sql_pe" {
  count               = var.module_enabled && var.is_private_endpoint ? 1 : 0
  name                = azurerm_private_endpoint.adl_sql_pe[0].name
  resource_group_name = data.azurerm_resource_group.rg1.name
}

resource "azurerm_private_dns_zone" "pe_dns" {
  count               = var.module_enabled && var.is_private_endpoint ? 1 : 0
  name                = var.private_dns_zone_name
  resource_group_name = data.azurerm_resource_group.rg1.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "adl_sql_privatedns_vnetlink" {
  count                 = var.module_enabled && var.is_private_endpoint ? 1 : 0
  name                  = "${azurerm_private_dns_zone.pe_dns[0].name}-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.pe_dns[0].name
  resource_group_name   = data.azurerm_resource_group.rg1.name
  virtual_network_id    = data.azurerm_virtual_network.vnet01[0].id
  registration_enabled  = true
  tags                  = var.tags
}

resource "azurerm_private_dns_a_record" "adl_sql_privatedns_record" {
  count               = var.module_enabled && var.is_private_endpoint ? 1 : 0
  name                = azurerm_mssql_server.adl_sql[0].name
  resource_group_name = data.azurerm_resource_group.rg1.name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.adl_sql_pe.0.private_service_connection.0.private_ip_address]
  zone_name           = azurerm_private_dns_zone.pe_dns[0].name
  tags                = var.tags
}
