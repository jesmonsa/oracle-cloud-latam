module "red_hub" {
  source = "../../modulos/red/vcn"
  providers = {
    oci = oci.region1
  }
  compartment_id        = var.compartment_ocid
  vcn_cidr              = var.vcn_cidr
  proyecto              = "${var.proyecto}hub"
  ambiente              = var.ambiente
  habilitar_nat_gateway = true
  tags                  = local.tags_comunes
}

module "red_spoke" {
  source = "../../modulos/red/vcn"
  providers = {
    oci = oci.region2
  }
  compartment_id        = var.compartment_ocid
  vcn_cidr              = var.vcn_spoke_cidr
  proyecto              = "${var.proyecto}spk"
  ambiente              = var.ambiente
  habilitar_nat_gateway = true
  tags                  = local.tags_comunes
}

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

# Tabla de Ruteo Hub DB (Región 1) — con ruta vía DRG hacia Spoke
resource "oci_core_route_table" "rt_hub_db" {
  provider       = oci.region1
  compartment_id = var.compartment_ocid
  vcn_id         = module.red_hub.vcn_id
  display_name   = "${var.proyecto}-${var.ambiente}-rt-hub-db"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = module.red_hub.nat_gateway_id
  }
  route_rules {
    destination       = var.vcn_spoke_cidr
    destination_type  = "CIDR_BLOCK"
    network_entity_id = module.peering_remoto.drg_id_region1
  }
}

# Tabla de Ruteo Spoke Backend (Región 2) — con ruta vía DRG hacia Hub
resource "oci_core_route_table" "rt_spoke_backend" {
  provider       = oci.region2
  compartment_id = var.compartment_ocid
  vcn_id         = module.red_spoke.vcn_id
  display_name   = "${var.proyecto}-${var.ambiente}-rt-spoke-bk"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = module.red_spoke.nat_gateway_id
  }
  route_rules {
    destination       = var.vcn_cidr
    destination_type  = "CIDR_BLOCK"
    network_entity_id = module.peering_remoto.drg_id_region2
  }
}

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
  habilitar_nsg_db   = true
  cidr_ssh_permitido = var.ssh_cidr_permitido
  # Lista de CIDRs internos: Hub + Spoke (peering cross-region)
  cidr_red_interna = [var.vcn_cidr, var.vcn_spoke_cidr]
  tags             = local.tags_comunes
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
  habilitar_nsg_ssh  = true
  cidr_ssh_permitido = var.vcn_cidr
  cidr_red_interna   = [var.vcn_cidr, var.vcn_spoke_cidr]
  tags               = local.tags_comunes
}

# ─── Subnets Región 1 ──────────────────────────────────────────────────────────

resource "oci_core_subnet" "hub_publica" {
  provider          = oci.region1
  compartment_id    = var.compartment_ocid
  vcn_id            = module.red_hub.vcn_id
  cidr_block        = var.subnet_publica_cidr
  display_name      = "${var.proyecto}hub-${var.ambiente}-subnet-publica"
  dns_label         = "subpub"
  route_table_id    = module.red_hub.route_table_publica_id
  security_list_ids = []
  freeform_tags     = local.tags_comunes
}

resource "oci_core_subnet" "hub_privada_web" {
  provider                   = oci.region1
  compartment_id             = var.compartment_ocid
  vcn_id                     = module.red_hub.vcn_id
  cidr_block                 = var.subnet_privada_cidr
  prohibit_public_ip_on_vnic = true
  display_name               = "${var.proyecto}hub-${var.ambiente}-subnet-web"
  dns_label                  = "subweb"
  route_table_id             = module.red_hub.route_table_privada_id
  security_list_ids          = []
  freeform_tags              = local.tags_comunes
}

resource "oci_core_subnet" "hub_privada_db" {
  provider                   = oci.region1
  compartment_id             = var.compartment_ocid
  vcn_id                     = module.red_hub.vcn_id
  cidr_block                 = var.subnet_db_cidr
  prohibit_public_ip_on_vnic = true
  display_name               = "${var.proyecto}hub-${var.ambiente}-subnet-db"
  dns_label                  = "subdb"
  route_table_id             = oci_core_route_table.rt_hub_db.id
  security_list_ids          = []
  freeform_tags              = local.tags_comunes
}

# ─── Subnets Región 2 ──────────────────────────────────────────────────────────

resource "oci_core_subnet" "spoke_privada_backend" {
  provider                   = oci.region2
  compartment_id             = var.compartment_ocid
  vcn_id                     = module.red_spoke.vcn_id
  cidr_block                 = var.subnet_backend_cidr
  prohibit_public_ip_on_vnic = true
  display_name               = "${var.proyecto}spk-${var.ambiente}-subnet-backend"
  dns_label                  = "subbk"
  route_table_id             = oci_core_route_table.rt_spoke_backend.id
  security_list_ids          = []
  freeform_tags              = local.tags_comunes
}

# ─── Instancias Región 1 ───────────────────────────────────────────────────────

module "dbsystem" {
  source = "../../modulos/base-de-datos/dbsystem"
  providers = {
    oci = oci.region1
  }
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ad.availability_domains[0].name
  subnet_id           = oci_core_subnet.hub_privada_db.id
  proyecto            = var.proyecto
  ambiente            = var.ambiente
  shape               = var.shape_dbsystem
  cpu_core_count      = var.ocpus_dbsystem
  memory_in_gbs       = var.memoria_dbsystem_gb
  db_admin_password   = var.db_password
  db_name             = var.db_name
  timezone            = var.db_timezone
  ssh_public_keys     = [var.ssh_public_key]
  nsg_ids             = var.habilitar_nsg ? module.nsgs_hub[0].todos_nsg_ids : []
  tags                = local.tags_comunes
}

module "webserver_fd1" {
  source = "../../modulos/computo/webserver"
  providers = {
    oci = oci.region1
  }
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ad.availability_domains[0].name
  fault_domain        = data.oci_identity_fault_domains.fd.fault_domains[0].name
  subnet_id           = oci_core_subnet.hub_privada_web.id
  ssh_public_key      = var.ssh_public_key
  proyecto            = "${var.proyecto}-web-fd1"
  ambiente            = var.ambiente
  shape               = var.shape_webserver
  ocpus               = var.ocpus_webserver
  memoria_gb          = var.memoria_webserver_gb
  asignar_ip_publica  = false
  cantidad            = 1
  imagen_os           = var.imagen_os != "" ? var.imagen_os : data.oci_core_images.os_image.images[0].id
  nsg_ids             = var.habilitar_nsg ? module.nsgs_hub[0].todos_nsg_ids : []
  tags                = local.tags_comunes
}

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

module "load_balancer" {
  source = "../../modulos/red/load-balancer"
  providers = {
    oci = oci.region1
  }
  compartment_id = var.compartment_ocid
  subnet_id      = oci_core_subnet.hub_publica.id
  backend_ips    = [module.webserver_fd1.ips_privadas[0]]
  proyecto       = var.proyecto
  ambiente       = var.ambiente
  tags           = local.tags_comunes
}

# ─── Instancias Región 2 ───────────────────────────────────────────────────────

data "oci_identity_availability_domains" "ad_region2" {
  provider       = oci.region2
  compartment_id = var.tenancy_ocid
}

data "oci_identity_fault_domains" "fd_region2" {
  provider            = oci.region2
  availability_domain = data.oci_identity_availability_domains.ad_region2.availability_domains[0].name
  compartment_id      = var.compartment_ocid
}

data "oci_core_images" "os_image_region2" {
  provider                 = oci.region2
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.shape_webserver
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

module "spoke_backend_r2" {
  source = "../../modulos/computo/webserver"
  providers = {
    oci = oci.region2
  }
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ad_region2.availability_domains[0].name
  fault_domain        = data.oci_identity_fault_domains.fd_region2.fault_domains[0].name
  subnet_id           = oci_core_subnet.spoke_privada_backend.id
  ssh_public_key      = var.ssh_public_key
  proyecto            = "${var.proyecto}-spk-bk"
  ambiente            = var.ambiente
  shape               = var.shape_webserver
  ocpus               = var.ocpus_webserver
  memoria_gb          = var.memoria_webserver_gb
  asignar_ip_publica  = false
  cantidad            = 1
  imagen_os           = data.oci_core_images.os_image_region2.images[0].id
  nsg_ids             = var.habilitar_nsg ? module.nsgs_spoke[0].todos_nsg_ids : []
  tags                = local.tags_comunes
}

module "baselines" {
  source = "../../modulos/seguridad/baselines"
  providers = {
    oci = oci.region1
  }
  count          = var.habilitar_baseline_seguridad ? 1 : 0
  compartment_id = var.compartment_ocid
  tenancy_ocid   = var.tenancy_ocid
  proyecto       = var.proyecto
  ambiente       = var.ambiente
  tags           = local.tags_comunes
}
