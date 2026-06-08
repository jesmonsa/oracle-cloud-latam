# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  09 - Peering Remoto: Cross-Region DRG (Hub-Spoke)                         ║
# ║  Región 1 (Hub):   VCN 10.0.0.0/16 + LB + Webserver + Bastion            ║
# ║  Región 2 (Spoke): VCN 10.2.0.0/16 + Backend                              ║
# ║  Interconexión: DRG + Remote Peering Connection (RPC)                      ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ═══════════════════════════════════════════════════════════════════════════════
#  REDES VIRTUALES
# ═══════════════════════════════════════════════════════════════════════════════

module "red_hub" {
  source = "../../modulos/red/vcn"
  providers = {
    oci = oci.region1
  }
  compartment_id            = var.compartment_ocid
  vcn_cidr                  = var.vcn_hub_cidr
  proyecto                  = "${var.proyecto}hub"
  ambiente                  = var.ambiente
  habilitar_nat_gateway     = true
  habilitar_service_gateway = true
  tags                      = local.tags_comunes
}

module "red_spoke" {
  source = "../../modulos/red/vcn"
  providers = {
    oci = oci.region2
  }
  compartment_id            = var.compartment_ocid
  vcn_cidr                  = var.vcn_spoke_cidr
  proyecto                  = "${var.proyecto}spk"
  ambiente                  = var.ambiente
  habilitar_nat_gateway     = true
  habilitar_service_gateway = false
  tags                      = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  DRG + REMOTE PEERING CONNECTION
# ═══════════════════════════════════════════════════════════════════════════════

module "peering_remoto" {
  source = "../../modulos/red/peering-remoto"
  providers = {
    oci.region1 = oci.region1
    oci.region2 = oci.region2
  }
  compartment_id = var.compartment_ocid
  vcn_id_region1 = module.red_hub.vcn_id
  vcn_id_region2 = module.red_spoke.vcn_id
  region1        = var.region
  region2        = var.region2
  proyecto       = var.proyecto
  ambiente       = var.ambiente
  tags           = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  SECURITY LISTS (vacías — NSGs controlan el tráfico)
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_core_security_list" "sl_vacia_hub" {
  count          = var.habilitar_nsg ? 1 : 0
  provider       = oci.region1
  compartment_id = var.compartment_ocid
  vcn_id         = module.red_hub.vcn_id
  display_name   = "${local.prefijo}-sl-vacia-hub"
  freeform_tags  = local.tags_comunes

  # Egress necesario: OCI valida acceso a nivel de subnet
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    description = "Permitir todo tráfico de salida (NSGs controlan ingreso)"
  }
}

resource "oci_core_security_list" "sl_vacia_spoke" {
  count          = var.habilitar_nsg ? 1 : 0
  provider       = oci.region2
  compartment_id = var.compartment_ocid
  vcn_id         = module.red_spoke.vcn_id
  display_name   = "${local.prefijo}-sl-vacia-spoke"
  freeform_tags  = local.tags_comunes

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    description = "Permitir todo tráfico de salida (NSGs controlan ingreso)"
  }
}

# ═══════════════════════════════════════════════════════════════════════════════
#  NETWORK SECURITY GROUPS
# ═══════════════════════════════════════════════════════════════════════════════

module "nsgs_hub" {
  source = "../../modulos/seguridad/nsg"
  providers = {
    oci = oci.region1
  }
  count              = var.habilitar_nsg ? 1 : 0
  compartment_id     = var.compartment_ocid
  vcn_id             = module.red_hub.vcn_id
  proyecto           = "${var.proyecto}hub"
  ambiente           = var.ambiente
  habilitar_nsg_web  = true
  habilitar_nsg_ssh  = true
  habilitar_nsg_db   = false
  cidr_ssh_permitido = var.ssh_cidr_permitido
  cidr_red_interna   = [var.vcn_hub_cidr, var.vcn_spoke_cidr]
  tags               = local.tags_comunes
}

module "nsgs_spoke" {
  source = "../../modulos/seguridad/nsg"
  providers = {
    oci = oci.region2
  }
  count              = var.habilitar_nsg ? 1 : 0
  compartment_id     = var.compartment_ocid
  vcn_id             = module.red_spoke.vcn_id
  proyecto           = "${var.proyecto}spk"
  ambiente           = var.ambiente
  habilitar_nsg_web  = true
  habilitar_nsg_ssh  = true
  habilitar_nsg_db   = false
  cidr_ssh_permitido = var.vcn_hub_cidr
  cidr_red_interna   = [var.vcn_hub_cidr, var.vcn_spoke_cidr]
  tags               = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  TABLAS DE RUTEO PERSONALIZADAS (con rutas DRG cross-region)
# ═══════════════════════════════════════════════════════════════════════════════

# Service Gateway CIDR para Oracle Services Network
data "oci_core_services" "all_services_r1" {
  provider = oci.region1
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

# Hub: ruta privada con NAT + DRG + SGW
resource "oci_core_route_table" "rt_hub_privada" {
  provider       = oci.region1
  compartment_id = var.compartment_ocid
  vcn_id         = module.red_hub.vcn_id
  display_name   = "${local.prefijo}-rt-hub-privada"
  freeform_tags  = local.tags_comunes

  route_rules {
    description       = "Internet via NAT Gateway"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = module.red_hub.nat_gateway_id
  }

  route_rules {
    description       = "Cross-Region: Hub → Spoke via DRG"
    destination       = var.vcn_spoke_cidr
    destination_type  = "CIDR_BLOCK"
    network_entity_id = module.peering_remoto.drg_id_region1
  }

  route_rules {
    description       = "Oracle Services via Service Gateway"
    destination       = data.oci_core_services.all_services_r1.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = module.red_hub.service_gateway_id
  }
}

# Spoke: ruta backend con DRG → Hub Region 1
resource "oci_core_route_table" "rt_spoke_backend" {
  provider       = oci.region2
  compartment_id = var.compartment_ocid
  vcn_id         = module.red_spoke.vcn_id
  display_name   = "${local.prefijo}-rt-spoke-backend"
  freeform_tags  = local.tags_comunes

  route_rules {
    description       = "Internet via NAT Gateway"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = module.red_spoke.nat_gateway_id
  }

  route_rules {
    description       = "Cross-Region: Spoke → Hub via DRG"
    destination       = var.vcn_hub_cidr
    destination_type  = "CIDR_BLOCK"
    network_entity_id = module.peering_remoto.drg_id_region2
  }
}

# ═══════════════════════════════════════════════════════════════════════════════
#  SUBNETS — REGIÓN 1 (Hub)
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_core_subnet" "hub_publica" {
  provider       = oci.region1
  compartment_id = var.compartment_ocid
  vcn_id         = module.red_hub.vcn_id
  cidr_block     = var.subnet_hub_publica_cidr
  display_name   = "${var.proyecto}hub-${var.ambiente}-sub-publica"
  dns_label      = "subpub"
  route_table_id = module.red_hub.route_table_publica_id
  security_list_ids = var.habilitar_nsg ? [oci_core_security_list.sl_vacia_hub[0].id] : []
  freeform_tags  = local.tags_comunes
}

resource "oci_core_subnet" "hub_privada_web" {
  provider                   = oci.region1
  compartment_id             = var.compartment_ocid
  vcn_id                     = module.red_hub.vcn_id
  cidr_block                 = var.subnet_hub_privada_cidr
  prohibit_public_ip_on_vnic = true
  display_name               = "${var.proyecto}hub-${var.ambiente}-sub-web"
  dns_label                  = "subweb"
  route_table_id             = oci_core_route_table.rt_hub_privada.id
  security_list_ids          = var.habilitar_nsg ? [oci_core_security_list.sl_vacia_hub[0].id] : []
  freeform_tags              = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  SUBNETS — REGIÓN 2 (Spoke)
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_core_subnet" "spoke_privada_backend" {
  provider                   = oci.region2
  compartment_id             = var.compartment_ocid
  vcn_id                     = module.red_spoke.vcn_id
  cidr_block                 = var.subnet_spoke_backend_cidr
  prohibit_public_ip_on_vnic = true
  display_name               = "${var.proyecto}spk-${var.ambiente}-sub-backend"
  dns_label                  = "subbk"
  route_table_id             = oci_core_route_table.rt_spoke_backend.id
  security_list_ids          = var.habilitar_nsg ? [oci_core_security_list.sl_vacia_spoke[0].id] : []
  freeform_tags              = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  CÓMPUTO — REGIÓN 1 (Hub Webserver)
# ═══════════════════════════════════════════════════════════════════════════════

module "webserver_hub" {
  source = "../../modulos/computo/webserver"
  providers = {
    oci = oci.region1
  }
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads_r1.availability_domains[0].name
  fault_domain        = data.oci_identity_fault_domains.fds_r1.fault_domains[0].name
  subnet_id           = oci_core_subnet.hub_privada_web.id
  ssh_public_key      = var.ssh_public_key
  proyecto            = "${var.proyecto}-hub-web"
  ambiente            = var.ambiente
  shape               = var.shape_webserver
  ocpus               = var.ocpus_webserver
  memoria_gb          = var.memoria_webserver_gb
  asignar_ip_publica  = false
  cantidad            = 1
  imagen_os           = data.oci_core_images.ol8_r1.images[0].id
  nsg_ids             = var.habilitar_nsg ? module.nsgs_hub[0].todos_nsg_ids : []
  userdata_extra      = local.userdata_extra_hub
  tags                = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  CÓMPUTO — REGIÓN 2 (Spoke Backend)
# ═══════════════════════════════════════════════════════════════════════════════

module "spoke_backend" {
  source = "../../modulos/computo/webserver"
  providers = {
    oci = oci.region2
  }
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads_r2.availability_domains[0].name
  fault_domain        = data.oci_identity_fault_domains.fds_r2.fault_domains[0].name
  subnet_id           = oci_core_subnet.spoke_privada_backend.id
  ssh_public_key      = var.ssh_public_key
  proyecto            = "${var.proyecto}-spk-bk"
  ambiente            = var.ambiente
  shape               = var.shape_webserver
  ocpus               = var.ocpus_webserver
  memoria_gb          = var.memoria_webserver_gb
  asignar_ip_publica  = false
  cantidad            = 1
  imagen_os           = data.oci_core_images.ol8_r2.images[0].id
  nsg_ids             = var.habilitar_nsg ? module.nsgs_spoke[0].todos_nsg_ids : []
  userdata_extra      = local.userdata_extra_spoke
  tags                = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  LOAD BALANCER — REGIÓN 1 (Hub)
# ═══════════════════════════════════════════════════════════════════════════════

module "load_balancer" {
  source = "../../modulos/red/load-balancer"
  providers = {
    oci = oci.region1
  }
  compartment_id = var.compartment_ocid
  subnet_id      = oci_core_subnet.hub_publica.id
  backend_ips    = [module.webserver_hub.ips_privadas[0]]
  proyecto       = var.proyecto
  ambiente       = var.ambiente
  nsg_ids        = var.habilitar_nsg ? [module.nsgs_hub[0].nsg_web_id] : []
  tags           = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  BASTION — REGIÓN 1 (Hub)
# ═══════════════════════════════════════════════════════════════════════════════

module "bastion" {
  source = "../../modulos/red/bastion-service"
  providers = {
    oci = oci.region1
  }
  compartment_id  = var.compartment_ocid
  subnet_id       = oci_core_subnet.hub_privada_web.id
  proyecto        = var.proyecto
  ambiente        = var.ambiente
  cidr_permitidos = [var.ssh_cidr_permitido]
  tags            = local.tags_comunes
}
