variable "resource_group_name" {
  type = string
}

variable "location" {
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
