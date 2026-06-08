# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  08 - Peering Local (Hub-Spoke VCN Interconnection)                         ║
# ║                                                                             ║
# ║  Hub VCN (10.0.0.0/16):  LB + Webserver + DB System + Bastion              ║
# ║  Spoke VCN (10.1.0.0/16): Backend server (conectado via LPG)               ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ─── VCN Hub ────────────────────────────────────────────────────────────────
module "red_hub" {
  source                      = "../../modulos/red/vcn"
  compartment_id              = var.compartment_ocid
  vcn_cidr                    = var.vcn_hub_cidr
  proyecto                    = "${var.proyecto}hub"
  ambiente                    = var.ambiente
  habilitar_nat_gateway       = true
  habilitar_service_gateway   = true
  tags                        = local.tags_comunes
}

# ─── VCN Spoke ──────────────────────────────────────────────────────────────
module "red_spoke" {
  source                      = "../../modulos/red/vcn"
  compartment_id              = var.compartment_ocid
  vcn_cidr                    = var.vcn_spoke_cidr
  proyecto                    = "${var.proyecto}spk"
  ambiente                    = var.ambiente
  habilitar_nat_gateway       = true
  habilitar_service_gateway   = false  # Spoke usa NAT para OS updates, no necesita SGW
  tags                        = local.tags_comunes
}

# ─── Local Peering Gateway (Hub ↔ Spoke) ────────────────────────────────────
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

# ─── Security List vacía (NSGs controlan todo) ──────────────────────────────
resource "oci_core_security_list" "sl_vacia" {
  count          = var.habilitar_nsg ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = module.red_hub.vcn_id
  display_name   = "${var.proyecto}hub-${var.ambiente}-sl-vacia"
  freeform_tags  = local.tags_comunes

  # Egress necesario: OCI valida acceso a Object Storage a nivel de subnet
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    description = "Permitir todo tráfico de salida (NSGs controlan ingreso)"
  }
}

resource "oci_core_security_list" "sl_vacia_spoke" {
  count          = var.habilitar_nsg ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = module.red_spoke.vcn_id
  display_name   = "${var.proyecto}spk-${var.ambiente}-sl-vacia"
  freeform_tags  = local.tags_comunes

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    description = "Permitir todo tráfico de salida"
  }
}

# ─── NSGs Hub (Web, SSH, DB, NFS, Egress) ───────────────────────────────────
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

  # CIDRs internos: Hub + Spoke (tráfico cross-VCN vía LPG)
  cidr_red_interna = [var.vcn_hub_cidr, var.vcn_spoke_cidr]
  tags             = local.tags_comunes
}

# ─── NSGs Spoke (SSH, Egress) ───────────────────────────────────────────────
module "nsgs_spoke" {
  source             = "../../modulos/seguridad/nsg"
  count              = var.habilitar_nsg ? 1 : 0
  compartment_id     = var.compartment_ocid
  vcn_id             = module.red_spoke.vcn_id
  proyecto           = "${var.proyecto}spk"
  ambiente           = var.ambiente
  habilitar_nsg_web  = true   # Backend también sirve HTTP
  habilitar_nsg_ssh  = true

  # SSH desde Hub VCN (Bastion) + tráfico interno cross-VCN
  cidr_red_interna = [var.vcn_hub_cidr, var.vcn_spoke_cidr]
  tags             = local.tags_comunes
}

# ─── Route Table Hub DB (NAT + LPG → Spoke) ────────────────────────────────
resource "oci_core_route_table" "rt_hub_db" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.red_hub.vcn_id
  display_name   = "${var.proyecto}hub-${var.ambiente}-rt-db"
  freeform_tags  = local.tags_comunes

  # Salida a Internet via NAT (para OS updates, Object Storage via NAT)
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = module.red_hub.nat_gateway_id
  }

  # Ruta al Spoke VCN via LPG
  route_rules {
    destination       = var.vcn_spoke_cidr
    destination_type  = "CIDR_BLOCK"
    network_entity_id = module.peering_local.lpg_id_vcn1
  }

  # Ruta a Oracle Services (Object Storage) via Service Gateway
  route_rules {
    destination       = data.oci_core_services.all_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = module.red_hub.service_gateway_id
  }
}

# ─── Route Table Spoke Backend (NAT + LPG → Hub) ───────────────────────────
resource "oci_core_route_table" "rt_spoke_backend" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.red_spoke.vcn_id
  display_name   = "${var.proyecto}spk-${var.ambiente}-rt-bk"
  freeform_tags  = local.tags_comunes

  # Salida a Internet via NAT
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = module.red_spoke.nat_gateway_id
  }

  # Ruta al Hub VCN via LPG
  route_rules {
    destination       = var.vcn_hub_cidr
    destination_type  = "CIDR_BLOCK"
    network_entity_id = module.peering_local.lpg_id_vcn2
  }
}

# ─── Data source para Service Gateway CIDR ──────────────────────────────────
data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

# ─── Subnet Pública Hub (LB) ───────────────────────────────────────────────
resource "oci_core_subnet" "hub_publica" {
  compartment_id    = var.compartment_ocid
  vcn_id            = module.red_hub.vcn_id
  cidr_block        = var.subnet_hub_publica_cidr
  display_name      = "${var.proyecto}hub-${var.ambiente}-subnet-lb"
  dns_label         = "sublb"
  route_table_id    = module.red_hub.route_table_publica_id
  security_list_ids = var.habilitar_nsg ? [oci_core_security_list.sl_vacia[0].id] : [module.red_hub.security_list_publica_id]
  freeform_tags     = local.tags_comunes
}

# ─── Subnet Privada Hub (Webservers) ───────────────────────────────────────
resource "oci_core_subnet" "hub_privada_web" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = module.red_hub.vcn_id
  cidr_block                 = var.subnet_hub_privada_cidr
  prohibit_public_ip_on_vnic = true
  display_name               = "${var.proyecto}hub-${var.ambiente}-subnet-web"
  dns_label                  = "subweb"
  route_table_id             = module.red_hub.route_table_privada_id
  security_list_ids          = var.habilitar_nsg ? [oci_core_security_list.sl_vacia[0].id] : [module.red_hub.security_list_privada_id]
  freeform_tags              = local.tags_comunes
}

# ─── Subnet Privada Hub (DB) ───────────────────────────────────────────────
resource "oci_core_subnet" "hub_privada_db" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = module.red_hub.vcn_id
  cidr_block                 = var.subnet_hub_db_cidr
  prohibit_public_ip_on_vnic = true
  display_name               = "${var.proyecto}hub-${var.ambiente}-subnet-db"
  dns_label                  = "subdb"
  route_table_id             = oci_core_route_table.rt_hub_db.id  # RT custom con LPG + SGW
  security_list_ids          = var.habilitar_nsg ? [oci_core_security_list.sl_vacia[0].id] : [module.red_hub.security_list_privada_id]
  freeform_tags              = local.tags_comunes
}

# ─── Subnet Privada Spoke (Backend) ────────────────────────────────────────
resource "oci_core_subnet" "spoke_privada_backend" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = module.red_spoke.vcn_id
  cidr_block                 = var.subnet_spoke_backend_cidr
  prohibit_public_ip_on_vnic = true
  display_name               = "${var.proyecto}spk-${var.ambiente}-subnet-bk"
  dns_label                  = "subbk"
  route_table_id             = oci_core_route_table.rt_spoke_backend.id  # RT custom con LPG
  security_list_ids          = var.habilitar_nsg ? [oci_core_security_list.sl_vacia_spoke[0].id] : [module.red_spoke.security_list_privada_id]
  freeform_tags              = local.tags_comunes
}

# ─── Webserver Hub (AD1/FD1) ───────────────────────────────────────────────
module "webserver_hub" {
  source              = "../../modulos/computo/webserver"
  compartment_id      = var.compartment_ocid
  availability_domain = local.ad_instancia_1
  fault_domain        = data.oci_identity_fault_domains.fd.fault_domains[0].name
  subnet_id           = oci_core_subnet.hub_privada_web.id
  ssh_public_key      = var.ssh_public_key
  proyecto            = "${var.proyecto}-hub-web"
  ambiente            = var.ambiente
  shape               = var.shape_webserver
  ocpus               = var.ocpus_webserver
  memoria_gb          = var.memoria_webserver_gb
  asignar_ip_publica  = false
  cantidad            = 1
  imagen_os           = local.imagen_id
  userdata_extra      = local.userdata_extra_hub
  nsg_ids             = var.habilitar_nsg ? [module.nsgs_hub[0].nsg_web_id, module.nsgs_hub[0].nsg_ssh_id] : []
  tags                = local.tags_comunes
}

# ─── Backend Spoke (AD1/FD1) ──────────────────────────────────────────────
module "spoke_backend" {
  source              = "../../modulos/computo/webserver"
  compartment_id      = var.compartment_ocid
  availability_domain = local.ad_instancia_1
  fault_domain        = data.oci_identity_fault_domains.fd.fault_domains[0].name
  subnet_id           = oci_core_subnet.spoke_privada_backend.id
  ssh_public_key      = var.ssh_public_key
  proyecto            = "${var.proyecto}-spk-bk"
  ambiente            = var.ambiente
  shape               = var.shape_webserver
  ocpus               = var.ocpus_webserver
  memoria_gb          = var.memoria_webserver_gb
  asignar_ip_publica  = false
  cantidad            = 1
  imagen_os           = local.imagen_id
  userdata_extra      = local.userdata_extra_spoke
  nsg_ids             = var.habilitar_nsg ? [module.nsgs_spoke[0].nsg_web_id, module.nsgs_spoke[0].nsg_ssh_id] : []
  tags                = local.tags_comunes
}

# ─── DB System Hub ─────────────────────────────────────────────────────────
module "database" {
  source              = "../../modulos/base-de-datos/dbsystem"
  compartment_id      = var.compartment_ocid
  availability_domain = local.ad_instancia_1
  subnet_id           = oci_core_subnet.hub_privada_db.id
  proyecto            = var.proyecto
  ambiente            = var.ambiente

  shape                   = var.shape_db
  cpu_core_count          = var.cpu_core_count_db
  data_storage_size_in_gb = var.data_storage_size_in_gb
  db_admin_password       = var.db_admin_password
  db_name                 = var.db_name
  db_version              = var.db_version
  database_edition        = var.database_edition
  license_model           = var.license_model
  ssh_public_keys         = [var.ssh_public_key]

  nsg_ids = var.habilitar_nsg ? [module.nsgs_hub[0].nsg_db_id, module.nsgs_hub[0].nsg_ssh_id, module.nsgs_hub[0].nsg_egress_id] : []
  tags    = local.tags_comunes
}

# ─── Load Balancer Hub ─────────────────────────────────────────────────────
module "load_balancer" {
  source         = "../../modulos/red/load-balancer"
  compartment_id = var.compartment_ocid
  subnet_id      = oci_core_subnet.hub_publica.id
  backend_ips    = [module.webserver_hub.ips_privadas[0]]
  proyecto       = var.proyecto
  ambiente       = var.ambiente

  bandwidth_min_mbps = var.lb_bandwidth_min_mbps
  bandwidth_max_mbps = var.lb_bandwidth_max_mbps

  nsg_ids = var.habilitar_nsg ? [module.nsgs_hub[0].nsg_web_id] : []
  tags    = local.tags_comunes
}

# ─── Bastion Hub ───────────────────────────────────────────────────────────
module "bastion" {
  source          = "../../modulos/red/bastion-service"
  compartment_id  = var.compartment_ocid
  subnet_id       = oci_core_subnet.hub_privada_web.id
  proyecto        = var.proyecto
  ambiente        = var.ambiente
  cidr_permitidos = var.bastion_cidr_permitidos
  tags            = local.tags_comunes
}
