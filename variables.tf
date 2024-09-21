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

variable "allowed_public_cidrs" {
  type = list(string)
}
