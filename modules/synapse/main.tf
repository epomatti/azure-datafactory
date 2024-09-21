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
  azuread_authentication_only          = true
  storage_data_lake_gen2_filesystem_id = var.storage_data_lake_gen2_filesystem_id

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      # Ignore the "sqladminuser" default user
      sql_administrator_login
    ]
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

# resource "azurerm_synapse_sql_pool" "test1" {
#   name                 = "syndp${var.workload}"
#   synapse_workspace_id = azurerm_synapse_workspace.w001.id
#   sku_name             = var.pool_sku_name
#   collation            = "SQL_Latin1_General_CP1_CI_AS"
#   create_mode          = "Default"
#   storage_account_type = "LRS"
#   data_encrypted       = true
# }
