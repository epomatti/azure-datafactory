variable "subscription_id" {
  type = string
}

variable "location" {
  type = string
}

variable "project" {
  type = string
}

variable "allowed_public_ips" {
  type = list(string)
}

variable "adf_integration_runtime_cleanup_enabled" {
  type = bool
}

variable "adf_integration_runtime_compute_type" {
  type = string
}

variable "adf_integration_runtime_core_count" {
  type = number
}

variable "adf_integration_runtime_ttl_min" {
  type = number
}

variable "synapse_sql_pool_sku_name" {
  type = string
}

variable "synapse_spark_node_size_family" {
  type = string
}

variable "synapse_spark_node_count" {
  type = number
}

variable "synapse_spark_node_size" {
  type = string
}

variable "synapse_administrator_login" {
  type = string
}

variable "synapse_administrator_password" {
  type      = string
  sensitive = true
}
