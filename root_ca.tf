resource "null_resource" "rotate_root" {
  triggers = {
    rotate = var.rotate_root_ca ? timestamp() : ""
  }
}

locals {
  # Attribute rotation_hours value must be > 0
  root_rotate_hours = (var.root_ca_validity_period_hours - var.rotate_root_ca_hours_before_expiry) > 0 ? (var.root_ca_validity_period_hours - var.rotate_root_ca_hours_before_expiry) : 1
}

resource "time_rotating" "rotate_root" {
  rotation_hours = local.root_rotate_hours
}

resource "tls_private_key" "root_ca_private_key" {
  algorithm = "RSA"
  rsa_bits  = var.ca_key_rsa_bits
  lifecycle {
    replace_triggered_by = [
      null_resource.rotate_root.id
    ]
  }
}

resource "tls_self_signed_cert" "root_ca_cert" {
  private_key_pem   = tls_private_key.root_ca_private_key.private_key_pem
  is_ca_certificate = true
  subject {
    country     = "NL"
    province    = "North Holland"
    locality    = "Amsterdam"
    common_name = "root ca"
  }
  validity_period_hours = var.root_ca_validity_period_hours
  allowed_uses          = ["cert_signing", "crl_signing", ]
  lifecycle {
    replace_triggered_by = [time_rotating.rotate_root.id]
  }
}

# Save to local files
resource "local_file" "root_ca_private_key" {
  filename        = "${local.certs_base_dir}/root_ca.key"
  content         = tls_private_key.root_ca_private_key.private_key_pem
  file_permission = "0600"
}

resource "local_file" "root_ca_crt" {
  filename        = "${local.certs_base_dir}/root_ca.crt"
  content         = tls_self_signed_cert.root_ca_cert.cert_pem
  file_permission = "0600"
}
