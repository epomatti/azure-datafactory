output "workspace_id" {
  value = azurerm_synapse_workspace.w001.id
}

output "workspace_name" {
  value = azurerm_synapse_workspace.w001.name
}

output "workspace_principal_id" {
  value = azurerm_synapse_workspace.w001.identity[0].principal_id
}

# output "pool001_name" {
#   value = azurerm_synapse_sql_pool.pool001.name
# }
