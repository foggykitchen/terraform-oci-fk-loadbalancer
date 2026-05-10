# terraform-oci-fk-loadbalancer

This repository contains a reusable **Terraform/OpenTofu module** and progressive examples for deploying an **Oracle Cloud Infrastructure (OCI) Load Balancer** as a dedicated traffic distribution layer for OCI compute workloads.

It is part of the **[FoggyKitchen.com training ecosystem](https://foggykitchen.com/courses-2/)** and is designed to work cleanly with reusable infrastructure modules such as **`terraform-oci-fk-vcn`** and **`terraform-oci-fk-compute`**.

---

## Purpose

The goal of this module is to provide a **clean, composable, and educational reference implementation** for OCI load balancing:

- Focused on OCI-native Load Balancer primitives
- Suitable for both static backend registration and instance pool integration
- Designed for hands-on learning, module composition, and multicloud comparisons

This is **not** a full application delivery platform. It is a **learning-first, architecture-aware module**.

---

## What the module does

The module creates:

- OCI Load Balancer
- One backend set
- One listener
- Optional static IP-based backend registrations
- Optional LB cookie session persistence configuration
- Optional reserved public IP attachment for public load balancers

The module intentionally does **not** create:
- VCNs or subnets
- Compute instances
- Instance pools
- Autoscaling policies
- Certificates or HTTPS termination workflows
- WAF or API Gateway resources

Each of those concerns belongs in its own dedicated module.

---

## Repository Structure

```bash
terraform-oci-fk-loadbalancer/
├── examples/
│   ├── 01_public_lb_multiple_instances/
│   ├── 02_public_lb_instance_pool/
│   └── README.md
├── main.tf
├── inputs.tf
├── outputs.tf
├── versions.tf
├── LICENSE
└── README.md
```

All examples are runnable and demonstrate **incremental load balancing patterns**, starting from static backends and progressing to instance pool integration.

---

## Example Usage

### Public LB with static backends

```hcl
module "loadbalancer" {
  source = "git::https://github.com/mlinxfeld/terraform-oci-fk-loadbalancer.git?ref=v0.1.0"

  name             = "fk-public-lb"
  compartment_ocid = var.compartment_ocid
  subnet_ids       = [var.public_subnet_id]

  shape = "flexible"
  shape_details = {
    minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 100
  }

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
    app1 = {
      ip_address = "10.0.20.10"
      port       = 80
    }
    app2 = {
      ip_address = "10.0.20.11"
      port       = 80
    }
  }
}
```

### Public LB for instance pool attachment

```hcl
module "loadbalancer" {
  source = "git::https://github.com/mlinxfeld/terraform-oci-fk-loadbalancer.git?ref=v0.1.0"

  name             = "fk-public-lb"
  compartment_ocid = var.compartment_ocid
  subnet_ids       = [var.public_subnet_id]

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

module "compute" {
  source = "git::https://github.com/mlinxfeld/terraform-oci-fk-compute.git?ref=v0.1.0"

  name             = "fk-app-pool"
  compartment_ocid = var.compartment_ocid
  tenancy_ocid     = var.tenancy_ocid
  subnet_id        = var.private_subnet_id

  deployment_mode = "instance_pool"
  shape           = "VM.Standard.E4.Flex"
  shape_config = {
    ocpus         = 1
    memory_in_gbs = 8
  }

  lb_attachment = module.loadbalancer.lb_attachment
}
```

---

## Module Inputs

### Core inputs

| Variable | Type | Required | Description |
|--------|------|----------|-------------|
| `name` | `string` | ✅ | Base display name used for OCI Load Balancer resources |
| `compartment_ocid` | `string` | ✅ | OCI compartment OCID |
| `subnet_ids` | `list(string)` | ✅ | Subnet OCIDs used by the load balancer |
| `display_name` | `string` | ❌ | Optional display name override |
| `is_private` | `bool` | ❌ | Whether the load balancer should be private |
| `network_security_group_ids` | `list(string)` | ❌ | Optional NSG OCIDs associated with the load balancer |
| `defined_tags` | `map(string)` | ❌ | Defined tags |
| `freeform_tags` | `map(string)` | ❌ | Freeform tags |

### Capacity and addressing

| Variable | Type | Required | Description |
|--------|------|----------|-------------|
| `shape` | `string` | ❌ | OCI Load Balancer shape, `flexible` by default |
| `shape_details` | `object` | ❌ | Flexible shape bandwidth settings |
| `reserved_public_ip_id` | `string` | ❌ | Reserved public IP OCID for public load balancers |

### Backend set and listener

| Variable | Type | Required | Description |
|--------|------|----------|-------------|
| `backend_set_name` | `string` | ❌ | Optional backend set name override |
| `backend_policy` | `string` | ❌ | Load balancing policy for the backend set |
| `health_checker` | `object` | ❌ | Backend health checker configuration |
| `listener` | `object` | ❌ | Listener configuration |
| `session_persistence` | `object` | ❌ | Optional LB cookie session persistence configuration |

### Static backends

| Variable | Type | Required | Description |
|--------|------|----------|-------------|
| `backends` | `map(object)` | ❌ | Static backend definitions keyed by logical name |

### Backend object schema

```hcl
backends = map(object({
  ip_address = string
  port       = number
  backup     = optional(bool, false)
  drain      = optional(bool, false)
  offline    = optional(bool, false)
  weight     = optional(number, 1)
}))
```

### Health checker object schema

```hcl
health_checker = object({
  protocol            = string
  port                = optional(number)
  interval_ms         = optional(number, 10000)
  retries             = optional(number, 3)
  timeout_in_millis   = optional(number, 3000)
  return_code         = optional(number)
  response_body_regex = optional(string)
  url_path            = optional(string)
})
```

### Listener object schema

```hcl
listener = object({
  name                    = optional(string, "listener")
  port                    = number
  protocol                = string
  idle_timeout_in_seconds = optional(number)
})
```

---

## Outputs

| Output | Description |
|------|-------------|
| `load_balancer_id` | OCI Load Balancer OCID |
| `load_balancer_name` | OCI Load Balancer display name |
| `load_balancer_ip_addresses` | All IP address records assigned to the load balancer |
| `load_balancer_public_ips` | Public IP addresses assigned to the load balancer |
| `load_balancer_private_ips` | Private IP addresses assigned to the load balancer |
| `backend_set_name` | Backend set name |
| `backend_set_id` | Backend set ID |
| `listener_name` | Listener name |
| `listener_id` | Listener ID |
| `backend_ids` | Map of static backend keys to backend resource IDs |
| `lb_attachment` | Object that can be passed into `terraform-oci-fk-compute` as `lb_attachment` |

---

## Examples Overview

| Example | Description |
|-------|-------------|
| `01_public_lb_multiple_instances` | Public OCI Load Balancer with `2+` regular compute instances attached as static backends by private IP |
| `02_public_lb_instance_pool` | Public OCI Load Balancer integrated with an OCI instance pool and autoscaling managed by `terraform-oci-fk-compute` |

See [`examples/`](examples) for details.

---

## Design Philosophy

- Explicit over implicit
- Small modules over monoliths
- Traffic distribution as infrastructure, not application logic
- Optimized for **learning, reuse, and composition**

This makes the module useful for:
- OCI compute foundations
- instance pool integrations
- training material
- architecture workshops
- multicloud comparisons (Azure ↔ OCI)

---

## Related Modules & Training

- [terraform-oci-fk-vcn](https://github.com/mlinxfeld/terraform-oci-fk-vcn)
- [terraform-oci-fk-compute](https://github.com/mlinxfeld/terraform-oci-fk-compute)
- [terraform-az-fk-loadbalancer](https://github.com/mlinxfeld/terraform-az-fk-loadbalancer)

---

## License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.
See [LICENSE](LICENSE) for details.

---

© 2026 [FoggyKitchen.com](https://foggykitchen.com/courses-2/) - *Cloud. Code. Clarity.*
