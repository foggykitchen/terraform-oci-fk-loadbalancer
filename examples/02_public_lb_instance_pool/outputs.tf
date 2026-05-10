output "load_balancer_id" {
  value = module.loadbalancer.load_balancer_id
}

output "load_balancer_public_ips" {
  value = module.loadbalancer.load_balancer_public_ips
}

output "instance_pool_id" {
  value = module.compute.instance_pool_id
}

output "autoscaling_configuration_id" {
  value = module.compute.autoscaling_configuration_id
}
