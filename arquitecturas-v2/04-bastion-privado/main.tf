# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Main - Bastion Service + Webservers Privados                               ║
# ║  Arquitectura: VCN + NAT GW + LB Público + Subnets Privadas + Bastion     ║
# ║                                                                            ║
# ║  Cambios clave vs Arquitectura 03:                                         ║
# ║    - Webservers en subnets PRIVADAS (sin IP pública)                       ║
# ║    - NAT Gateway habilitado (webservers acceden a internet para yum)       ║
# ║    - Service Gateway habilitado (acceso a servicios OCI internos)          ║
# ║    - Bastion Service para SSH seguro (túnel, sin exponer puerto 22)        ║
# ║    - SSH desde internet ELIMINADO — solo via Bastion                       ║
# ║    - LB sigue siendo el único punto de entrada HTTP público                ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ─── Red: VCN + IGW + NAT GW + Service GW ────────────────────────────────
module "red" {
  source         = "../../modulos/red/vcn"
  compartment_id = var.compartment_ocid
  vcn_cidr       = var.vcn_cidr
  proyecto       = var.proyecto
  ambiente       = var.ambiente
  tags           = local.tags_comunes

  # NAT Gateway: los webservers privados necesitan salida a internet (yum install)
  habilitar_nat_gateway = true
  # Service Gateway: acceso directo a Object Storage y servicios OCI sin salir de la VCN
  habilitar_service_gateway = true
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
  # SSH solo desde la VCN interna (Bastion Service usa IPs internas)
  cidr_ssh_permitido = var.vcn_cidr
  tags               = local.tags_comunes
}

# ─── Security List para subnets privadas ───────────────────────────────────
# Cuando NSG habilitado: SL vacía (NSGs manejan la seguridad)
resource "oci_core_security_list" "sl_vacia" {
  count          = var.habilitar_nsg ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = module.red.vcn_id
  display_name   = "${local.prefijo}-sl-vacia"
  freeform_tags  = local.tags_comunes
}

# Cuando NSG deshabilitado: SL con reglas completas
resource "oci_core_security_list" "sl_privada" {
  count          = var.habilitar_nsg ? 0 : 1
  compartment_id = var.compartment_ocid
  vcn_id         = module.red.vcn_id
  display_name   = "${local.prefijo}-sl-privada"
  freeform_tags  = local.tags_comunes

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    description = "Permitir todo tráfico de salida (via NAT GW)"
  }

  ingress_security_rules {
    protocol    = "6"
    source      = var.vcn_cidr
    description = "SSH desde VCN interna (Bastion Service)"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = var.subnet_lb_cidr
    description = "HTTP desde subnet del Load Balancer"
    tcp_options {
      min = 80
      max = 80
    }
  }
}

# ─── Security List para Load Balancer ────────────────────────────────────────
resource "oci_core_security_list" "sl_lb" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.red.vcn_id
  display_name   = "${local.prefijo}-sl-lb"
  freeform_tags  = local.tags_comunes

  egress_security_rules {
    destination = var.vcn_cidr
    protocol    = "6"
    description = "LB a backends (HTTP health check + tráfico)"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "HTTP desde internet al LB"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "HTTPS desde internet al LB"
    tcp_options {
      min = 443
      max = 443
    }
  }
}

# ─── Subnet Privada AD1 (Webserver 1) ─────────────────────────────────────
resource "oci_core_subnet" "privada_ad1" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = module.red.vcn_id
  cidr_block                 = var.subnet_privada_ad1_cidr
  display_name               = "${local.prefijo}-subnet-priv-ad1"
  dns_label                  = "subprivad1"
  availability_domain        = local.ad_instancia_1
  prohibit_public_ip_on_vnic = true
  route_table_id             = module.red.route_table_privada_id
  freeform_tags              = local.tags_comunes

  security_list_ids = var.habilitar_nsg ? (
    [oci_core_security_list.sl_vacia[0].id]
    ) : (
    [oci_core_security_list.sl_privada[0].id]
  )
}

# ─── Subnet Privada AD2 (Webserver 2) ─────────────────────────────────────
resource "oci_core_subnet" "privada_ad2" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = module.red.vcn_id
  cidr_block                 = var.subnet_privada_ad2_cidr
  display_name               = "${local.prefijo}-subnet-priv-ad2"
  dns_label                  = "subprivad2"
  availability_domain        = local.ad_instancia_2
  prohibit_public_ip_on_vnic = true
  route_table_id             = module.red.route_table_privada_id
  freeform_tags              = local.tags_comunes

  security_list_ids = var.habilitar_nsg ? (
    [oci_core_security_list.sl_vacia[0].id]
    ) : (
    [oci_core_security_list.sl_privada[0].id]
  )
}

# ─── Subnet Pública Regional para Load Balancer ─────────────────────────────
resource "oci_core_subnet" "lb" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.red.vcn_id
  cidr_block     = var.subnet_lb_cidr
  display_name   = "${local.prefijo}-subnet-lb"
  dns_label      = "sublb"
  route_table_id = module.red.route_table_publica_id
  freeform_tags  = local.tags_comunes

  security_list_ids = [oci_core_security_list.sl_lb.id]
}

# ─── Webserver 1 (AD1 - Privado) ──────────────────────────────────────────
module "webserver_ad1" {
  source              = "../../modulos/computo/webserver"
  compartment_id      = var.compartment_ocid
  subnet_id           = oci_core_subnet.privada_ad1.id
  availability_domain = local.ad_instancia_1
  fault_domain        = local.fd_instancia_1
  ssh_public_key      = var.ssh_public_key
  proyecto            = var.proyecto
  ambiente            = var.ambiente
  shape               = var.shape_webserver
  ocpus               = var.ocpus_webserver
  memoria_gb          = var.memoria_webserver_gb
  asignar_ip_publica  = false  # ← Sin IP pública (privado)
  cantidad            = 1
  imagen_os           = var.imagen_os != "" ? var.imagen_os : data.oci_core_images.os_image.images[0].id
  nsg_ids             = var.habilitar_nsg ? module.nsgs[0].todos_nsg_ids : []
  tags                = local.tags_comunes
}

# ─── Webserver 2 (AD2 - Privado) ──────────────────────────────────────────
module "webserver_ad2" {
  source              = "../../modulos/computo/webserver"
  compartment_id      = var.compartment_ocid
  subnet_id           = oci_core_subnet.privada_ad2.id
  availability_domain = local.ad_instancia_2
  fault_domain        = local.fd_instancia_2
  ssh_public_key      = var.ssh_public_key
  proyecto            = var.proyecto
  ambiente            = var.ambiente
  shape               = var.shape_webserver
  ocpus               = var.ocpus_webserver
  memoria_gb          = var.memoria_webserver_gb
  asignar_ip_publica  = false  # ← Sin IP pública (privado)
  cantidad            = 1
  imagen_os           = var.imagen_os != "" ? var.imagen_os : data.oci_core_images.os_image.images[0].id
  nsg_ids             = var.habilitar_nsg ? module.nsgs[0].todos_nsg_ids : []
  tags                = local.tags_comunes
}

# ─── Load Balancer (único punto de entrada HTTP) ────────────────────────────
module "load_balancer" {
  source         = "../../modulos/red/load-balancer"
  compartment_id = var.compartment_ocid
  subnet_id      = oci_core_subnet.lb.id
  proyecto       = var.proyecto
  ambiente       = var.ambiente
  tags           = local.tags_comunes

  backend_ips        = local.backend_private_ips
  shape              = "flexible"
  bandwidth_min_mbps = var.lb_bandwidth_min_mbps
  bandwidth_max_mbps = var.lb_bandwidth_max_mbps
  puerto_backend     = 80
  puerto_listener    = 80
  protocolo          = "HTTP"
}

# ─── Bastion Service (SSH seguro sin exponer puerto 22) ─────────────────────
# El Bastion Service permite crear sesiones SSH a instancias privadas
# sin necesidad de un bastion host EC2 ni abrir SSH al internet
module "bastion" {
  source                     = "../../modulos/red/bastion-service"
  compartment_id             = var.compartment_ocid
  subnet_id                  = oci_core_subnet.privada_ad1.id
  proyecto                   = var.proyecto
  ambiente                   = var.ambiente
  cidr_permitidos            = var.bastion_cidr_permitidos
  tiempo_max_sesion_segundos = var.bastion_ttl_segundos
  tags                       = local.tags_comunes
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
