variable "name" {
  description = "Base display name used for OCI Load Balancer resources."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must not be empty."
  }
}

variable "compartment_ocid" {
  description = "Compartment OCID where the load balancer resources will be created."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet OCIDs used by the load balancer."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "subnet_ids must contain at least one subnet OCID."
  }
}

variable "display_name" {
  description = "Optional display name override for the load balancer."
  type        = string
  default     = null
}

variable "is_private" {
  description = "Whether the load balancer should get a private IP instead of a public IP."
  type        = bool
  default     = false
}

variable "network_security_group_ids" {
  description = "Optional NSG OCIDs associated with the load balancer."
  type        = list(string)
  default     = []
}

variable "shape" {
  description = "OCI Load Balancer shape. Flexible is the recommended default."
  type        = string
  default     = "flexible"
}

variable "shape_details" {
  description = "Bandwidth settings used when shape is flexible."
  type = object({
    minimum_bandwidth_in_mbps = number
    maximum_bandwidth_in_mbps = number
  })
  default = {
    minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 100
  }
}

variable "reserved_public_ip_id" {
  description = "Optional reserved public IP OCID attached to a public load balancer."
  type        = string
  default     = null
}

variable "backend_set_name" {
  description = "Optional backend set name override."
  type        = string
  default     = null
}

variable "backend_policy" {
  description = "Load balancing policy for the backend set."
  type        = string
  default     = "ROUND_ROBIN"
}

variable "health_checker" {
  description = "Health checker configuration for the backend set."
  type = object({
    protocol            = string
    port                = optional(number)
    interval_ms         = optional(number, 10000)
    retries             = optional(number, 3)
    timeout_in_millis   = optional(number, 3000)
    return_code         = optional(number)
    response_body_regex = optional(string)
    url_path            = optional(string)
  })
  default = {
    protocol = "HTTP"
    port     = 80
    url_path = "/"
  }

  validation {
    condition     = contains(["HTTP", "TCP"], var.health_checker.protocol)
    error_message = "health_checker.protocol must be either HTTP or TCP."
  }
}

variable "listener" {
  description = "Listener configuration."
  type = object({
    name                    = optional(string, "listener")
    port                    = number
    protocol                = string
    idle_timeout_in_seconds = optional(number)
  })
  default = {
    name     = "listener"
    port     = 80
    protocol = "HTTP"
  }

  validation {
    condition     = contains(["HTTP", "HTTP2", "TCP"], var.listener.protocol)
    error_message = "listener.protocol must be HTTP, HTTP2, or TCP."
  }
}

variable "session_persistence" {
  description = "Optional LB cookie session persistence configuration."
  type = object({
    cookie_name        = optional(string)
    disable_fallback   = optional(bool)
    domain             = optional(string)
    is_http_only       = optional(bool)
    is_secure          = optional(bool)
    max_age_in_seconds = optional(number)
    path               = optional(string)
  })
  default = null
}

variable "backends" {
  description = "Optional map of static backend definitions keyed by a logical backend name."
  type = map(object({
    ip_address = string
    port       = number
    backup     = optional(bool, false)
    drain      = optional(bool, false)
    offline    = optional(bool, false)
    weight     = optional(number, 1)
  }))
  default = {}
}

variable "defined_tags" {
  description = "Defined tags applied to resources created by the module."
  type        = map(string)
  default     = {}
}

variable "freeform_tags" {
  description = "Freeform tags applied to resources created by the module."
  type        = map(string)
  default     = {}
}
