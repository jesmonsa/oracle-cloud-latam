terraform {
  required_providers {
    oci = {
      source                = "oracle/oci"
      configuration_aliases = [oci.region1, oci.region2]
    }
  }
}

locals {
  prefijo      = "${var.proyecto}-${var.ambiente}"
  tags_comunes = merge(var.tags, { Modulo = "red-peering-remoto" })
}

resource "oci_core_drg" "drg_region1" {
  provider       = oci.region1
  compartment_id = var.compartment_id
  display_name   = "${local.prefijo}-drg-${var.region1}"
  freeform_tags  = local.tags_comunes
}

resource "oci_core_drg_attachment" "drg_attach_region1" {
  provider = oci.region1
  drg_id   = oci_core_drg.drg_region1.id
  vcn_id   = var.vcn_id_region1
}

resource "oci_core_remote_peering_connection" "rpc_region1" {
  provider         = oci.region1
  compartment_id   = var.compartment_id
  drg_id           = oci_core_drg.drg_region1.id
  display_name     = "${local.prefijo}-rpc-${var.region1}"
  peer_id          = oci_core_remote_peering_connection.rpc_region2.id
  peer_region_name = var.region2
  freeform_tags    = local.tags_comunes
}

resource "oci_core_drg" "drg_region2" {
  provider       = oci.region2
  compartment_id = var.compartment_id
  display_name   = "${local.prefijo}-drg-${var.region2}"
  freeform_tags  = local.tags_comunes
}

resource "oci_core_drg_attachment" "drg_attach_region2" {
  provider = oci.region2
  drg_id   = oci_core_drg.drg_region2.id
  vcn_id   = var.vcn_id_region2
}

resource "oci_core_remote_peering_connection" "rpc_region2" {
  provider       = oci.region2
  compartment_id = var.compartment_id
  drg_id         = oci_core_drg.drg_region2.id
  display_name   = "${local.prefijo}-rpc-${var.region2}"
  freeform_tags  = local.tags_comunes
}
