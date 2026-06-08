# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Main - Alta Disponibilidad Multi-AD                                        ║
# ║  Arquitectura: VCN + 2 Subnets + 2 Webservers en ADs diferentes            ║
# ║  Fallback: Si la región tiene 1 AD, usa Fault Domains                       ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ─── Precondición: SSH en producción ─────────────────────────────────────────
resource "null_resource" "validacion_seguridad" {
  count = local.ssh_abierto_al_mundo && var.ambiente == "produccion" ? 1 : 0

  lifecycle {
    precondition {
      condition     = !local.ssh_abierto_al_mundo
      error_message = "ERROR: No se permite SSH abierto (0.0.0.0/0) en producción."
    }
  }
}

# ─── Red: VCN + Internet Gateway + Route Tables ─────────────────────────────
module "red" {
  source         = "../../modulos/red/vcn"
  compartment_id = var.compartment_ocid
  vcn_cidr       = var.vcn_cidr
  proyecto       = var.proyecto
  ambiente       = var.ambiente
  tags           = local.tags_comunes

  habilitar_nat_gateway     = false
  habilitar_service_gateway = false
}

# ─── Seguridad: Network Security Groups ───────────────────────────────────
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

# ─── Security List (cuando NSG está deshabilitado) ──────────────────────────
resource "oci_core_security_list" "sl_publica" {
  count          = var.habilitar_nsg ? 0 : 1
  compartment_id = var.compartment_ocid
  vcn_id         = module.red.vcn_id
  display_name   = "${local.prefijo}-sl-publica"
  freeform_tags  = local.tags_comunes

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    description = "Permitir todo tráfico de salida"
  }

  ingress_security_rules {
    protocol    = "6"
    source      = var.ssh_cidr_permitido
    description = "SSH desde CIDR permitido"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "HTTP desde cualquier origen"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "HTTPS desde cualquier origen"
    tcp_options {
      min = 443
      max = 443
    }
  }
}

# Security List vacía (cuando NSG maneja la seguridad)
resource "oci_core_security_list" "sl_vacia" {
  count          = var.habilitar_nsg ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = module.red.vcn_id
  display_name   = "${local.prefijo}-sl-vacia"
  freeform_tags  = local.tags_comunes
}

# ─── Subnet Pública AD1 ─────────────────────────────────────────────────────
resource "oci_core_subnet" "publica_ad1" {
  compartment_id      = var.compartment_ocid
  vcn_id              = module.red.vcn_id
  cidr_block          = var.subnet_publica_ad1_cidr
  display_name        = "${local.prefijo}-subnet-pub-ad1"
  dns_label           = "subpubad1"
  availability_domain = local.ad_instancia_1
  route_table_id      = module.red.route_table_publica_id
  freeform_tags       = local.tags_comunes

  security_list_ids = var.habilitar_nsg ? (
    [oci_core_security_list.sl_vacia[0].id]
    ) : (
    [oci_core_security_list.sl_publica[0].id]
  )
}

# ─── Subnet Pública AD2 ─────────────────────────────────────────────────────
resource "oci_core_subnet" "publica_ad2" {
  compartment_id      = var.compartment_ocid
  vcn_id              = module.red.vcn_id
  cidr_block          = var.subnet_publica_ad2_cidr
  display_name        = "${local.prefijo}-subnet-pub-ad2"
  dns_label           = "subpubad2"
  availability_domain = local.ad_instancia_2
  route_table_id      = module.red.route_table_publica_id
  freeform_tags       = local.tags_comunes

  security_list_ids = var.habilitar_nsg ? (
    [oci_core_security_list.sl_vacia[0].id]
    ) : (
    [oci_core_security_list.sl_publica[0].id]
  )
}

# ─── Webserver 1 (AD1) ──────────────────────────────────────────────────────
module "webserver_ad1" {
  source              = "../../modulos/computo/webserver"
  compartment_id      = var.compartment_ocid
  subnet_id           = oci_core_subnet.publica_ad1.id
  availability_domain = local.ad_instancia_1
  fault_domain        = local.fd_instancia_1
  ssh_public_key      = var.ssh_public_key
  proyecto            = var.proyecto
  ambiente            = var.ambiente
  shape               = var.shape_webserver
  ocpus               = var.ocpus_webserver
  memoria_gb          = var.memoria_webserver_gb
  asignar_ip_publica  = true
  cantidad            = 1
  imagen_os           = var.imagen_os != "" ? var.imagen_os : data.oci_core_images.os_image.images[0].id
  nsg_ids             = var.habilitar_nsg ? module.nsgs[0].todos_nsg_ids : []
  tags                = local.tags_comunes
}

# ─── Webserver 2 (AD2 o FD2) ────────────────────────────────────────────────
module "webserver_ad2" {
  source              = "../../modulos/computo/webserver"
  compartment_id      = var.compartment_ocid
  subnet_id           = oci_core_subnet.publica_ad2.id
  availability_domain = local.ad_instancia_2
  fault_domain        = local.fd_instancia_2
  ssh_public_key      = var.ssh_public_key
  proyecto            = var.proyecto
  ambiente            = var.ambiente
  shape               = var.shape_webserver
  ocpus               = var.ocpus_webserver
  memoria_gb          = var.memoria_webserver_gb
  asignar_ip_publica  = true
  cantidad            = 1
  imagen_os           = var.imagen_os != "" ? var.imagen_os : data.oci_core_images.os_image.images[0].id
  nsg_ids             = var.habilitar_nsg ? module.nsgs[0].todos_nsg_ids : []
  tags                = local.tags_comunes
}

# ─── Baselines de Seguridad (opcional) ──────────────────────────────────────
module "baselines" {
  source         = "../../modulos/seguridad/baselines"
  count          = var.habilitar_baseline_seguridad ? 1 : 0
  compartment_id = var.compartment_ocid
  tenancy_ocid   = var.tenancy_ocid
  proyecto       = var.proyecto
  ambiente       = var.ambiente
  tags           = local.tags_comunes
}
