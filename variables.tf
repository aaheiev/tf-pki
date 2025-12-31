variable "ca_key_rsa_bits" {
  type    = number
  default = 4096
}

variable "key_rsa_bits" {
  type    = number
  default = 2048
}

variable "root_ca_validity_period_hours" {
  type    = number
  default = 365 * 24 * 10
}

variable "rotate_root_ca" {
  type    = bool
  default = false
}

variable "rotate_root_ca_hours_before_expiry" {
  type    = number
  default = 30 * 24
}

variable "rotate_intermediate_ca" {
  type    = bool
  default = false
}

variable "intermediate_ca_validity_period_hours" {
  type    = number
  default = 365 * 24 * 5
}

variable "rotate_intermediate_ca_hours_before_expiry" {
  type    = number
  default = 14 * 24
}

variable "rotate_server_cert" {
  type    = bool
  default = false
}

variable "server_host_name" {
  type    = string
  default = "api.simple-site1.com"
}

variable "server_cert_validity_period_hours" {
  type    = number
  default = 365 * 24
}

variable "rotate_server_cert_hours_before_expiry" {
  type    = number
  default = 7 * 24
}

variable "rotate_client_cert" {
  type    = bool
  default = false
}

variable "client_cert_validity_period_hours" {
  type    = number
  default = 365 * 24
}

variable "client_server_cert_hours_before_expiry" {
  type    = number
  default = 7 * 24
}

variable "client_name" {
  type    = string
  default = "client"
}
