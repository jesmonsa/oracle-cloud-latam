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
  tags_comunes = merge(var.tags, { Modulo = "almacenamiento-block-volume" })
}

resource "oci_core_volume" "bv" {
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  display_name        = "${local.prefijo}-bv"
  size_in_gbs         = var.tamano_gb
  vpus_per_gb         = var.vpus_por_gb
  freeform_tags       = local.tags_comunes
}

resource "oci_core_volume_attachment" "bv_attach" {
  attachment_type = "iscsi"
  instance_id     = var.instancia_id
  volume_id       = oci_core_volume.bv.id
  display_name    = "${local.prefijo}-bv-attach"
}
