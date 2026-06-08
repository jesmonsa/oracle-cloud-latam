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
  tags_comunes = merge(var.tags, { Modulo = "almacenamiento-filesystem-compartido" })
}

resource "oci_file_storage_file_system" "fs" {
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  display_name        = "${local.prefijo}-fss"
  freeform_tags       = local.tags_comunes
}

resource "oci_file_storage_mount_target" "mt" {
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  subnet_id           = var.subnet_id
  display_name        = "${local.prefijo}-mt"
  nsg_ids             = var.nsg_ids
  freeform_tags       = local.tags_comunes
}

resource "oci_file_storage_export_set" "es" {
  mount_target_id = oci_file_storage_mount_target.mt.id
  display_name    = "${local.prefijo}-es"
}

resource "oci_file_storage_export" "export" {
  export_set_id  = oci_file_storage_export_set.es.id
  file_system_id = oci_file_storage_file_system.fs.id
  path           = var.ruta_exportacion

  export_options {
    source          = var.cidr_permitido
    access          = "READ_WRITE"
    identity_squash = "NONE"
  }
}
