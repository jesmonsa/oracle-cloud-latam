module "red_hub" {
  source                = "../../modulos/red/vcn"
  compartment_id        = var.compartment_ocid
  vcn_cidr              = var.vcn_cidr
  proyecto              = "${var.proyecto}hub"
  ambiente              = var.ambiente
  habilitar_nat_gateway = true
  tags                  = local.tags_comunes
}

module "red_spoke" {
  source                = "../../modulos/red/vcn"
  compartment_id        = var.compartment_ocid
  vcn_cidr              = var.vcn_spoke_cidr
  proyecto              = "${var.proyecto}spk"
  ambiente              = var.ambiente
  habilitar_nat_gateway = true # Para que el spoke pueda actualizar OS
  tags                  = local.tags_comunes
}

module "peering_local" {
  source              = "../../modulos/red/peering-local"
  compartment_id_vcn1 = var.compartment_ocid
  compartment_id_vcn2 = var.compartment_ocid
  vcn_id_1            = module.red_hub.vcn_id
  vcn_id_2            = module.red_spoke.vcn_id
  proyecto            = var.proyecto
  ambiente            = var.ambiente
  tags                = local.tags_comunes
}

# Tabla de Ruteo Especial Hub DB (Apunta a NAT y a Spoke vía LPG)
resource "oci_core_route_table" "rt_hub_db" {
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
    network_entity_id = module.peering_local.lpg_id_vcn1
  }
}

# Tabla de Ruteo Especial Spoke (Apunta a NAT y a Hub VCN vía LPG)
resource "oci_core_route_table" "rt_spoke_backend" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.red_spoke.vcn_id
  display_name   = "${var.proyecto}-${var.ambiente}-rt-spoke-bk"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = module.red_spoke.nat_gateway_id
  }

  route_rules {
    destination       = var.vcn_cidr # Apunta a toda la Hub VCN
    destination_type  = "CIDR_BLOCK"
    network_entity_id = module.peering_local.lpg_id_vcn2
  }
}

module "nsgs_hub" {
  source             = "../../modulos/seguridad/nsg"
  count              = var.habilitar_nsg ? 1 : 0
  compartment_id     = var.compartment_ocid
  vcn_id             = module.red_hub.vcn_id
  proyecto           = "${var.proyecto}hub"
  ambiente           = var.ambiente
  habilitar_nsg_web  = true
  habilitar_nsg_ssh  = true
  habilitar_nsg_db   = true
  cidr_ssh_permitido = var.ssh_cidr_permitido

  # Lista de CIDRs internos: Hub + Spoke (tráfico cross-VCN vía LPG)
  cidr_red_interna = [var.vcn_cidr, var.vcn_spoke_cidr]
  tags             = local.tags_comunes
}

module "nsgs_spoke" {
  source             = "../../modulos/seguridad/nsg"
  count              = var.habilitar_nsg ? 1 : 0
  compartment_id     = var.compartment_ocid
  vcn_id             = module.red_spoke.vcn_id
  proyecto           = "${var.proyecto}spk"
  ambiente           = var.ambiente
  habilitar_nsg_ssh  = true
  cidr_ssh_permitido = var.vcn_cidr # Solo se puede SSH desde la Hub VCN (Bastion)
  cidr_red_interna   = [var.vcn_cidr, var.vcn_spoke_cidr]
  tags               = local.tags_comunes
}

# Subnet Pública Hub (LB)
resource "oci_core_subnet" "hub_publica" {
  compartment_id    = var.compartment_ocid
  vcn_id            = module.red_hub.vcn_id
  cidr_block        = var.subnet_publica_cidr
  display_name      = "${var.proyecto}hub-${var.ambiente}-subnet-publica"
  dns_label         = "subpub"
  route_table_id    = module.red_hub.route_table_publica_id
  security_list_ids = []
  freeform_tags     = local.tags_comunes
}

# Subnet Privada Hub (Webservers, Bastion)
resource "oci_core_subnet" "hub_privada_web" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = module.red_hub.vcn_id
  cidr_block                 = var.subnet_privada_cidr
  prohibit_public_ip_on_vnic = true
  display_name               = "${var.proyecto}hub-${var.ambiente}-subnet-web"
  dns_label                  = "subweb"
  route_table_id             = module.red_hub.route_table_privada_id # Sale por NAT estándar
  security_list_ids          = []
  freeform_tags              = local.tags_comunes
}

# Subnet Privada Hub (Base de Datos)
resource "oci_core_subnet" "hub_privada_db" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = module.red_hub.vcn_id
  cidr_block                 = var.subnet_db_cidr
  prohibit_public_ip_on_vnic = true
  display_name               = "${var.proyecto}hub-${var.ambiente}-subnet-db"
  dns_label                  = "subdb"
  route_table_id             = oci_core_route_table.rt_hub_db.id # Usa la RT custom con LPG
  security_list_ids          = []
  freeform_tags              = local.tags_comunes
}

# Subnet Privada Spoke (Backend)
resource "oci_core_subnet" "spoke_privada_backend" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = module.red_spoke.vcn_id
  cidr_block                 = var.subnet_backend_cidr
  prohibit_public_ip_on_vnic = true
  display_name               = "${var.proyecto}spk-${var.ambiente}-subnet-backend"
  dns_label                  = "subbk"
  route_table_id             = oci_core_route_table.rt_spoke_backend.id # Usa la RT custom con LPG
  security_list_ids          = []
  freeform_tags              = local.tags_comunes
}

module "dbsystem" {
  source              = "../../modulos/base-de-datos/dbsystem"
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ad.availability_domains[0].name
  subnet_id           = oci_core_subnet.hub_privada_db.id
  proyecto            = var.proyecto
  ambiente            = var.ambiente

  shape             = var.shape_dbsystem
  cpu_core_count    = var.ocpus_dbsystem
  memory_in_gbs     = var.memoria_dbsystem_gb
  db_admin_password = var.db_password
  db_name           = var.db_name
  timezone          = var.db_timezone
  ssh_public_keys   = [var.ssh_public_key]

  nsg_ids = var.habilitar_nsg ? module.nsgs_hub[0].todos_nsg_ids : []
  tags    = local.tags_comunes
}

module "webserver_fd1" {
  source              = "../../modulos/computo/webserver"
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

module "spoke_backend" {
  source              = "../../modulos/computo/webserver"
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ad.availability_domains[0].name
  # Puede coincidir en FD o no, no es el objetivo HA en el backend en este LAB
  fault_domain       = data.oci_identity_fault_domains.fd.fault_domains[0].name
  subnet_id          = oci_core_subnet.spoke_privada_backend.id
  ssh_public_key     = var.ssh_public_key
  proyecto           = "${var.proyecto}-spk-bk"
  ambiente           = var.ambiente
  shape              = var.shape_webserver
  ocpus              = var.ocpus_webserver
  memoria_gb         = var.memoria_webserver_gb
  asignar_ip_publica = false
  cantidad           = 1
  imagen_os          = var.imagen_os != "" ? var.imagen_os : data.oci_core_images.os_image.images[0].id
  nsg_ids            = var.habilitar_nsg ? module.nsgs_spoke[0].todos_nsg_ids : []
  tags               = local.tags_comunes
}

module "bastion" {
  source          = "../../modulos/red/bastion-service"
  compartment_id  = var.compartment_ocid
  subnet_id       = oci_core_subnet.hub_privada_web.id
  proyecto        = var.proyecto
  ambiente        = var.ambiente
  cidr_permitidos = [var.ssh_cidr_permitido]
  tags            = local.tags_comunes
}

module "load_balancer" {
  source         = "../../modulos/red/load-balancer"
  compartment_id = var.compartment_ocid
  subnet_id      = oci_core_subnet.hub_publica.id
  backend_ips = [
    module.webserver_fd1.ips_privadas[0]
  ]
  proyecto = var.proyecto
  ambiente = var.ambiente
  tags     = local.tags_comunes
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
