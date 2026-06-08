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
    Modulo = "seguridad-nsg"
  })
}

# ─── NSG Web (HTTP/HTTPS) ─────────────────────────────────────────────────

resource "oci_core_network_security_group" "nsg_web" {
  count          = var.habilitar_nsg_web ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${local.prefijo}-nsg-web"
  freeform_tags  = local.tags_comunes
}

resource "oci_core_network_security_group_security_rule" "nsg_web_http" {
  count                     = var.habilitar_nsg_web ? 1 : 0
  network_security_group_id = oci_core_network_security_group.nsg_web[0].id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }
}

resource "oci_core_network_security_group_security_rule" "nsg_web_https" {
  count                     = var.habilitar_nsg_web ? 1 : 0
  network_security_group_id = oci_core_network_security_group.nsg_web[0].id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}

# ─── NSG SSH ──────────────────────────────────────────────────────────────

resource "oci_core_network_security_group" "nsg_ssh" {
  count          = var.habilitar_nsg_ssh ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${local.prefijo}-nsg-ssh"
  freeform_tags  = local.tags_comunes
}

resource "oci_core_network_security_group_security_rule" "nsg_ssh_rule" {
  count                     = var.habilitar_nsg_ssh ? 1 : 0
  network_security_group_id = oci_core_network_security_group.nsg_ssh[0].id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = var.cidr_ssh_permitido
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

# ─── NSG Base de Datos (puerto 1521) ─────────────────────────────────────
# Soporta múltiples CIDRs origen (útil en arquitecturas de peering multi-región)

resource "oci_core_network_security_group" "nsg_db" {
  count          = var.habilitar_nsg_db ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${local.prefijo}-nsg-db"
  freeform_tags  = local.tags_comunes
}

resource "oci_core_network_security_group_security_rule" "nsg_db_rule" {
  for_each = var.habilitar_nsg_db ? toset(var.cidr_red_interna) : toset([])

  network_security_group_id = oci_core_network_security_group.nsg_db[0].id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = each.value
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 1521
      max = 1521
    }
  }
}

# ─── NSG NFS (File Storage Service) ──────────────────────────────────────
# Soporta múltiples CIDRs origen

resource "oci_core_network_security_group" "nsg_nfs" {
  count          = var.habilitar_nsg_nfs ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${local.prefijo}-nsg-nfs"
  freeform_tags  = local.tags_comunes
}

resource "oci_core_network_security_group_security_rule" "nsg_nfs_tcp_111" {
  for_each = var.habilitar_nsg_nfs ? toset(var.cidr_red_interna) : toset([])

  network_security_group_id = oci_core_network_security_group.nsg_nfs[0].id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = each.value
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 111
      max = 111
    }
  }
}

resource "oci_core_network_security_group_security_rule" "nsg_nfs_udp_111" {
  for_each = var.habilitar_nsg_nfs ? toset(var.cidr_red_interna) : toset([])

  network_security_group_id = oci_core_network_security_group.nsg_nfs[0].id
  direction                 = "INGRESS"
  protocol                  = "17" # UDP
  source                    = each.value
  source_type               = "CIDR_BLOCK"
  udp_options {
    destination_port_range {
      min = 111
      max = 111
    }
  }
}

resource "oci_core_network_security_group_security_rule" "nsg_nfs_tcp_2048" {
  for_each = var.habilitar_nsg_nfs ? toset(var.cidr_red_interna) : toset([])

  network_security_group_id = oci_core_network_security_group.nsg_nfs[0].id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = each.value
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 2048
      max = 2050
    }
  }
}

resource "oci_core_network_security_group_security_rule" "nsg_nfs_udp_2048" {
  for_each = var.habilitar_nsg_nfs ? toset(var.cidr_red_interna) : toset([])

  network_security_group_id = oci_core_network_security_group.nsg_nfs[0].id
  direction                 = "INGRESS"
  protocol                  = "17" # UDP
  source                    = each.value
  source_type               = "CIDR_BLOCK"
  udp_options {
    destination_port_range {
      min = 2048
      max = 2050
    }
  }
}

# ─── NSG Egress General (salida a Internet/OCI Services) ─────────────────

resource "oci_core_network_security_group" "nsg_egress" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${local.prefijo}-nsg-egress-general"
  freeform_tags  = local.tags_comunes
}

resource "oci_core_network_security_group_security_rule" "nsg_egress_all" {
  network_security_group_id = oci_core_network_security_group.nsg_egress.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}
