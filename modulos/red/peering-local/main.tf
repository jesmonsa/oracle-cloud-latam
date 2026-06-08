terraform {
  required_version = ">= 1.0.0"
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

locals {
  prefijo      = "${var.proyecto}-${var.ambiente}"
  tags_comunes = merge(var.tags, { Modulo = "red-peering-local" })
}

resource "oci_core_local_peering_gateway" "lpg_vcn1" {
  compartment_id = var.compartment_id_vcn1
  vcn_id         = var.vcn_id_1
  display_name   = "${local.prefijo}-lpg-vcn1"
  peer_id        = oci_core_local_peering_gateway.lpg_vcn2.id
  freeform_tags  = local.tags_comunes
}

resource "oci_core_local_peering_gateway" "lpg_vcn2" {
  compartment_id = var.compartment_id_vcn2
  vcn_id         = var.vcn_id_2
  display_name   = "${local.prefijo}-lpg-vcn2"
  freeform_tags  = local.tags_comunes
}
