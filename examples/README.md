# OCI Load Balancer with Terraform/OpenTofu - Training Examples

This directory contains runnable examples for the **terraform-oci-fk-loadbalancer** module.
The examples focus on practical OCI Load Balancer deployment patterns, from multiple regular backend instances to instance pool integration with autoscaling.

These examples are part of the **[FoggyKitchen.com training ecosystem](https://foggykitchen.com/courses-2/)** and are used across OCI and multicloud courses covering networking, traffic distribution, compute integration, and architecture fundamentals.

---

## Published Examples

| Example | Title | Key Topics |
|:-------:|:------|:-----------|
| 01 | **Public LB with Multiple Instances** | OCI Load Balancer, public frontend IP, static backends, private app subnet, `count`, cloud-init bootstrap |
| 02 | **Public LB with Instance Pool** | OCI Load Balancer, instance pool attachment, backend health, autoscaling, compute-driven LB integration |

---

## How to Use

The example directory contains:
- Terraform/OpenTofu configuration (`.tf`)
- A focused `README.md` explaining the goal of the example
- A minimal, runnable architecture

To run the multiple instances example:

```bash
cd examples/01_public_lb_multiple_instances
tofu init
tofu plan
tofu apply
```

To run the instance pool example:

```bash
cd examples/02_public_lb_instance_pool
tofu init
tofu plan
tofu apply
```

---

## Design Principles

- One example = one architectural goal
- No unused or placeholder resources
- Clear separation of concerns between networking, load balancing, and compute
- Examples designed to integrate with other modules such as VCN and Compute

---

## Related Resources

- [FoggyKitchen OCI Load Balancer Module (terraform-oci-fk-loadbalancer)](../)
- [FoggyKitchen OCI VCN Module (terraform-oci-fk-vcn)](https://github.com/foggykitchen/terraform-oci-fk-vcn)
- [FoggyKitchen OCI Compute Module (terraform-oci-fk-compute)](https://github.com/foggykitchen/terraform-oci-fk-compute)
- [FoggyKitchen Azure Load Balancer Module (terraform-az-fk-loadbalancer)](https://github.com/mlinxfeld/terraform-az-fk-loadbalancer)

---

## License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.
See [LICENSE](../LICENSE) for details.

---

© 2026 [FoggyKitchen.com](https://foggykitchen.com) - Cloud. Code. Clarity.
