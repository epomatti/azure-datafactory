variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "datalake_storage_account_id" {
  type = string
}

variable "storage_data_lake_gen2_filesystem_id" {
  type = string
}

variable "workload" {
  type = string
}

variable "allowed_public_ips" {
  type = list(string)
}

variable "sql_pool_sku_name" {
  type = string
}

variable "spark_node_size_family" {
  type = string
}

variable "spark_node_size" {
  type = string
}

variable "spark_node_count" {
  type = number
}

variable "sql_administrator_login" {
  type = string
}

variable "sql_administrator_password" {
  type      = string
  sensitive = true
}
