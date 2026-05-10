output "load_balancer_id" {
  description = "OCI Load Balancer OCID."
  value       = oci_load_balancer_load_balancer.this.id
}

output "load_balancer_name" {
  description = "OCI Load Balancer display name."
  value       = oci_load_balancer_load_balancer.this.display_name
}

output "load_balancer_ip_addresses" {
  description = "All IP address records assigned to the load balancer."
  value       = oci_load_balancer_load_balancer.this.ip_address_details
}

output "load_balancer_public_ips" {
  description = "Public IP addresses assigned to the load balancer."
  value = [
    for ip in oci_load_balancer_load_balancer.this.ip_address_details : ip.ip_address
    if try(ip.is_public, false)
  ]
}

output "load_balancer_private_ips" {
  description = "Private IP addresses assigned to the load balancer."
  value = [
    for ip in oci_load_balancer_load_balancer.this.ip_address_details : ip.ip_address
    if !try(ip.is_public, true)
  ]
}

output "backend_set_name" {
  description = "Backend set name."
  value       = oci_load_balancer_backend_set.this.name
}

output "backend_set_id" {
  description = "Backend set ID."
  value       = oci_load_balancer_backend_set.this.id
}

output "listener_name" {
  description = "Listener name."
  value       = oci_load_balancer_listener.this.name
}

output "listener_id" {
  description = "Listener ID."
  value       = oci_load_balancer_listener.this.id
}

output "backend_ids" {
  description = "Map of static backend keys to backend resource IDs."
  value = {
    for key, backend in oci_load_balancer_backend.this : key => backend.id
  }
}

output "lb_attachment" {
  description = "Object that can be passed into terraform-oci-fk-compute lb_attachment."
  value = {
    load_balancer_id = oci_load_balancer_load_balancer.this.id
    backendset_name  = oci_load_balancer_backend_set.this.name
    port             = var.listener.port
  }
}
