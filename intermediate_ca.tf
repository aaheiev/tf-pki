resource "null_resource" "rotate_intermediate" {
  triggers = {
    rotate = var.rotate_intermediate_ca ? timestamp() : ""
  }
}

locals {
  # Attribute rotation_hours value must be > 0
  intermediate_rotate_hrs = (var.intermediate_ca_validity_period_hours - var.rotate_intermediate_ca_hours_before_expiry) > 0 ? (var.intermediate_ca_validity_period_hours - var.rotate_intermediate_ca_hours_before_expiry) : 1
}

resource "time_rotating" "rotate_intermediate" {
  rotation_hours = local.intermediate_rotate_hrs
}

resource "tls_private_key" "intermediate" {
  algorithm = "RSA"
  rsa_bits  = var.ca_key_rsa_bits
  lifecycle {
    replace_triggered_by = [
      null_resource.rotate_intermediate.id
    ]
  }
}

resource "tls_cert_request" "intermediate" {
  private_key_pem = tls_private_key.intermediate.private_key_pem
  subject {
    country             = "NL"
    province            = "North Holland"
    locality            = "Amsterdam"
    common_name         = "intermediate ca"
  }
}

resource "tls_locally_signed_cert" "intermediate" {
  cert_request_pem      = tls_cert_request.intermediate.cert_request_pem
  ca_private_key_pem    = tls_private_key.root_ca_private_key.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.root_ca_cert.cert_pem
  is_ca_certificate     = true
  validity_period_hours = var.intermediate_ca_validity_period_hours
  allowed_uses          = ["cert_signing", "crl_signing"]
  lifecycle {
    replace_triggered_by = [time_rotating.rotate_intermediate.id]
  }
}

# Save to local files
resource "local_file" "intermediate_ca_private_key" {
  filename        = "${local.certs_base_dir}/intermediate_ca.key"
  content         = tls_private_key.intermediate.private_key_pem
  file_permission = "0600"
}

resource "local_file" "intermediate_ca_crt" {
  filename        = "${local.certs_base_dir}/intermediate_ca.crt"
  content         = tls_locally_signed_cert.intermediate.cert_pem
  file_permission = "0600"
}

resource "local_file" "ca_cert" {
  filename        = "${local.certs_base_dir}/ca.crt"
  content         = join("", [tls_locally_signed_cert.intermediate.cert_pem, tls_self_signed_cert.root_ca_cert.cert_pem])
  file_permission = "0644"
}