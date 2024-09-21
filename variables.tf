variable "subscription_id" {
  type = string
}

variable "location" {
  type    = string
  default = "eastus2"
}

variable "project" {
  type    = string
  default = "litware"
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

variable "synapse_sql_pool" {
  type = string
}
