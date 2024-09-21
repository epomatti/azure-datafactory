terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }
  }
}

resource "azurerm_data_factory" "default" {
  name                   = "adf-${var.workload}"
  location               = var.location
  resource_group_name    = var.resource_group_name
  public_network_enabled = true

  managed_virtual_network_enabled = true

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_factory_managed_private_endpoint" "datalake" {
  name               = "datalake"
  data_factory_id    = azurerm_data_factory.default.id
  target_resource_id = var.datalake_storage_account_id
  subresource_name   = "dfs"
}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "lake" {
  name                 = "Lake"
  data_factory_id      = azurerm_data_factory.default.id
  url                  = var.datalake_primary_dfs_endpoint
  use_managed_identity = true
}

resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  scope                = var.datalake_storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_factory.default.identity[0].principal_id
}

resource "azurerm_role_assignment" "storage_blob_data_owner" {
  scope                = var.datalake_storage_account_id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_data_factory.default.identity[0].principal_id
}


resource "azurerm_data_factory_integration_runtime_azure" "integratin_runtime_001" {
  name                    = "IntegrationRuntime001"
  data_factory_id         = azurerm_data_factory.default.id
  location                = var.location
  cleanup_enabled         = var.integration_runtime_cleanup_enabled
  compute_type            = var.integration_runtime_compute_type
  core_count              = var.integration_runtime_core_count
  time_to_live_min        = var.integration_runtime_ttl_min
  virtual_network_enabled = true
}

# locals {
#   data_lake_name = azurerm_data_factory_linked_service_data_lake_storage_gen2.lake.name
# }

# Stage 1
# resource "azapi_resource" "zip_source" {
#   type      = "Microsoft.DataFactory/factories/datasets@2018-06-01"
#   name      = "TokyoZipSourceDataset"
#   parent_id = azurerm_data_factory.default.id
#   body = jsonencode({
#     "properties" : {
#       "linkedServiceName" : {
#         "referenceName" : "${local.data_lake_name}",
#         "type" : "LinkedServiceReference"
#       },
#       "annotations" : [],
#       "type" : "Binary",
#       "typeProperties" : {
#         "location" : {
#           "type" : "AzureBlobFSLocation",
#           "fileName" : "tokyo2011.zip",
#           "fileSystem" : "raw-source"
#         },
#         "compression" : {
#           "type" : "ZipDeflate"
#         }
#       }
#     }
#   })
# }

# resource "azapi_resource" "unzip_sink" {
#   type      = "Microsoft.DataFactory/factories/datasets@2018-06-01"
#   name      = "TokyoUnzipDataset"
#   parent_id = azurerm_data_factory.default.id
#   body = jsonencode({
#     "properties" : {
#       "linkedServiceName" : {
#         "referenceName" : "${local.data_lake_name}",
#         "type" : "LinkedServiceReference"
#       },
#       "annotations" : [],
#       "type" : "Binary",
#       "typeProperties" : {
#         "location" : {
#           "type" : "AzureBlobFSLocation",
#           "fileSystem" : "raw-data"
#         },
#       },
#       "schema" : []
#     }
#   })
# }

# resource "azapi_resource" "excel_raw_source" {
#   type      = "Microsoft.DataFactory/factories/datasets@2018-06-01"
#   name      = "TokyoExcelRaw"
#   parent_id = azurerm_data_factory.default.id
#   body = jsonencode({
#     "properties" : {
#       "type" : "Excel",
#       "linkedServiceName" : {
#         "referenceName" : "${local.data_lake_name}",
#         "type" : "LinkedServiceReference"
#       },
#       "schema" : [],
#       "typeProperties" : {
#         "location" : {
#           "type" : "AzureBlobFSLocation",
#           "fileName" : "*.xlsx",
#           "fileSystem" : "raw-data"
#         },
#         "sheetIndex" : 0,
#         "firstRowAsHeader" : true
#       }
#     }
#   })
# }

# resource "azapi_resource" "csv_sink" {
#   type      = "Microsoft.DataFactory/factories/datasets@2018-06-01"
#   name      = "TokyoCSVSink"
#   parent_id = azurerm_data_factory.default.id
#   body = jsonencode({
#     "properties" : {
#       "linkedServiceName" : {
#         "referenceName" : "${local.data_lake_name}",
#         "type" : "LinkedServiceReference"
#       },
#       "annotations" : [],
#       "type" : "DelimitedText",
#       "typeProperties" : {
#         "location" : {
#           "type" : "AzureBlobFSLocation",
#           "fileSystem" : "staged-data"
#         },
#         "columnDelimiter" : ",",
#         "escapeChar" : "\\",
#         "firstRowAsHeader" : true,
#         "quoteChar" : "\"",
#       },
#       "schema" : []
#     }
#   })
# }

# resource "azapi_resource" "prepare" {
#   type      = "Microsoft.DataFactory/factories/pipelines@2018-06-01"
#   name      = "PrepareForDatabricks"
#   parent_id = azurerm_data_factory.default.id
#   body = jsonencode({
#     "properties" : {
#       "activities" : [
#         {
#           "name" : "Unzip",
#           "type" : "Copy",
#           "dependsOn" : [],
#           "policy" : {
#             "timeout" : "0.12:00:00",
#             "retry" : 0,
#             "retryIntervalInSeconds" : 30,
#             "secureOutput" : false,
#             "secureInput" : false
#           },
#           "userProperties" : [],
#           "typeProperties" : {
#             "source" : {
#               "type" : "BinarySource",
#               "storeSettings" : {
#                 "type" : "AzureBlobFSReadSettings",
#                 "recursive" : true
#               },
#               "formatSettings" : {
#                 "type" : "BinaryReadSettings",
#                 "compressionProperties" : {
#                   "type" : "ZipDeflateReadSettings",
#                   "preserveZipFileNameAsFolder" : false,
#                 }
#               }
#             },
#             "sink" : {
#               "type" : "BinarySink",
#               "storeSettings" : {
#                 "type" : "AzureBlobFSWriteSettings",
#                 "copyBehavior" : "PreserveHierarchy"
#               }
#             },
#             "enableStaging" : false
#           },
#           "inputs" : [
#             {
#               "referenceName" : "${azapi_resource.zip_source.name}",
#               "type" : "DatasetReference"
#             }
#           ],
#           "outputs" : [
#             {
#               "referenceName" : "${azapi_resource.unzip_sink.name}",
#               "type" : "DatasetReference"
#             }
#           ]
#         },
#         {
#           "name" : "Convert Excel to CSV",
#           "type" : "Copy",
#           "dependsOn" : [
#             {
#               "activity" : "Unzip",
#               "dependencyConditions" : [
#                 "Succeeded"
#               ]
#             }
#           ],
#           "policy" : {
#             "timeout" : "0.12:00:00",
#             "retry" : 0,
#             "retryIntervalInSeconds" : 30,
#             "secureOutput" : false,
#             "secureInput" : false
#           },
#           "userProperties" : [],
#           "typeProperties" : {
#             "source" : {
#               "type" : "ExcelSource",
#               "storeSettings" : {
#                 "type" : "AzureBlobFSReadSettings",
#                 "recursive" : false,
#                 "wildcardFileName" : "*.xlsx"
#               }
#             },
#             "sink" : {
#               "type" : "DelimitedTextSink",
#               "storeSettings" : {
#                 "type" : "AzureBlobFSWriteSettings"
#               },
#               "formatSettings" : {
#                 "type" : "DelimitedTextWriteSettings",
#                 "quoteAllText" : true,
#                 "fileExtension" : ".csv"
#               }
#             },
#             "enableStaging" : false,
#             "translator" : {
#               "type" : "TabularTranslator",
#               "typeConversion" : true,
#               "typeConversionSettings" : {
#                 "allowDataTruncation" : true,
#                 "treatBooleanAsNumber" : false
#               }
#             }
#           },
#           "inputs" : [
#             {
#               "referenceName" : "${azapi_resource.excel_raw_source.name}",
#               "type" : "DatasetReference"
#             }
#           ],
#           "outputs" : [
#             {
#               "referenceName" : "${azapi_resource.csv_sink.name}",
#               "type" : "DatasetReference"
#             }
#           ]
#         }
#       ],
#       "annotations" : []
#     }
#   })
# }
