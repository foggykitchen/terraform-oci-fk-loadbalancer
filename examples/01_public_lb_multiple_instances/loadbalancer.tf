module "loadbalancer" {
  source = "git::https://github.com/foggykitchen/terraform-oci-fk-loadbalancer.git?ref=v1.0.0"

  name             = "fk-lb-multiple"
  compartment_ocid = var.compartment_ocid
  subnet_ids       = [module.vcn.subnet_ids["fk_lb_public_subnet"]]

  health_checker = {
    protocol = "HTTP"
    port     = 80
    url_path = "/"
  }

  listener = {
    name     = "http"
    port     = 80
    protocol = "HTTP"
  }

  backends = {
    for index, instance in module.compute :
    "app${index + 1}" => {
      ip_address = instance.instance_private_ip
      port       = 80
    }
  }
}
