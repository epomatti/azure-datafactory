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

variable "pool_sku_name" {
  type = string
}

variable "sql_administrator_login" {
  type = string
}

variable "sql_administrator_password" {
  type      = string
  sensitive = true
}
