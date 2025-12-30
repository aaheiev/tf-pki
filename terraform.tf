terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
    }
    tls = {
      source = "hashicorp/tls"
    }
    random = {
      source = "hashicorp/random"
    }
    pkcs12 = {
      source = "chilicat/pkcs12"
    }
    time = {
      source = "hashicorp/time"
    }
    null = {
      source  = "hashicorp/null"
    }
  }
}
