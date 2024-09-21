data "azuread_client_config" "current" {}

locals {
  current_client_object_id = data.azuread_client_config.current.object_id
  # tokyo_source = "${path.module}/../../../dataset/tokyo2011.zip"
}

resource "azurerm_storage_account" "lake" {
  name                       = "dls${var.workload}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  account_tier               = "Standard"
  account_replication_type   = "LRS"
  account_kind               = "StorageV2"
  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"

  # Hierarchical namespace
  is_hns_enabled = true

  # Further controlled by network_rules below
  public_network_access_enabled = true

  network_rules {
    default_action             = "Deny"
    ip_rules                   = var.network_ip_rules
    virtual_network_subnet_ids = var.virtual_network_subnet_ids
    bypass                     = ["AzureServices"]
  }

  lifecycle {
    ignore_changes = [
      network_rules[0].private_link_access
    ]
  }
}

resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  scope                = azurerm_storage_account.lake.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = local.current_client_object_id
}

resource "azurerm_role_assignment" "storage_blob_data_owner" {
  scope                = azurerm_storage_account.lake.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = local.current_client_object_id
}

# resource "azurerm_storage_data_lake_gen2_filesystem" "source" {
#   name               = "raw-source"
#   storage_account_id = azurerm_storage_account.lake.id

#   depends_on = [
#     azurerm_role_assignment.adlsv2,
#   ]
# }

# resource "azurerm_storage_blob" "tokyo" {
#   name                   = "tokyo2011.zip"
#   storage_account_name   = azurerm_storage_account.lake.name
#   storage_container_name = azurerm_storage_data_lake_gen2_filesystem.source.name
#   type                   = "Block"
#   source                 = local.tokyo_source
# }

# resource "azurerm_storage_data_lake_gen2_filesystem" "raw" {
#   name               = "raw-data"
#   storage_account_id = azurerm_storage_account.lake.id

#   depends_on = [
#     azurerm_role_assignment.adlsv2,
#   ]
# }

# resource "azurerm_storage_data_lake_gen2_filesystem" "stage" {
#   name               = "staged-data"
#   storage_account_id = azurerm_storage_account.lake.id

#   depends_on = [
#     azurerm_role_assignment.adlsv2,
#   ]
# }

# resource "azurerm_storage_data_lake_gen2_filesystem" "transf" {
#   name               = "transformed-data"
#   storage_account_id = azurerm_storage_account.lake.id

#   depends_on = [
#     azurerm_role_assignment.adlsv2,
#   ]
# }

# Allow Databricks AAD SP to connect
# resource "azurerm_role_assignment" "databricks" {
#   scope                = azurerm_storage_account.lake.id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = var.databricks_service_principal_object_id
# }
