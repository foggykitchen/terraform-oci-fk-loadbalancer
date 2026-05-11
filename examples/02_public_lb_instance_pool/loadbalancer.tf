module "loadbalancer" {
  source = "git::https://github.com/mlinxfeld/terraform-oci-fk-loadbalancer.git?ref=v1.0.0"

  name             = "fk-lb-pool"
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
}
