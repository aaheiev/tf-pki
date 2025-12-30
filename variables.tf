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
