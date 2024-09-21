output "storage_account_id" {
  value = azurerm_storage_account.lake.id
}

# output "storage_account_name" {
#   value = azurerm_storage_account.lake.name
# }

# output "primary_access_key" {
#   value     = azurerm_storage_account.lake.primary_access_key
#   sensitive = true
# }

output "primary_dfs_endpoint" {
  value = azurerm_storage_account.lake.primary_dfs_endpoint
}

# output "secondary_dfs_endpoint" {
#   value = azurerm_storage_account.lake.secondary_dfs_endpoint
# }

# output "primary_connection_string" {
#   value = azurerm_storage_account.lake.primary_connection_string
# }

# output "databricks_filesystem_stage_name" {
#   value = azurerm_storage_data_lake_gen2_filesystem.stage.name
# }

output "synapse_filesystem_id" {
  value = azurerm_storage_data_lake_gen2_filesystem.synapse.id
}
