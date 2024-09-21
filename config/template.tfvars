location = "eastus2"
project  = "litware"

subscription_id    = ""
allowed_public_ips = [""]

adf_integration_runtime_cleanup_enabled = true
adf_integration_runtime_compute_type    = "General"
adf_integration_runtime_core_count      = 8
adf_integration_runtime_ttl_min         = 0

synapse_sql_pool_sku_name      = "DW100c"
synapse_spark_node_size_family = "MemoryOptimized"
synapse_spark_node_size        = "Small"
synapse_spark_node_count       = 3
synapse_administrator_login    = "sqladminuser"
synapse_administrator_password = "P@ssw0rd1234"
