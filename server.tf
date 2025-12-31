resource "null_resource" "rotate_server" {
  triggers = {
    rotate = var.rotate_server_cert ? timestamp() : ""
  }
}

locals {
  # Attribute rotation_hours value must be > 0
  server_crt_rotate_hrs = (var.server_cert_validity_period_hours - var.rotate_server_cert_hours_before_expiry) > 0 ? (var.server_cert_validity_period_hours - var.rotate_server_cert_hours_before_expiry) : 1
}

resource "time_rotating" "rotate_server" {
  rotation_hours = local.server_crt_rotate_hrs
}

resource "tls_private_key" "server" {
  algorithm = "RSA"
  rsa_bits  = var.key_rsa_bits
  lifecycle {
    replace_triggered_by = [
      null_resource.rotate_server.id
    ]
  }
}

resource "tls_cert_request" "server" {
  private_key_pem = tls_private_key.server.private_key_pem
  dns_names       = [var.server_host_name]
  subject {
    country             = "NL"
    province            = "North Holland"
    locality            = "Amsterdam"
    common_name         = var.server_host_name
  }
}

resource "tls_locally_signed_cert" "server" {
  cert_request_pem      = tls_cert_request.server.cert_request_pem
  ca_private_key_pem    = tls_private_key.intermediate.private_key_pem
  ca_cert_pem           = tls_locally_signed_cert.intermediate.cert_pem
  is_ca_certificate     = false
  validity_period_hours = var.server_cert_validity_period_hours
  allowed_uses          = ["server_auth"]
  lifecycle {
    replace_triggered_by = [time_rotating.rotate_server.id]
  }
}

resource "local_file" "server_private_key" {
  filename        = "${local.certs_base_dir}/server.key"
  content         = tls_private_key.server.private_key_pem
  file_permission = "0600"
}

resource "local_file" "server_crt" {
  filename        = "${local.certs_base_dir}/server.crt"
  content         = tls_locally_signed_cert.server.cert_pem
  file_permission = "0644"
}
