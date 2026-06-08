module "red" {
  source         = "../../modulos/red/vcn"
  compartment_id = var.compartment_ocid
  vcn_cidr       = var.vcn_cidr
  proyecto       = var.proyecto
  ambiente       = var.ambiente
  tags           = local.tags_comunes
}

module "nsgs" {
  source             = "../../modulos/seguridad/nsg"
  count              = var.habilitar_nsg ? 1 : 0
  compartment_id     = var.compartment_ocid
  vcn_id             = module.red.vcn_id
  proyecto           = var.proyecto
  ambiente           = var.ambiente
  habilitar_nsg_web  = true
  habilitar_nsg_ssh  = true
  cidr_ssh_permitido = var.ssh_cidr_permitido
  tags               = local.tags_comunes
}

# Si Security Lists se usan (habilitar_nsg = false), adjuntarlas a la subnet
resource "oci_core_security_list" "sl_publica" {
  count          = var.habilitar_nsg ? 0 : 1
  compartment_id = var.compartment_ocid
  vcn_id         = module.red.vcn_id
  display_name   = "${var.proyecto}-${var.ambiente}-sl-publica"
  freeform_tags  = local.tags_comunes

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.ssh_cidr_permitido
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }
}

# Si NSG = true, forzamos usar una Security List vacía para no usar el Default SL inseguro de la VCN
resource "oci_core_security_list" "sl_vacia" {
  count          = var.habilitar_nsg ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = module.red.vcn_id
  display_name   = "${var.proyecto}-${var.ambiente}-sl-vacia"
  freeform_tags  = local.tags_comunes
}

resource "oci_core_subnet" "publica" {
  compartment_id    = var.compartment_ocid
  vcn_id            = module.red.vcn_id
  cidr_block        = var.subnet_publica_cidr
  display_name      = "${var.proyecto}-${var.ambiente}-subnet-publica"
  dns_label         = "subpub"
  route_table_id    = module.red.route_table_publica_id
  security_list_ids = var.habilitar_nsg ? [oci_core_security_list.sl_vacia[0].id] : [oci_core_security_list.sl_publica[0].id]
  freeform_tags     = local.tags_comunes
}

module "webserver" {
  source             = "../../modulos/computo/webserver"
  compartment_id     = var.compartment_ocid
  subnet_id          = oci_core_subnet.publica.id
  ssh_public_key     = var.ssh_public_key
  proyecto           = var.proyecto
  ambiente           = var.ambiente
  shape              = var.shape_webserver
  ocpus              = var.ocpus_webserver
  memoria_gb         = var.memoria_webserver_gb
  asignar_ip_publica = true
  cantidad           = 1
  imagen_os          = var.imagen_os != "" ? var.imagen_os : data.oci_core_images.os_image.images[0].id
  nsg_ids            = var.habilitar_nsg ? module.nsgs[0].todos_nsg_ids : []
  tags               = local.tags_comunes
}

module "baselines" {
  source         = "../../modulos/seguridad/baselines"
  count          = var.habilitar_baseline_seguridad ? 1 : 0
  compartment_id = var.compartment_ocid
  tenancy_ocid   = var.tenancy_ocid
  proyecto       = var.proyecto
  ambiente       = var.ambiente
  tags           = local.tags_comunes
}
