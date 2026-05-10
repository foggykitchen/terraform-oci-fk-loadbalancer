locals {
  load_balancer_name = coalesce(var.display_name, var.name)
  backend_set_name   = coalesce(var.backend_set_name, "${var.name}_backendset")
  use_flexible_shape = lower(var.shape) == "flexible"
}

resource "oci_load_balancer_load_balancer" "this" {
  compartment_id             = var.compartment_ocid
  display_name               = local.load_balancer_name
  shape                      = var.shape
  subnet_ids                 = var.subnet_ids
  is_private                 = var.is_private
  network_security_group_ids = var.network_security_group_ids
  defined_tags               = var.defined_tags
  freeform_tags              = var.freeform_tags

  dynamic "shape_details" {
    for_each = local.use_flexible_shape ? [var.shape_details] : []

    content {
      minimum_bandwidth_in_mbps = shape_details.value.minimum_bandwidth_in_mbps
      maximum_bandwidth_in_mbps = shape_details.value.maximum_bandwidth_in_mbps
    }
  }

  dynamic "reserved_ips" {
    for_each = (!var.is_private && var.reserved_public_ip_id != null) ? [var.reserved_public_ip_id] : []

    content {
      id = reserved_ips.value
    }
  }

  lifecycle {
    precondition {
      condition     = !local.use_flexible_shape || var.shape_details.maximum_bandwidth_in_mbps >= var.shape_details.minimum_bandwidth_in_mbps
      error_message = "shape_details.maximum_bandwidth_in_mbps must be greater than or equal to minimum_bandwidth_in_mbps."
    }

    precondition {
      condition     = !var.is_private || var.reserved_public_ip_id == null
      error_message = "reserved_public_ip_id is supported only for public load balancers."
    }
  }
}

resource "oci_load_balancer_backend_set" "this" {
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  name             = local.backend_set_name
  policy           = var.backend_policy

  health_checker {
    protocol            = var.health_checker.protocol
    port                = try(var.health_checker.port, null)
    interval_ms         = try(var.health_checker.interval_ms, null)
    retries             = try(var.health_checker.retries, null)
    timeout_in_millis   = try(var.health_checker.timeout_in_millis, null)
    return_code         = try(var.health_checker.return_code, null)
    response_body_regex = try(var.health_checker.response_body_regex, null)
    url_path            = try(var.health_checker.protocol, null) == "HTTP" ? try(var.health_checker.url_path, "/") : null
  }

  dynamic "lb_cookie_session_persistence_configuration" {
    for_each = var.session_persistence == null ? [] : [var.session_persistence]

    content {
      cookie_name        = try(lb_cookie_session_persistence_configuration.value.cookie_name, null)
      disable_fallback   = try(lb_cookie_session_persistence_configuration.value.disable_fallback, null)
      domain             = try(lb_cookie_session_persistence_configuration.value.domain, null)
      is_http_only       = try(lb_cookie_session_persistence_configuration.value.is_http_only, null)
      is_secure          = try(lb_cookie_session_persistence_configuration.value.is_secure, null)
      max_age_in_seconds = try(lb_cookie_session_persistence_configuration.value.max_age_in_seconds, null)
      path               = try(lb_cookie_session_persistence_configuration.value.path, null)
    }
  }
}

resource "oci_load_balancer_listener" "this" {
  load_balancer_id         = oci_load_balancer_load_balancer.this.id
  name                     = var.listener.name
  default_backend_set_name = oci_load_balancer_backend_set.this.name
  port                     = var.listener.port
  protocol                 = var.listener.protocol

  dynamic "connection_configuration" {
    for_each = try(var.listener.idle_timeout_in_seconds, null) == null ? [] : [var.listener.idle_timeout_in_seconds]

    content {
      idle_timeout_in_seconds = connection_configuration.value
    }
  }
}

resource "oci_load_balancer_backend" "this" {
  for_each = var.backends

  load_balancer_id = oci_load_balancer_load_balancer.this.id
  backendset_name  = oci_load_balancer_backend_set.this.name
  ip_address       = each.value.ip_address
  port             = each.value.port
  backup           = each.value.backup
  drain            = each.value.drain
  offline          = each.value.offline
  weight           = each.value.weight
}
