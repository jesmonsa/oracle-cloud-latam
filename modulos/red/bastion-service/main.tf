terraform {
  required_version = ">= 1.0.0"
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}
locals {
  prefijo = "${var.proyecto}-${var.ambiente}"
  tags_comunes = merge(var.tags, {
    Modulo = "red-bastion-service"
  })
}

resource "oci_bastion_bastion" "bastion" {
  bastion_type                 = "STANDARD"
  compartment_id               = var.compartment_id
  target_subnet_id             = var.subnet_id
  client_cidr_block_allow_list = var.cidr_permitidos
  max_session_ttl_in_seconds   = var.tiempo_max_sesion_segundos
  name                         = "${local.prefijo}-bastion"
  freeform_tags                = local.tags_comunes
}

