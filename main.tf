terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.53.1"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "2.0.0-beta"
    }
  }
}

resource "random_integer" "affix" {
  min = 100
  max = 999
}

locals {
  affix    = random_integer.affix.result
  workload = "${var.project}${local.affix}"
}

resource "azurerm_resource_group" "default" {
  name     = "rg-${local.workload}"
  location = var.location
}

module "network" {
  source              = "./modules/network"
  workload            = local.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
}

module "monitor" {
  source              = "./modules/monitor"
  workload            = local.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
}

module "data_lake" {
  source              = "./modules/datalake"
  workload            = local.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  allowed_public_ips  = var.allowed_public_ips
  # datastores_service_principal_object_id = module.entra.service_principal_object_id
}

module "synapse" {
  source                               = "./modules/synapse"
  workload                             = local.workload
  resource_group_name                  = azurerm_resource_group.default.name
  location                             = azurerm_resource_group.default.location
  datalake_storage_account_id          = module.data_lake.storage_account_id
  storage_data_lake_gen2_filesystem_id = module.data_lake.synapse_filesystem_id
  allowed_public_ips                   = var.allowed_public_ips
  sql_pool_sku_name                    = var.synapse_sql_pool_sku_name
  spark_node_size_family               = var.synapse_spark_node_size_family
  spark_node_size                      = var.synapse_spark_node_size
  spark_node_count                     = var.synapse_spark_node_count
  sql_administrator_login              = var.synapse_administrator_login
  sql_administrator_password           = var.synapse_administrator_password
}

module "data_factory" {
  source              = "./modules/adf"
  workload            = local.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  datalake_storage_account_id   = module.data_lake.storage_account_id
  datalake_primary_dfs_endpoint = module.data_lake.primary_dfs_endpoint

  integration_runtime_cleanup_enabled = var.adf_integration_runtime_cleanup_enabled
  integration_runtime_compute_type    = var.adf_integration_runtime_compute_type
  integration_runtime_core_count      = var.adf_integration_runtime_core_count
  integration_runtime_ttl_min         = var.adf_integration_runtime_ttl_min

  synapse_workspace_id   = module.synapse.workspace_id
  synapse_principal_id   = module.synapse.workspace_principal_id
  synapse_workspace_name = module.synapse.workspace_name
  # synapse_pool001_name           = module.synapse.pool001_name
  synapse_administrator_login    = var.synapse_administrator_login
  synapse_administrator_password = var.synapse_administrator_password
}

# module "blobs" {
#   source                                 = "./modules/blob"
#   workload                               = local.workload
#   resource_group_name                    = azurerm_resource_group.default.name
#   location                               = azurerm_resource_group.default.location
#   ip_network_rules                       = local.allowed_ip_addresses
#   datastores_service_principal_object_id = module.entra.service_principal_object_id
#   subnet_id                              = module.vnet.default_subnet_id
# }

# module "mssql" {
#   source              = "./modules/mssql"
#   count               = var.mssql_create_flag ? 1 : 0
#   workload            = local.workload
#   resource_group_name = azurerm_resource_group.default.name
#   location            = azurerm_resource_group.default.location

#   sku                       = var.mssql_sku
#   max_size_gb               = var.mssql_max_size_gb
#   admin_login               = var.mssql_admin_login
#   admin_login_password      = var.mssql_admin_login_password
#   localfw_start_ip_address  = var.allowed_ip_address
#   localfw_end_ip_address    = var.allowed_ip_address
#   subnet_id                 = module.vnet.default_subnet_id
#   aml_identity_principal_id = module.ml_workspace.aml_identity_principal_id
# }

# module "ml_workspace" {
#   source              = "./modules/ml/workspace"
#   workload            = local.workload
#   resource_group_name = azurerm_resource_group.default.name
#   location            = azurerm_resource_group.default.location

#   public_network_access_enabled  = var.mlw_public_network_access_enabled
#   managed_network_isolation_mode = var.mlw_managed_network_isolation_mode
#   application_insights_id        = module.monitor.application_insights_id
#   storage_account_id             = module.storage.storage_account_id
#   key_vault_id                   = module.keyvault.key_vault_id
#   container_registry_id          = module.cr.id

#   data_lake_id = module.data_lake.id
#   blobs_id     = module.blobs.id
# }

# module "ml_private_endpoint" {
#   source              = "./modules/ml/private-endpoint"
#   count               = var.mlw_create_private_endpoint_flag ? 1 : 0
#   resource_group_name = azurerm_resource_group.default.name
#   location            = azurerm_resource_group.default.location
#   vnet_id             = module.vnet.vnet_id
#   subnet_id           = module.vnet.default_subnet_id
#   aml_workspace_id    = module.ml_workspace.aml_workspace_id
# }

# module "ml_compute" {
#   source = "./modules/ml/compute"
#   count  = var.mlw_instance_create_flag ? 1 : 0

#   machine_learning_workspace_id   = module.ml_workspace.aml_workspace_id
#   instance_vm_size                = var.mlw_instance_vm_size
#   instance_node_public_ip_enabled = var.mlw_instance_node_public_ip_enabled
#   ssh_public_key                  = local.ssh_public_key
# }

# module "vm" {
#   source              = "./modules/vm"
#   count               = var.vm_create_flag ? 1 : 0
#   workload            = local.workload
#   resource_group_name = azurerm_resource_group.default.name
#   location            = azurerm_resource_group.default.location
#   size                = var.vm_size
#   subnet              = module.vnet.default_subnet_id
# }
