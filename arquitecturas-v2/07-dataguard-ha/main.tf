# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Main - DataGuard HA (Alta Disponibilidad de Base de Datos)                 ║
# ║  Arquitectura: LB + Privados + Bastion + NFS + DB Primario + DB Standby   ║
# ║                                                                            ║
# ║  Cambios clave vs Arquitectura 06:                                         ║
# ║    - DataGuard: DB Standby automático en AD2                              ║
# ║    - Subnet DB adicional en AD2 para el standby                           ║
# ║    - Replicación async con MAXIMUM_PERFORMANCE por defecto                ║
# ║    - Failover automático posible si se configura Fast-Start Failover      ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ─── Red: VCN + IGW + NAT GW + Service GW ──────────────────────────────────
module "red" {
  source         = "../../modulos/red/vcn"
  compartment_id = var.compartment_ocid
  vcn_cidr       = var.vcn_cidr
  proyecto       = var.proyecto
  ambiente       = var.ambiente
  tags           = local.tags_comunes

  habilitar_nat_gateway     = true
  habilitar_service_gateway = true
}

# ─── Seguridad: Network Security Groups ─────────────────────────────────────
module "nsgs" {
  source             = "../../modulos/seguridad/nsg"
  count              = var.habilitar_nsg ? 1 : 0
  compartment_id     = var.compartment_ocid
  vcn_id             = module.red.vcn_id
  proyecto           = var.proyecto
  ambiente           = var.ambiente
  habilitar_nsg_web  = true
  habilitar_nsg_ssh  = true
  habilitar_nsg_nfs  = true
  habilitar_nsg_db   = true
  cidr_ssh_permitido = var.vcn_cidr
  tags               = local.tags_comunes
}

# ─── Security Lists ─────────────────────────────────────────────────────────
resource "oci_core_security_list" "sl_vacia" {
  count          = var.habilitar_nsg ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = module.red.vcn_id
  display_name   = "${local.prefijo}-sl-vacia"
  freeform_tags  = local.tags_comunes

  # Egress necesario: OCI valida acceso a Object Storage a nivel de subnet
  # (especialmente para DataGuard y DB System). NSGs controlan todo el ingreso.
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    description = "Permitir todo tráfico de salida (NSGs controlan ingreso)"
  }
}

resource "oci_core_security_list" "sl_privada" {
  count          = var.habilitar_nsg ? 0 : 1
  compartment_id = var.compartment_ocid
  vcn_id         = module.red.vcn_id
  display_name   = "${local.prefijo}-sl-privada"
  freeform_tags  = local.tags_comunes

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    description = "Permitir todo tráfico de salida"
  }

  ingress_security_rules {
    protocol    = "6"
    source      = var.vcn_cidr
    description = "SSH desde VCN (Bastion)"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = var.subnet_lb_cidr
    description = "HTTP desde LB"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = var.vcn_cidr
    description = "NFS TCP portmapper"
    tcp_options {
      min = 111
      max = 111
    }
  }

  ingress_security_rules {
    protocol    = "17"
    source      = var.vcn_cidr
    description = "NFS UDP portmapper"
    udp_options {
      min = 111
      max = 111
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = var.vcn_cidr
    description = "NFS TCP"
    tcp_options {
      min = 2048
      max = 2050
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = var.vcn_cidr
    description = "Oracle DB SQL*Net"
    tcp_options {
      min = 1521
      max = 1521
    }
  }
}

resource "oci_core_security_list" "sl_lb" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.red.vcn_id
  display_name   = "${local.prefijo}-sl-lb"
  freeform_tags  = local.tags_comunes

  egress_security_rules {
    destination = var.vcn_cidr
    protocol    = "6"
    description = "LB a backends HTTP"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "HTTP desde internet"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "HTTPS desde internet"
    tcp_options {
      min = 443
      max = 443
    }
  }
}

# ─── Subnets Privadas (Webservers + Mount Target) ──────────────────────────
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

# ─── Subnets Privadas para Base de Datos (AD1 primario, AD2 standby) ────────
resource "oci_core_subnet" "db_ad1" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = module.red.vcn_id
  cidr_block                 = var.subnet_db_ad1_cidr
  display_name               = "${local.prefijo}-subnet-db-ad1"
  dns_label                  = "subdbad1"
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

resource "oci_core_subnet" "db_ad2" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = module.red.vcn_id
  cidr_block                 = var.subnet_db_ad2_cidr
  display_name               = "${local.prefijo}-subnet-db-ad2"
  dns_label                  = "subdbad2"
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

# ─── Subnet Pública para Load Balancer ──────────────────────────────────────
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

# ─── File Storage Service (NFS Compartido) ──────────────────────────────────
module "filesystem" {
  source              = "../../modulos/almacenamiento/filesystem-compartido"
  compartment_id      = var.compartment_ocid
  availability_domain = local.ad_instancia_1
  subnet_id           = oci_core_subnet.privada_ad1.id
  proyecto            = var.proyecto
  ambiente            = var.ambiente
  ruta_exportacion    = var.nfs_ruta_exportacion
  cidr_permitido      = var.vcn_cidr
  nsg_ids             = var.habilitar_nsg ? [module.nsgs[0].nsg_nfs_id] : []
  tags                = local.tags_comunes
}

# ─── Webserver 1 (AD1 - Privado + NFS mount) ───────────────────────────────
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
  asignar_ip_publica  = false
  cantidad            = 1
  imagen_os           = var.imagen_os != "" ? var.imagen_os : data.oci_core_images.os_image.images[0].id
  nsg_ids             = var.habilitar_nsg ? module.nsgs[0].todos_nsg_ids : []
  tags                = local.tags_comunes
  userdata_extra      = local.nfs_mount_script
}

# ─── Webserver 2 (AD2 - Privado + NFS mount) ───────────────────────────────
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
  asignar_ip_publica  = false
  cantidad            = 1
  imagen_os           = var.imagen_os != "" ? var.imagen_os : data.oci_core_images.os_image.images[0].id
  nsg_ids             = var.habilitar_nsg ? module.nsgs[0].todos_nsg_ids : []
  tags                = local.tags_comunes
  userdata_extra      = local.nfs_mount_script
}

# ─── Oracle DB System (Primario - AD1) ──────────────────────────────────────
module "database" {
  source              = "../../modulos/base-de-datos/dbsystem"
  compartment_id      = var.compartment_ocid
  availability_domain = local.ad_instancia_1
  subnet_id           = oci_core_subnet.db_ad1.id
  proyecto            = var.proyecto
  ambiente            = var.ambiente
  shape               = var.shape_db
  cpu_core_count      = var.cpu_core_count_db
  db_admin_password   = var.db_admin_password
  db_name             = var.db_name
  db_version          = var.db_version
  database_edition    = var.database_edition
  license_model       = var.license_model
  ssh_public_keys     = [var.ssh_public_key]
  nsg_ids             = var.habilitar_nsg ? [module.nsgs[0].nsg_db_id, module.nsgs[0].nsg_ssh_id, module.nsgs[0].nsg_egress_id] : []
  tags                = local.tags_comunes
}

# ─── DataGuard (Standby - AD2) ──────────────────────────────────────────────
# Crea automáticamente un nuevo DB System standby en AD2 que replica
# desde el primario en AD1 usando Oracle Data Guard.
module "dataguard" {
  source              = "../../modulos/base-de-datos/dataguard"
  primary_database_id = module.database.database_id
  db_admin_password   = var.db_admin_password
  availability_domain = local.ad_instancia_2
  subnet_id           = oci_core_subnet.db_ad2.id
  proyecto            = var.proyecto
  ambiente            = var.ambiente
  shape               = var.shape_db
  cpu_core_count      = var.cpu_core_count_db
  protection_mode     = var.dataguard_protection_mode
  transport_type      = var.dataguard_transport_type
  nsg_ids             = var.habilitar_nsg ? [module.nsgs[0].nsg_db_id, module.nsgs[0].nsg_ssh_id, module.nsgs[0].nsg_egress_id] : []
}

# ─── Load Balancer ──────────────────────────────────────────────────────────
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

# ─── Bastion Service ────────────────────────────────────────────────────────
module "bastion" {
  source                     = "../../modulos/red/bastion-service"
  compartment_id             = var.compartment_ocid
  subnet_id                  = oci_core_subnet.privada_ad1.id
  proyecto                   = var.proyecto
  ambiente                   = var.ambiente
  cidr_permitidos            = var.bastion_cidr_permitidos
  tiempo_max_sesion_segundos = 10800
  tags                       = local.tags_comunes
}

# ─── Baselines (opcional) ───────────────────────────────────────────────────
module "baselines" {
  source         = "../../modulos/seguridad/baselines"
  count          = var.habilitar_baseline_seguridad ? 1 : 0
  compartment_id = var.compartment_ocid
  tenancy_ocid   = var.tenancy_ocid
  proyecto       = var.proyecto
  ambiente       = var.ambiente
  tags           = local.tags_comunes
}
