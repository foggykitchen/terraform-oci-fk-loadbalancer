module "compute" {
  count  = var.instance_count
  source = "../../../terraform-oci-fk-compute"

  name             = "fk-lb-multiple-instance-${count.index + 1}"
  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  subnet_id        = module.vcn.subnet_ids["private_app"]

  deployment_mode = "instance"
  shape           = "VM.Standard.E4.Flex"
  shape_config = {
    ocpus         = 1
    memory_in_gbs = 8
  }

  user_data = base64encode(<<-EOF
    #cloud-config
    package_update: true
    package_upgrade: true

    packages:
      - nginx

    write_files:
      - path: /usr/share/nginx/html/index.html
        owner: root:root
        permissions: "0644"
        content: |
          <html>
          <head><title>FoggyKitchen OCI LB Demo</title></head>
          <body>
            <h1>It works</h1>
            <p>Served by: <b>__HOSTNAME__</b></p>
            <p>Private IP: <b>__PRIVATE_IP__</b></p>
            <p>Generated at: <b>__TIME__</b></p>
          </body>
          </html>

    runcmd:
      - [ bash, -lc, "PRIVATE_IP=$$(hostname -I | awk '{print $$1}'); HOSTNAME_VALUE=$$(hostname -f || hostname); TIMESTAMP=$$(date -Is); sed -i \"s/__HOSTNAME__/$${HOSTNAME_VALUE}/g\" /usr/share/nginx/html/index.html; sed -i \"s/__PRIVATE_IP__/$${PRIVATE_IP}/g\" /usr/share/nginx/html/index.html; sed -i \"s/__TIME__/$${TIMESTAMP}/g\" /usr/share/nginx/html/index.html" ]
      - [ systemctl, enable, nginx ]
      - [ systemctl, restart, nginx ]
      - [ bash, -lc, "firewall-cmd --permanent --add-service=http || true" ]
      - [ bash, -lc, "firewall-cmd --reload || true" ]
  EOF
  )
}
