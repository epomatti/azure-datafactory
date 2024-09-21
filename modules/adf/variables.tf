variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "workload" {
  type = string
}

variable "datalake_storage_account_id" {
  type = string
}

variable "datalake_primary_dfs_endpoint" {
  type = string
}

variable "integration_runtime_cleanup_enabled" {
  type = bool
}

variable "integration_runtime_compute_type" {
  type = string
}

variable "integration_runtime_core_count" {
  type = number
}

variable "integration_runtime_ttl_min" {
  type = number
}
