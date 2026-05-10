module "vcn" {
  source = "git::https://github.com/mlinxfeld/terraform-oci-fk-vcn.git"

  compartment_ocid = var.compartment_ocid
  name             = "fk-lb-multiple-vcn"
  vcn_cidr_blocks  = ["10.80.0.0/16"]

  create_internet_gateway = true
  create_nat_gateway      = true
  create_service_gateway  = true

  route_tables = {
    public = {
      route_rules = [
        {
          destination        = "0.0.0.0/0"
          destination_type   = "CIDR_BLOCK"
          network_entity_key = "internet_gateway"
        }
      ]
    }
    private = {
      route_rules = [
        {
          destination        = "0.0.0.0/0"
          destination_type   = "CIDR_BLOCK"
          network_entity_key = "nat_gateway"
        },
        {
          destination        = "all-services"
          destination_type   = "SERVICE_CIDR_BLOCK"
          network_entity_key = "service_gateway"
        }
      ]
    }
  }

  security_lists = {
    lb_public = {
      ingress_rules = [
        {
          protocol = "6"
          source   = "0.0.0.0/0"
          tcp_options = {
            min = 80
            max = 80
          }
        },
      ]
      egress_rules = [
        {
          protocol    = "all"
          destination = "0.0.0.0/0"
        }
      ]
    }
    app_private = {
      ingress_rules = [
        {
          protocol = "6"
          source   = "10.80.10.0/24"
          tcp_options = {
            min = 80
            max = 80
          }
        },
      ]
      egress_rules = [
        {
          protocol    = "all"
          destination = "0.0.0.0/0"
        }
      ]
    }
  }

  subnets = {
    public_lb = {
      cidr_block                 = "10.80.10.0/24"
      route_table_key            = "public"
      security_list_keys         = ["lb_public"]
      prohibit_public_ip_on_vnic = false
    }
    private_app = {
      cidr_block                 = "10.80.20.0/24"
      route_table_key            = "private"
      security_list_keys         = ["app_private"]
      prohibit_internet_ingress  = true
      prohibit_public_ip_on_vnic = true
    }
  }
}
