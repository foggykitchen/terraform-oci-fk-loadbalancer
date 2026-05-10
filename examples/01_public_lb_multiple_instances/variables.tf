variable "tenancy_ocid" {
  type = string
}

variable "user_ocid" {
  type = string
}

variable "fingerprint" {
  type = string
}

variable "private_key_path" {
  type = string
}

variable "region" {
  type = string
}

variable "compartment_ocid" {
  type = string
}

variable "instance_count" {
  type    = number
  default = 2

  validation {
    condition     = var.instance_count >= 2
    error_message = "instance_count must be at least 2."
  }
}
