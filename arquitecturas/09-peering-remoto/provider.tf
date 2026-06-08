terraform {
  required_version = ">= 1.5.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 8.0"
    }
  }
}

provider "oci" {
  alias            = "region1"
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.current_user_ocid != "" ? var.current_user_ocid : null
  fingerprint      = var.fingerprint != "" ? var.fingerprint : null
  private_key_path = var.private_key_path != "" ? var.private_key_path : null
  region           = var.region
}

provider "oci" {
  alias            = "region2"
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.current_user_ocid != "" ? var.current_user_ocid : null
  fingerprint      = var.fingerprint != "" ? var.fingerprint : null
  private_key_path = var.private_key_path != "" ? var.private_key_path : null
  region           = var.region2
}
