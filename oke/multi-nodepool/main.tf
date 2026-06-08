# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  OKE Multi Node Pool — Arquitectura de Referencia                            ║
# ║  Cluster Kubernetes heterogéneo con nodos x86 (E4) y ARM (A1)               ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ============================================================================
# LOCALS Y CONFIGURACIÓN
# ============================================================================

locals {
  prefijo = "${var.proyecto}-${var.ambiente}"

  # Tags empresariales con información de proyecto y propietario
  tags_base = merge(
    var.tags_empresariales,
    {
      Proyecto      = var.proyecto
      Ambiente      = var.ambiente
      Propietario   = var.propietario
      Equipo        = var.equipo_responsable
      CreatedAt     = timestamp()
      CreatedBy     = "Terraform"
    }
  )

  # Nombre del cluster
  cluster_display_name = var.cluster_name != "" ? var.cluster_name : "${local.prefijo}-oke-cluster"
}

# ============================================================================
# TOPOLOGÍA DE ARQUITECTURA
# ============================================================================
#
# ┌─────────────────────────────────────────────────────────────┐
# │                          VCN (10.0.0.0/16)                  │
# │  ┌────────────────────────────────────────────────────┐   │
# │  │  Internet Gateway                                    │   │
# │  └─────────────────────┬──────────────────────────────┘   │
# │                        │                                     │
# │  ┌─────────────────────┴─────────────────────┐               │
# │  │  NAT Gateway (outbound traffic)           │               │
# │  └───────────────────────────────────────────┘               │
# │                                                              │
# │  ┌─────────────┐  ┌─────────────┐  ┌──────────────────┐    │
# │  │  Subnet API │  │  Subnet LB  │  │ Subnet NodePool  │    │
# │  │ (10.0.1/24) │  │(10.0.2.0/24)│  │  (10.0.3.0/23)   │    │
# │  ├─────────────┤  ├─────────────┤  ├──────────────────┤    │
# │  │ K8s API     │  │ Services    │  │ ▪ Node Pool x86  │    │
# │  │ Endpoint    │  │ LB (Layer4) │  │   (E4 Flex)      │    │
# │  │             │  │             │  │ ▪ Node Pool ARM  │    │
# │  │             │  │             │  │   (A1 Flex)      │    │
# │  └─────────────┘  └─────────────┘  └──────────────────┘    │
# │                                                              │
# │  ┌────────────────────────────────────────────────┐     │
# │  │  Service Gateway (acceso a servicios OCI)          │     │
# │  └────────────────────────────────────────────────┘     │
# │                                                              │
# └──────────────────────────────────────────────────────────────┘
#
# CIDR Kubernetes:
# - PODs:     10.244.0.0/16   (Flannel CNI overlay)
# - Services: 10.96.0.0/12    (ClusterIP, NodePort, LoadBalancer)

# ============================================================================
# COMPONENTES DESPLEGADOS
# ============================================================================
#
# 1. INFRAESTRUCTURA DE RED (VCN Module)
#    ✓ Virtual Cloud Network con subredes segregadas
#    ✓ 3 subredes: API, Load Balancer, Node Pools
#    ✓ Internet Gateway para tráfico saliente
#    ✓ NAT Gateway para instancias privadas
#    ✓ Service Gateway para acceso a servicios OCI
#    ✓ Route Tables (pública y privada)
#    ✓ Security Lists con reglas de ingreso/egreso
#
# 2. CLUSTER DE KUBERNETES (OKE)
#    ✓ Control Plane administrado por OCI
#    ✓ Kubernetes v1.32.1
#    ✓ Networking: Flannel Overlay CNI
#    ✓ API Endpoint seguro
#
# 3. NODE POOL x86 (E4 Flex)
#    ✓ Shape: VM.Standard.E4.Flex
#    ✓ Arquitectura: x86_64
#    ✓ Imágenes: Ubuntu Linux para x86
#    ✓ Auto-scaling disponible
#
# 4. NODE POOL ARM (A1 Flex)
#    ✓ Shape: VM.Standard.A1.Flex
#    ✓ Arquitectura: aarch64 (ARM64)
#    ✓ Imágenes: Ubuntu Linux para ARM
#    ✓ Auto-scaling disponible

# ============================================================================
# MÓDULO VCN — INFRAESTRUCTURA DE RED
# ============================================================================

module "vcn" {
  source = "../../modulos/red/vcn"

  compartment_id              = var.compartment_id
  vcn_cidr                    = var.vcn_cidr
  proyecto                    = var.proyecto
  ambiente                    = var.ambiente
  habilitar_nat_gateway       = true
  habilitar_service_gateway   = true

  tags = local.tags_base

  providers = {
    oci = oci
  }
}

# ============================================================================
# SUBREDES PARA KUBERNETES
# ============================================================================

# Subred para API endpoint y control plane
resource "oci_core_subnet" "api" {
  compartment_id      = var.compartment_id
  vcn_id              = module.vcn.vcn_id
  cidr_block          = var.subnet_api_cidr
  display_name        = "${local.prefijo}-subnet-api"
  dns_label           = "api${var.ambiente}"
  route_table_id      = module.vcn.route_table_publica_id
  dhcp_options_id     = oci_core_dhcp_options.default.id
  security_list_ids   = [oci_core_security_list.api.id]

  freeform_tags = merge(local.tags_base, {
    Name = "api-endpoint"
  })
}

# Subred para Load Balancers (capa 4)
resource "oci_core_subnet" "lb" {
  compartment_id      = var.compartment_id
  vcn_id              = module.vcn.vcn_id
  cidr_block          = var.subnet_lb_cidr
  display_name        = "${local.prefijo}-subnet-lb"
  dns_label           = "lb${var.ambiente}"
  route_table_id      = module.vcn.route_table_publica_id
  dhcp_options_id     = oci_core_dhcp_options.default.id
  security_list_ids   = [oci_core_security_list.lb.id]

  freeform_tags = merge(local.tags_base, {
    Name = "load-balancer"
  })
}

# Subred para Node Pools (nodos de computación)
resource "oci_core_subnet" "nodepool" {
  compartment_id      = var.compartment_id
  vcn_id              = module.vcn.vcn_id
  cidr_block          = var.subnet_nodepool_cidr
  display_name        = "${local.prefijo}-subnet-nodepool"
  dns_label           = "nodes${var.ambiente}"
  route_table_id      = module.vcn.route_table_privada_id
  dhcp_options_id     = oci_core_dhcp_options.default.id
  security_list_ids   = [oci_core_security_list.nodepool.id]

  freeform_tags = merge(local.tags_base, {
    Name = "node-pools"
  })
}

# ============================================================================
# OPCIONES DHCP
# ============================================================================

resource "oci_core_dhcp_options" "default" {
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  display_name   = "${local.prefijo}-dhcp-default"

  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  options {
    type                = "SearchDomain"
    search_domain_names = ["${var.ambiente}.oraclevcn.com"]
  }

  freeform_tags = local.tags_base
}

# ============================================================================
# SECURITY LISTS
# ============================================================================

# Security List para API endpoint
resource "oci_core_security_list" "api" {
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  display_name   = "${local.prefijo}-seclist-api"

  # Ingreso: HTTPS desde internet
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    stateless   = false
    source_type = "CIDR_BLOCK"

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  # Egreso: Todo
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless   = false
  }

  freeform_tags = local.tags_base
}

# Security List para Load Balancers
resource "oci_core_security_list" "lb" {
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  display_name   = "${local.prefijo}-seclist-lb"

  # Ingreso: HTTP y HTTPS desde internet
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    stateless   = false
    source_type = "CIDR_BLOCK"

    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    stateless   = false
    source_type = "CIDR_BLOCK"

    tcp_options {
      min = 443
      max = 443
    }
  }

  # Egreso: Todo
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless   = false
  }

  freeform_tags = local.tags_base
}

# Security List para Node Pools
resource "oci_core_security_list" "nodepool" {
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  display_name   = "${local.prefijo}-seclist-nodepool"

  # Ingreso: Todo desde VCN
  ingress_security_rules {
    protocol    = "all"
    source      = var.vcn_cidr
    stateless   = false
    source_type = "CIDR_BLOCK"
  }

  # Egreso: Todo
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless   = false
  }

  freeform_tags = local.tags_base
}

# ============================================================================
# DATA SOURCES: IMÁGENES DEL SISTEMA OPERATIVO
# ============================================================================

# Imágenes para x86 (E4 Flex) — Ubuntu 22.04 LTS
data "oci_core_images" "ol8_x86" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.np_x86_shape
  sort_by                  = "TIMECREATED"

  filter {
    name   = "display_name"
    values = ["^Canonical-Ubuntu-22\\.04.*"]
    regex  = true
  }
}

# Imágenes para ARM (A1 Flex) — Ubuntu 22.04 LTS ARM
data "oci_core_images" "ol8_arm" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.np_arm_shape
  sort_by                  = "TIMECREATED"

  filter {
    name   = "display_name"
    values = ["^Canonical-Ubuntu-22\\.04.*aarch64.*"]
    regex  = true
  }
}

# ============================================================================
# CLUSTER KUBERNETES (ORACLE CONTAINER ENGINE)
# ============================================================================

resource "oci_containerengine_cluster" "oke" {
  compartment_id     = var.compartment_id
  kubernetes_version = var.kubernetes_version
  name               = local.cluster_display_name
  vcn_id             = module.vcn.vcn_id

  # API Endpoint público para acceso con kubectl
  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = oci_core_subnet.api.id
  }

  # Configuración de red
  cluster_pod_network_options {
    cni_type = "FLANNEL_OVERLAY"
  }

  # Configuración de seguridad
  options {
    kubernetes_network_config {
      pods_cidr     = var.pods_cidr
      services_cidr = var.services_cidr
    }

    service_lb_subnet_ids = [oci_core_subnet.lb.id]

    persistent_volume_config {
      freeform_tags = local.tags_base
    }
  }

  # Type: BASIC_CLUSTER (sin costo adicional)
  type = "BASIC_CLUSTER"

  freeform_tags = merge(local.tags_base, {
    Name            = "kubernetes-cluster"
    KubernetesVer   = var.kubernetes_version
  })

  depends_on = [
    module.vcn
  ]
}

# ============================================================================
# NODE POOL x86 (E4 Flex) — NODOS ESTÁNDAR
# ============================================================================

resource "oci_containerengine_node_pool" "np_x86" {
  cluster_id         = oci_containerengine_cluster.oke.id
  compartment_id     = var.compartment_id
  kubernetes_version = var.kubernetes_version
  name               = "${local.prefijo}-np-x86"
  node_shape         = var.np_x86_shape

  # Configuración de nodos
  node_config_details {
    size = var.np_x86_size

    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      subnet_id           = oci_core_subnet.nodepool.id
    }

    freeform_tags = merge(local.tags_base, {
      Arquitectura = "x86_64"
      NodePool     = "np-x86"
      Shape        = var.np_x86_shape
    })
  }

  # Configuración de instancia flexible
  node_shape_config {
    ocpus         = var.np_x86_ocpus
    memory_in_gbs = var.np_x86_memoria_gb
  }

  # Imagen del sistema operativo
  node_source_details {
    image_id    = data.oci_core_images.ol8_x86.images[0].id
    source_type = "IMAGE"
  }

  # Configuración de seguridad
  ssh_public_key = var.ssh_public_key

  initial_node_labels {
    key   = "workload-type"
    value = "compute"
  }

  initial_node_labels {
    key   = "arch"
    value = "x86_64"
  }

  freeform_tags = merge(local.tags_base, {
    NodePool = "np-x86"
  })

  depends_on = [
    oci_containerengine_cluster.oke
  ]
}

# ============================================================================
# NODE POOL ARM (A1 Flex) — NODOS CON ARQUITECTURA ARM64
# ============================================================================

resource "oci_containerengine_node_pool" "np_arm" {
  cluster_id         = oci_containerengine_cluster.oke.id
  compartment_id     = var.compartment_id
  kubernetes_version = var.kubernetes_version
  name               = "${local.prefijo}-np-arm"
  node_shape         = var.np_arm_shape

  # Configuración de nodos
  node_config_details {
    size = var.np_arm_size

    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      subnet_id           = oci_core_subnet.nodepool.id
    }

    freeform_tags = merge(local.tags_base, {
      Arquitectura = "aarch64"
      NodePool     = "np-arm"
      Shape        = var.np_arm_shape
    })
  }

  # Configuración de instancia flexible
  node_shape_config {
    ocpus         = var.np_arm_ocpus
    memory_in_gbs = var.np_arm_memoria_gb
  }

  # Imagen del sistema operativo
  node_source_details {
    image_id    = data.oci_core_images.ol8_arm.images[0].id
    source_type = "IMAGE"
  }

  # Configuración de seguridad
  ssh_public_key = var.ssh_public_key

  initial_node_labels {
    key   = "workload-type"
    value = "compute"
  }

  initial_node_labels {
    key   = "arch"
    value = "aarch64"
  }

  freeform_tags = merge(local.tags_base, {
    NodePool = "np-arm"
  })

  depends_on = [
    oci_containerengine_cluster.oke
  ]
}

# ============================================================================
# DATA SOURCES: AVAILABILITY DOMAINS
# ============================================================================

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}
