variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "workload" {
  type = string
}

variable "network_ip_rules" {
  type = list(string)
}

# variable "databricks_service_principal_object_id" {
#   type = string
# }
