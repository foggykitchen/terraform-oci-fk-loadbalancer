# Examples

This directory contains runnable Terraform/OpenTofu examples for `terraform-oci-fk-loadbalancer`.

| Example | Description |
|--------|-------------|
| `01_public_lb_multiple_instances` | Public OCI Load Balancer with `2+` regular compute instances attached as static backends by private IP |
| `02_public_lb_instance_pool` | Public OCI Load Balancer integrated with an OCI instance pool and autoscaling managed by `terraform-oci-fk-compute` |

The examples are intentionally progressive:
- `01_public_lb_multiple_instances` focuses on the simplest load balancing pattern with independently managed backend instances.
- `02_public_lb_instance_pool` shows the OCI-native pattern where backend membership is managed through an instance pool and load balancer attachment.
