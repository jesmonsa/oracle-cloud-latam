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
    Modulo = "red-vcn"
  })
}

data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_vcn" "vcn" {
  compartment_id = var.compartment_id
  cidr_block     = var.vcn_cidr
  display_name   = "${local.prefijo}-vcn"
  dns_label      = "vcn${var.ambiente}"
  freeform_tags  = local.tags_comunes
}

resource "oci_core_internet_gateway" "ig" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${local.prefijo}-igw"
  enabled        = true
  freeform_tags  = local.tags_comunes
}

resource "oci_core_nat_gateway" "nat" {
  count          = var.habilitar_nat_gateway ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${local.prefijo}-nat"
  freeform_tags  = local.tags_comunes
}

resource "oci_core_service_gateway" "sgw" {
  count          = var.habilitar_service_gateway ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  services {
    service_id = data.oci_core_services.all_services.services[0].id
  }
  display_name  = "${local.prefijo}-sgw"
  freeform_tags = local.tags_comunes
}

resource "oci_core_route_table" "publica" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${local.prefijo}-rt-publica"
  freeform_tags  = local.tags_comunes

  route_rules {
    network_entity_id = oci_core_internet_gateway.ig.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_route_table" "privada" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${local.prefijo}-rt-privada"
  freeform_tags  = local.tags_comunes

  dynamic "route_rules" {
    for_each = var.habilitar_nat_gateway ? [1] : []
    content {
      network_entity_id = oci_core_nat_gateway.nat[0].id
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
    }
  }

  dynamic "route_rules" {
    for_each = var.habilitar_service_gateway ? [1] : []
    content {
      network_entity_id = oci_core_service_gateway.sgw[0].id
      destination       = data.oci_core_services.all_services.services[0].cidr_block
      destination_type  = "SERVICE_CIDR_BLOCK"
    }
  }
}

