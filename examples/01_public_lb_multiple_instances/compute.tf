module "compute" {
  count  = var.instance_count
  source = "git::https://github.com/mlinxfeld/terraform-oci-fk-compute.git"

  name             = "fk-lb-multiple-instance-${count.index + 1}"
  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  subnet_id        = module.vcn.subnet_ids["private_app"]

  deployment_mode          = "instance"
  shape                    = "VM.Standard.E4.Flex"
  operating_system_version = "9"
  shape_config = {
    ocpus         = 1
    memory_in_gbs = 8
  }

  user_data = base64encode(<<-EOF
    #cloud-config
    write_files:
      - path: /opt/fk-demo/start-http.sh
        owner: root:root
        permissions: "0755"
        content: |
          #!/bin/bash
          set -euo pipefail
          mkdir -p /opt/fk-demo/www
          HOSTNAME_VALUE=$(hostname -f 2>/dev/null || hostname)
          PRIVATE_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
          TIMESTAMP=$(date -Is)
          if command -v python3 >/dev/null 2>&1; then
            PYTHON_BIN=$(command -v python3)
          elif [ -x /usr/libexec/platform-python ]; then
            PYTHON_BIN=/usr/libexec/platform-python
          elif command -v python >/dev/null 2>&1; then
            PYTHON_BIN=$(command -v python)
          else
            echo "No Python interpreter available for demo HTTP server" > /var/log/fk-demo-http.log
            exit 1
          fi
          cat > /opt/fk-demo/www/index.html <<HTML
          <html>
          <head><title>FoggyKitchen OCI LB Demo</title></head>
          <body>
            <h1>It works</h1>
            <p>Served by: <b>$${HOSTNAME_VALUE}</b></p>
            <p>Private IP: <b>$${PRIVATE_IP}</b></p>
            <p>Generated at: <b>$${TIMESTAMP}</b></p>
          </body>
          </html>
          HTML
          nohup "$${PYTHON_BIN}" -m http.server 80 --directory /opt/fk-demo/www >/var/log/fk-demo-http.log 2>&1 &

    runcmd:
      - [ bash, -lc, "systemctl disable --now firewalld || true" ]
      - [ bash, -lc, "pkill -f 'http.server 80' || true" ]
      - [ bash, -lc, "/opt/fk-demo/start-http.sh" ]
  EOF
  )
}
