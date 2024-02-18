# General settings
resource_group_name = "genpact-demo3"
location = "eastus"

# VNet settings
virtual_network_name = "vm-vnet"
#virtual_network_address_prefix = "172.18.0.0/16"
#vm_subnet_name = "kubesubnet"
#vm_subnet_address_prefix = "172.18.1.0/24"
#appgw_subnet_name = "appgwsubnet"
#app_gateway_subnet_address_prefix = "172.18.2.0/24"


#storage account settings
  storage_account_name = "genpactstoragemodule12"
  storage_account_tier = "Standard"
  storage_account_replication_type = "LRS"
  storage_account_kind = "StorageV2"
  large_file_share_enabled = true
  nfsv3_enabled            = true
  allow_nested_items_to_be_public = true
  enable_https_traffic_only       = true
  min_tls_version                 = "TLS1_2"
  

#nic settings
network_interface_name = "my-custom-nic"
dns_servers                   = ["8.8.4.4", "8.8.8.8"]
ip_configuration = {
  name                          = "custom-configuration"
  private_ip_address_allocation = "Dynamic"
  dns_servers                   = ["8.8.4.4", "8.8.8.8"]
}

#Linux VM
admin_password = "Password1234!"

#mssql

azuread_administrator = {
  login_username = "osshaikh@microsoft.com"
  object_id      = "2a806653-2eea-4b70-8d2d-d0ee01801131"
  tenant_id      = "2f9a5637-5993-4e63-a7b2-729e73eb844b"
  azuread_authentication_only = true
}
  enable_firewall_rules = true
  firewall_rules = [
    {
      name             = "access-to-azure"
      start_ip_address = "0.0.0.0"
      end_ip_address   = "0.0.0.0"
    },
    {
      name             = "desktop-ip"
      start_ip_address = "123.201.36.94"
      end_ip_address   = "123.201.36.94"
    }
  ]