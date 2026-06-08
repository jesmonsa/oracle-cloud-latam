terraform {
  required_version = ">= 1.5"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state"
    key            = "ai/gpu-cluster/terraform.tfstate"
    region         = "us-phoenix-1"
    endpoint       = "https://axxxxxxxxxxx.compat.objectstorage.oraclecloud.com"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "oci" {
  region              = var.region
  auth                = "APIKey"
  config_file_profile = var.oci_profile

  retry_duration_seconds = 30
}

provider "oci" {
  alias               = "home"
  region              = data.oci_identity_regions.home.regions[0].name
  auth                = "APIKey"
  config_file_profile = var.oci_profile
}

data "oci_identity_regions" "home" {
  provider = oci.home
  filter {
    name   = "is_home_region"
    values = [true]
  }
}

data "oci_identity_tenancy" "tenant" {
  provider   = oci.home
  tenancy_id = var.tenancy_id
}

data "oci_identity_compartment" "compartment" {
  id = var.compartment_id
}
