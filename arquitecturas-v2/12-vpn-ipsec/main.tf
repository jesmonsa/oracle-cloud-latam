# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  12 - VPN Site-to-Site (IPSec) — Túnel VPN con CPE simulado               ║
# ║                                                                            ║
# ║  Topología:                                                                ║
# ║                                                                            ║
# ║    [On-Premises]          [OCI Cloud]                                      ║
# ║    192.168.0.0/16         10.0.0.0/16                                      ║
# ║         │                      │                                           ║
# ║    ┌────▼────┐           ┌─────▼─────┐                                    ║
# ║    │   CPE   │◄═══IPSec═══►  DRG    │                                    ║
# ║    │ 203.0.  │  Tunnel 1  │          │                                    ║
# ║    │ 113.1   │  Tunnel 2  │  attach  │                                    ║
# ║    └─────────┘            └─────┬────┘                                    ║
# ║                                  │                                         ║
# ║                            ┌─────▼─────┐                                  ║
# ║    Internet ──► LB ──────►│ Webserver  │                                  ║
# ║                            │ (privado)  │                                  ║
# ║                            └────────────┘                                  ║
# ║                                                                            ║
# ║  Nota: CPE usa IP simulada (203.0.113.0/24 = TEST-NET-3, RFC 5737)        ║
# ║  Los túneles quedarán DOWN (sin equipo real), pero la config es válida.    ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ═══════════════════════════════════════════════════════════════════════════════
#  1. RED — VCN
# ═══════════════════════════════════════════════════════════════════════════════

module "red" {
  source = "../../modulos/red/vcn"

  compartment_id            = var.compartment_ocid
  proyecto                  = var.proyecto
  ambiente                  = var.ambiente
  vcn_cidr                  = var.vcn_cidr
  habilitar_nat_gateway     = true
  habilitar_service_gateway = true
  tags                      = local.tags_comunes
}

resource "oci_core_security_list" "sl_vacia" {
  count          = var.habilitar_nsg ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = module.red.vcn_id
  display_name   = "${local.prefijo}-sl-vacia"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
    description = "Permitir todo tráfico de salida"
  }

  freeform_tags = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  2. SEGURIDAD — NSGs
# ═══════════════════════════════════════════════════════════════════════════════

module "nsgs" {
  count  = var.habilitar_nsg ? 1 : 0
  source = "../../modulos/seguridad/nsg"

  compartment_id     = var.compartment_ocid
  vcn_id             = module.red.vcn_id
  proyecto           = var.proyecto
  ambiente           = var.ambiente
  habilitar_nsg_web  = true
  habilitar_nsg_ssh  = true
  cidr_ssh_permitido = var.ssh_cidr_permitido
  cidr_red_interna   = [var.vcn_cidr, var.on_prem_cidr]
  tags               = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  3. SUBNETS
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_core_subnet" "publica" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = module.red.vcn_id
  cidr_block                 = var.subnet_publica_cidr
  display_name               = "${local.prefijo}-sub-publica"
  dns_label                  = "pub"
  prohibit_public_ip_on_vnic = false
  route_table_id             = module.red.route_table_publica_id
  security_list_ids          = var.habilitar_nsg ? [oci_core_security_list.sl_vacia[0].id] : []
  freeform_tags              = local.tags_comunes
}

# Subnet privada con route table custom (incluye ruta DRG → on-prem)
resource "oci_core_subnet" "privada" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = module.red.vcn_id
  cidr_block                 = var.subnet_privada_cidr
  display_name               = "${local.prefijo}-sub-privada"
  dns_label                  = "priv"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.rt_privada_vpn.id
  security_list_ids          = var.habilitar_nsg ? [oci_core_security_list.sl_vacia[0].id] : []
  freeform_tags              = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  4. DRG (Dynamic Routing Gateway)
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_core_drg" "drg" {
  compartment_id = var.compartment_ocid
  display_name   = "${local.prefijo}-drg"
  freeform_tags  = local.tags_comunes
}

resource "oci_core_drg_attachment" "drg_attach" {
  drg_id       = oci_core_drg.drg.id
  display_name = "${local.prefijo}-drg-attach"

  network_details {
    id   = module.red.vcn_id
    type = "VCN"
  }
}

# ═══════════════════════════════════════════════════════════════════════════════
#  5. CPE (Customer Premises Equipment) — simulado
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_core_cpe" "cpe" {
  compartment_id = var.compartment_ocid
  ip_address     = var.cpe_ip_address
  display_name   = "${local.prefijo}-cpe-onprem"
  freeform_tags  = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  6. IPSec CONNECTION + TUNNELS
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_core_ipsec" "vpn" {
  compartment_id = var.compartment_ocid
  cpe_id         = oci_core_cpe.cpe.id
  drg_id         = oci_core_drg.drg.id
  display_name   = "${local.prefijo}-ipsec"

  static_routes = [var.on_prem_cidr]

  freeform_tags = local.tags_comunes
}

# Data source para obtener info de los túneles (OCI crea 2 automáticamente)
data "oci_core_ipsec_connection_tunnels" "tunnels" {
  ipsec_id = oci_core_ipsec.vpn.id
}

# Configurar tunnel 1 con shared secret
resource "oci_core_ipsec_connection_tunnel_management" "tunnel_1" {
  ipsec_id  = oci_core_ipsec.vpn.id
  tunnel_id = data.oci_core_ipsec_connection_tunnels.tunnels.ip_sec_connection_tunnels[0].id

  display_name  = "${local.prefijo}-tunnel-1"
  routing       = "STATIC"
  shared_secret = var.shared_secret
  ike_version   = "V2"
}

resource "oci_core_ipsec_connection_tunnel_management" "tunnel_2" {
  ipsec_id  = oci_core_ipsec.vpn.id
  tunnel_id = data.oci_core_ipsec_connection_tunnels.tunnels.ip_sec_connection_tunnels[1].id

  display_name  = "${local.prefijo}-tunnel-2"
  routing       = "STATIC"
  shared_secret = var.shared_secret
  ike_version   = "V2"
}

# ═══════════════════════════════════════════════════════════════════════════════
#  7. ROUTE TABLE PRIVADA (con ruta al DRG para on-prem)
# ═══════════════════════════════════════════════════════════════════════════════

data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_route_table" "rt_privada_vpn" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.red.vcn_id
  display_name   = "${local.prefijo}-rt-privada-vpn"
  freeform_tags  = local.tags_comunes

  # Internet via NAT
  route_rules {
    description       = "Internet via NAT Gateway"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = module.red.nat_gateway_id
  }

  # On-premises via DRG (IPSec tunnel)
  route_rules {
    description       = "On-Premises via DRG (VPN IPSec)"
    destination       = var.on_prem_cidr
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.drg.id
  }

  # Oracle Services via Service Gateway
  route_rules {
    description       = "Oracle Services via SGW"
    destination       = data.oci_core_services.all_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = module.red.service_gateway_id
  }
}

# ═══════════════════════════════════════════════════════════════════════════════
#  8. WEBSERVER + LB + BASTION
# ═══════════════════════════════════════════════════════════════════════════════

module "webserver" {
  source = "../../modulos/computo/webserver"

  compartment_id = var.compartment_ocid
  proyecto       = var.proyecto
  ambiente       = var.ambiente
  cantidad       = 1
  subnet_id      = oci_core_subnet.privada.id
  imagen_os      = local.imagen_id
  shape          = var.shape_webserver
  ocpus          = var.ocpus_webserver
  memoria_gb     = var.memoria_webserver_gb
  ssh_public_key = var.ssh_public_key
  nsg_ids        = var.habilitar_nsg ? module.nsgs[0].todos_nsg_ids : []
  userdata_extra = local.userdata_extra
  tags           = local.tags_comunes
}

module "load_balancer" {
  source = "../../modulos/red/load-balancer"

  compartment_id = var.compartment_ocid
  proyecto       = var.proyecto
  ambiente       = var.ambiente
  subnet_id      = oci_core_subnet.publica.id
  backend_ips    = module.webserver.ips_privadas
  nsg_ids        = var.habilitar_nsg ? [module.nsgs[0].nsg_web_id] : []
  tags           = local.tags_comunes
}

module "bastion" {
  source = "../../modulos/red/bastion-service"

  compartment_id = var.compartment_ocid
  subnet_id      = oci_core_subnet.privada.id
  proyecto       = var.proyecto
  ambiente       = var.ambiente
  tags           = local.tags_comunes
}
