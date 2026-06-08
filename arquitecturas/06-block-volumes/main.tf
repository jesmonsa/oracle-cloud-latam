module "red" {
  source                = "../../modulos/red/vcn"
  compartment_id        = var.compartment_ocid
  vcn_cidr              = var.vcn_cidr
  proyecto              = var.proyecto
  ambiente              = var.ambiente
  habilitar_nat_gateway = true
  tags                  = local.tags_comunes
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

# Subnet Pública (LB)
resource "oci_core_subnet" "publica" {
  compartment_id    = var.compartment_ocid
  vcn_id            = module.red.vcn_id
  cidr_block        = var.subnet_publica_cidr
  display_name      = "${var.proyecto}-${var.ambiente}-subnet-publica"
  dns_label         = "subpub"
  route_table_id    = module.red.route_table_publica_id
  security_list_ids = []
  freeform_tags     = local.tags_comunes
}

# Subnet Privada (Bastion, Webservers)
resource "oci_core_subnet" "privada" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = module.red.vcn_id
  cidr_block                 = var.subnet_privada_cidr
  prohibit_public_ip_on_vnic = true
  display_name               = "${var.proyecto}-${var.ambiente}-subnet-privada"
  dns_label                  = "subpriv"
  route_table_id             = module.red.route_table_privada_id
  security_list_ids          = []
  freeform_tags              = local.tags_comunes
}

module "webserver_fd1" {
  source              = "../../modulos/computo/webserver"
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ad.availability_domains[0].name
  fault_domain        = data.oci_identity_fault_domains.fd.fault_domains[0].name
  subnet_id           = oci_core_subnet.privada.id
  ssh_public_key      = var.ssh_public_key
  proyecto            = "${var.proyecto}-fd1"
  ambiente            = var.ambiente
  shape               = var.shape_webserver
  ocpus               = var.ocpus_webserver
  memoria_gb          = var.memoria_webserver_gb
  asignar_ip_publica  = false
  cantidad            = 1
  imagen_os           = var.imagen_os != "" ? var.imagen_os : data.oci_core_images.os_image.images[0].id
  nsg_ids             = var.habilitar_nsg ? module.nsgs[0].todos_nsg_ids : []
  tags                = local.tags_comunes
}

module "webserver_fd2" {
  source              = "../../modulos/computo/webserver"
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ad.availability_domains[0].name
  fault_domain        = data.oci_identity_fault_domains.fd.fault_domains[1].name
  subnet_id           = oci_core_subnet.privada.id
  ssh_public_key      = var.ssh_public_key
  proyecto            = "${var.proyecto}-fd2"
  ambiente            = var.ambiente
  shape               = var.shape_webserver
  ocpus               = var.ocpus_webserver
  memoria_gb          = var.memoria_webserver_gb
  asignar_ip_publica  = false
  cantidad            = 1
  imagen_os           = var.imagen_os != "" ? var.imagen_os : data.oci_core_images.os_image.images[0].id
  nsg_ids             = var.habilitar_nsg ? module.nsgs[0].todos_nsg_ids : []
  tags                = local.tags_comunes
}

# Block Volumes para cada WebServer (iSCSI por defecto en el módulo)
module "bv_fd1" {
  source              = "../../modulos/almacenamiento/block-volume"
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ad.availability_domains[0].name
  instancia_id        = module.webserver_fd1.instancia_ids[0]
  proyecto            = "${var.proyecto}-fd1"
  ambiente            = var.ambiente
  tamano_gb           = var.tamano_block_volume_gb
  punto_montaje       = "/u01"
  tags                = local.tags_comunes
}

module "bv_fd2" {
  source              = "../../modulos/almacenamiento/block-volume"
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ad.availability_domains[0].name
  instancia_id        = module.webserver_fd2.instancia_ids[0]
  proyecto            = "${var.proyecto}-fd2"
  ambiente            = var.ambiente
  tamano_gb           = var.tamano_block_volume_gb
  punto_montaje       = "/u01"
  tags                = local.tags_comunes
}

module "bastion" {
  source          = "../../modulos/red/bastion-service"
  compartment_id  = var.compartment_ocid
  subnet_id       = oci_core_subnet.privada.id
  proyecto        = var.proyecto
  ambiente        = var.ambiente
  cidr_permitidos = [var.ssh_cidr_permitido]
  tags            = local.tags_comunes
}

module "load_balancer" {
  source         = "../../modulos/red/load-balancer"
  compartment_id = var.compartment_ocid
  subnet_id      = oci_core_subnet.publica.id
  backend_ips = [
    module.webserver_fd1.ips_privadas[0],
    module.webserver_fd2.ips_privadas[0]
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
