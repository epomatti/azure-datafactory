data "azurerm_client_config" "current" {}

locals {
  client_object_id = data.azurerm_client_config.current.object_id
  client_tenant_id = data.azurerm_client_config.current.tenant_id
}

data "azuread_user" "current" {
  object_id = data.azurerm_client_config.current.object_id
}

resource "azurerm_synapse_workspace" "w001" {
  name                                 = "synw${var.workload}"
  resource_group_name                  = var.resource_group_name
  location                             = var.location
  azuread_authentication_only          = false
  sql_administrator_login              = var.sql_administrator_login
  sql_administrator_login_password     = var.sql_administrator_password
  storage_data_lake_gen2_filesystem_id = var.storage_data_lake_gen2_filesystem_id
  managed_virtual_network_enabled      = true

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_synapse_workspace_aad_admin" "w001" {
  synapse_workspace_id = azurerm_synapse_workspace.w001.id
  login                = data.azuread_user.current.user_principal_name
  object_id            = local.client_object_id
  tenant_id            = local.client_tenant_id
}

resource "azurerm_synapse_firewall_rule" "allow" {
  count                = length(var.allowed_public_ips)
  name                 = "Allow_${count.index}"
  synapse_workspace_id = azurerm_synapse_workspace.w001.id
  start_ip_address     = var.allowed_public_ips[count.index]
  end_ip_address       = var.allowed_public_ips[count.index]
}

# resource "azurerm_synapse_sql_pool" "pool001" {
#   name                      = "syndp001"
#   synapse_workspace_id      = azurerm_synapse_workspace.w001.id
#   sku_name                  = var.pool_sku_name
#   collation                 = "SQL_Latin1_General_CP1_CI_AS"
#   create_mode               = "Default"
#   storage_account_type      = "LRS"
#   data_encrypted            = true
#   geo_backup_policy_enabled = false
# }

resource "azurerm_synapse_managed_private_endpoint" "datalake" {
  name                 = "datalake"
  synapse_workspace_id = azurerm_synapse_workspace.w001.id
  target_resource_id   = var.datalake_storage_account_id
  subresource_name     = "dfs"

  depends_on = [azurerm_synapse_firewall_rule.allow]
}

resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  scope                = var.datalake_storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_synapse_workspace.w001.identity[0].principal_id
}

resource "azurerm_role_assignment" "storage_blob_data_owner" {
  scope                = var.datalake_storage_account_id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_synapse_workspace.w001.identity[0].principal_id
}

resource "azurerm_synapse_spark_pool" "spark001" {
  name                 = "sparkpool001"
  synapse_workspace_id = azurerm_synapse_workspace.w001.id
  node_size_family     = var.spark_node_size_family
  node_size            = var.spark_node_size
  node_count           = var.spark_node_count
  cache_size           = 100
  spark_version        = "3.4"  

  auto_pause {
    delay_in_minutes = 15
  }

  #   library_requirement {
  #     content  = <<EOF
  # appnope==0.1.0
  # beautifulsoup4==4.6.3
  # EOF
  #     filename = "requirements.txt"
  #   }

  #   spark_config {
  #     content  = <<EOF
  # spark.shuffle.spill                true
  # EOF
  #     filename = "config.txt"
  #   }

}
