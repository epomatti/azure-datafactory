data "azuread_client_config" "current" {}

locals {
  current_client_object_id = data.azuread_client_config.current.object_id
}

resource "azurerm_storage_account" "default" {
  name                       = "st${var.workload}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  account_tier               = "Standard"
  account_replication_type   = "LRS"
  account_kind               = "StorageV2"
  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"

  # Enable STP
  is_hns_enabled = true
  sftp_enabled   = true

  # Further controlled by network_rules below
  public_network_access_enabled = true
}

resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  scope                = azurerm_storage_account.default.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = local.current_client_object_id
}

resource "azurerm_role_assignment" "storage_blob_data_owner" {
  scope                = azurerm_storage_account.default.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = local.current_client_object_id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "staging" {
  name               = "staging"
  storage_account_id = azurerm_storage_account.default.id

  depends_on = [
    azurerm_role_assignment.storage_blob_data_contributor,
    azurerm_role_assignment.storage_blob_data_owner,
  ]
}

# resource "azurerm_storage_account_local_user" "example" {
#   name                 = "user1"
#   storage_account_id   = azurerm_storage_account.example.id
#   ssh_key_enabled      = true
#   ssh_password_enabled = true
#   home_directory       = "example_path"
#   ssh_authorized_key {
#     description = "key1"
#     key         = local.first_public_key
#   }
#   ssh_authorized_key {
#     description = "key2"
#     key         = local.second_public_key
#   }
#   permission_scope {
#     permissions {
#       read   = true
#       create = true
#     }
#     service       = "blob"
#     resource_name = azurerm_storage_container.example.name
#   }
# }
