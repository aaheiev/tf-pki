resource "null_resource" "rotate_client" {
  triggers = {
    rotate = var.rotate_client_cert ? timestamp() : ""
  }
}

locals {
  # Attribute rotation_hours value must be > 0
  client_crt_rotate_hrs = (var.client_cert_validity_period_hours - var.client_server_cert_hours_before_expiry) > 0 ? (var.client_cert_validity_period_hours - var.client_server_cert_hours_before_expiry) : 1
}

resource "time_rotating" "rotate_client" {
  rotation_hours = local.client_crt_rotate_hrs
}

resource "tls_private_key" "client" {
  algorithm = "RSA"
  rsa_bits  = var.key_rsa_bits
  lifecycle {
    replace_triggered_by = [
      null_resource.rotate_client.id
    ]
  }
}

resource "tls_cert_request" "client" {
  private_key_pem = tls_private_key.client.private_key_pem
  subject {
    country             = "NL"
    province            = "North Holland"
    locality            = "Amsterdam"
    common_name         = var.client_name
  }
}

resource "tls_locally_signed_cert" "client" {
  cert_request_pem      = tls_cert_request.client.cert_request_pem
  ca_private_key_pem    = tls_private_key.intermediate.private_key_pem
  ca_cert_pem           = tls_locally_signed_cert.intermediate.cert_pem
  is_ca_certificate     = false
  validity_period_hours = var.client_cert_validity_period_hours
  allowed_uses          = ["client_auth"]
  lifecycle {
    replace_triggered_by = [time_rotating.rotate_client.id]
  }
}

resource "local_file" "client_private_key" {
  filename        = "${local.certs_base_dir}/client.key"
  content         = tls_private_key.client.private_key_pem
  file_permission = "0600"
}

resource "local_file" "client_crt" {
  filename        = "${local.certs_base_dir}/client.crt"
  content         = tls_locally_signed_cert.client.cert_pem
  file_permission = "0644"
}
