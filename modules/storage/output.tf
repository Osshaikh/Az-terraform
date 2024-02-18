#
# Copyright 2023 BBL & Microsoft. All rights reserved.
#

output "name" {
  value       = azurerm_storage_account.st1.name
  description = "The generated name of the Storage Account."
}
output "id" {
  value       = azurerm_storage_account.st1.id
  description = "The generated ID of the Storage Account."
}
output "primary_blob_endpoint" {
  value       = azurerm_storage_account.st1.primary_blob_endpoint
  description = "The primary Blob endpoint."
  sensitive   = true
}
output "primary_connection_string" {
  value       = azurerm_storage_account.st1.primary_connection_string
  description = "The Storage Account primary connection string."
  sensitive   = true
}
output "primary_access_key" {
  value       = azurerm_storage_account.st1.primary_access_key
  description = "The Primary access key of the Storage Account."
  sensitive   = true
}
output "container_ids" {
  value       = [for c in azurerm_storage_container.st1 : c.id]
  description = "The generated IDs for the Containers."
}
output "file_share_ids" {
  value       = [for s in azurerm_storage_share.st1 : s.id]
  description = "The generated IDs of the File shares."
}
output "file_share_urls" {
  value       = [for s in azurerm_storage_share.st1 : s.url]
  description = "The generated URLs of the File shares."
}
