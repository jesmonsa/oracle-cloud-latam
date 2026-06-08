# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Track OKE — Lección 02: Node Pools Flex (E4 x86 + A1 ARM)               ║
# ║                                                                            ║
# ║  Topología:                                                                ║
# ║                                                                            ║
# ║    Internet ──► LB Subnet (pública) ──► K8s Service (LoadBalancer)         ║
# ║                                              │                             ║
# ║                                    ┌─────────▼──────────┐                 ║
# ║                                    │   OKE Cluster       │                 ║
# ║                                    │   (Control Plane)   │                 ║
# ║                                    │   Flannel CNI       │                 ║
# ║                                    └────┬──────────┬────┘                 ║
# ║                                         │          │                       ║
# ║                              ┌──────────▼──┐  ┌───▼──────────┐           ║
# ║                              │  NP-01 x86  │  │  NP-02 ARM   │           ║
# ║                              │  E4.Flex     │  │  A1.Flex     │           ║
# ║                              │  1 worker    │  │  1 worker    │           ║
# ║                              └──────────────┘  └──────────────┘           ║
# ║                                                                            ║
# ║  Qué aprenderás:                                                           ║
# ║    ✓ Crear múltiples Node Pools en un mismo cluster                       ║
# ║    ✓ Mezclar arquitecturas x86 (E4 Flex) y ARM (A1 Flex)                 ║
# ║    ✓ Seleccionar imágenes OS distintas por arquitectura                   ║
# ║    ✓ Configurar Flex Shapes (OCPUs + RAM independientes)                  ║
# ║    ✓ Entender scheduling en clusters heterogéneos                         ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

locals {
  prefijo = "${var.proyecto}-${var.ambiente}"
  tags_comunes = {
    Proyecto    = var.proyecto
    Ambiente    = var.ambiente
    Propietario = var.propietario
    Track       = "oke-kubernetes"
    Leccion     = "02-node-pools-flex"
    ManagedBy   = "terraform"
  }
}

# ═══════════════════════════════════════════════════════════════════════════════
#  Data Sources
# ═══════════════════════════════════════════════════════════════════════════════

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# Imagen Oracle Linux 8 para x86 (E4 Flex)
data "oci_core_images" "ol8_x86" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.np_x86_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# Imagen Oracle Linux 8 para ARM / aarch64 (A1 Flex)
data "oci_core_images" "ol8_arm" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.np_arm_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

# ═══════════════════════════════════════════════════════════════════════════════
#  1. VCN + Gateways (reutilizando módulo VCN)
# ═══════════════════════════════════════════════════════════════════════════════

module "red" {
  source = "../../../modulos/red/vcn"

  compartment_id            = var.compartment_ocid
  proyecto                  = var.proyecto
  ambiente                  = var.ambiente
  vcn_cidr                  = var.vcn_cidr
  habilitar_nat_gateway     = true
  habilitar_service_gateway = true
  tags                      = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  2. Security Lists para OKE (idénticas a lección 01)
# ═══════════════════════════════════════════════════════════════════════════════

# --- SL para API Endpoint (pública) ---
resource "oci_core_security_list" "sl_api" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.red.vcn_id
  display_name   = "${local.prefijo}-sl-oke-api"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
  }

  # K8s API — acceso desde kubectl
  ingress_security_rules {
    source    = "0.0.0.0/0"
    protocol  = "6"
    stateless = false
    tcp_options {
      min = 6443
      max = 6443
    }
  }

  # Comunicación control plane → worker nodes
  ingress_security_rules {
    source    = var.subnet_nodepool_cidr
    protocol  = "6"
    stateless = false
    tcp_options {
      min = 12250
      max = 12250
    }
  }

  # ICMP Path Discovery
  ingress_security_rules {
    source    = var.subnet_nodepool_cidr
    protocol  = "1"
    stateless = false
    icmp_options {
      type = 3
      code = 4
    }
  }

  freeform_tags = local.tags_comunes
}

# --- SL para Node Pools (privada) ---
resource "oci_core_security_list" "sl_nodes" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.red.vcn_id
  display_name   = "${local.prefijo}-sl-oke-nodes"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
  }

  # Comunicación intra-nodes (pods Flannel — ambos pools)
  ingress_security_rules {
    source    = var.subnet_nodepool_cidr
    protocol  = "all"
    stateless = false
  }

  # Desde API endpoint (control plane)
  ingress_security_rules {
    source    = var.subnet_api_cidr
    protocol  = "all"
    stateless = false
  }

  # ICMP Path Discovery
  ingress_security_rules {
    source    = "0.0.0.0/0"
    protocol  = "1"
    stateless = false
    icmp_options {
      type = 3
      code = 4
    }
  }

  # NodePort range (para Services tipo NodePort/LoadBalancer)
  ingress_security_rules {
    source    = var.subnet_lb_cidr
    protocol  = "6"
    stateless = false
    tcp_options {
      min = 30000
      max = 32767
    }
  }

  # SSH para debug (desde VCN)
  ingress_security_rules {
    source    = var.vcn_cidr
    protocol  = "6"
    stateless = false
    tcp_options {
      min = 22
      max = 22
    }
  }

  freeform_tags = local.tags_comunes
}

# --- SL para Load Balancer (pública) ---
resource "oci_core_security_list" "sl_lb" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.red.vcn_id
  display_name   = "${local.prefijo}-sl-oke-lb"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
  }

  # HTTP
  ingress_security_rules {
    source    = "0.0.0.0/0"
    protocol  = "6"
    stateless = false
    tcp_options {
      min = 80
      max = 80
    }
  }

  # HTTPS
  ingress_security_rules {
    source    = "0.0.0.0/0"
    protocol  = "6"
    stateless = false
    tcp_options {
      min = 443
      max = 443
    }
  }

  freeform_tags = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  3. Route Table para Nodes (NAT + SGW)
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_core_route_table" "rt_nodes" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.red.vcn_id
  display_name   = "${local.prefijo}-rt-oke-nodes"
  freeform_tags  = local.tags_comunes

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = module.red.nat_gateway_id
  }

  route_rules {
    destination       = data.oci_core_services.all_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = module.red.service_gateway_id
  }
}

# ═══════════════════════════════════════════════════════════════════════════════
#  4. Subnets (3 subnets — misma topología que lección 01)
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_core_subnet" "api" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = module.red.vcn_id
  cidr_block                 = var.subnet_api_cidr
  display_name               = "${local.prefijo}-sub-oke-api"
  dns_label                  = "okeapi"
  prohibit_public_ip_on_vnic = false
  route_table_id             = module.red.route_table_publica_id
  security_list_ids          = [oci_core_security_list.sl_api.id]
  freeform_tags              = local.tags_comunes
}

resource "oci_core_subnet" "lb" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = module.red.vcn_id
  cidr_block                 = var.subnet_lb_cidr
  display_name               = "${local.prefijo}-sub-oke-lb"
  dns_label                  = "okelb"
  prohibit_public_ip_on_vnic = false
  route_table_id             = module.red.route_table_publica_id
  security_list_ids          = [oci_core_security_list.sl_lb.id]
  freeform_tags              = local.tags_comunes
}

resource "oci_core_subnet" "nodes" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = module.red.vcn_id
  cidr_block                 = var.subnet_nodepool_cidr
  display_name               = "${local.prefijo}-sub-oke-nodes"
  dns_label                  = "okenodes"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.rt_nodes.id
  security_list_ids          = [oci_core_security_list.sl_nodes.id]
  freeform_tags              = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  5. OKE Cluster (Flannel CNI)
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_containerengine_cluster" "cluster" {
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.k8s_version
  name               = "${local.prefijo}-oke"
  vcn_id             = module.red.vcn_id

  cluster_pod_network_options {
    cni_type = "FLANNEL_OVERLAY"
  }

  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = oci_core_subnet.api.id
  }

  options {
    service_lb_subnet_ids = [oci_core_subnet.lb.id]

    kubernetes_network_config {
      pods_cidr     = var.pods_cidr
      services_cidr = var.services_cidr
    }
  }

  freeform_tags = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  6. Node Pool 1 — E4 Flex (x86_64)
#     Workers de propósito general, arquitectura x86
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_containerengine_node_pool" "np_x86" {
  compartment_id     = var.compartment_ocid
  cluster_id         = oci_containerengine_cluster.cluster.id
  kubernetes_version = var.k8s_version
  name               = "${local.prefijo}-np-x86"

  node_shape = var.np_x86_shape
  node_shape_config {
    ocpus         = var.np_x86_ocpus
    memory_in_gbs = var.np_x86_memoria_gb
  }

  node_source_details {
    source_type = "IMAGE"
    image_id    = data.oci_core_images.ol8_x86.images[0].id
  }

  node_config_details {
    size = var.np_x86_size

    dynamic "placement_configs" {
      for_each = [for i in range(min(var.np_x86_size, length(data.oci_identity_availability_domains.ads.availability_domains))) :
        data.oci_identity_availability_domains.ads.availability_domains[i].name
      ]
      content {
        availability_domain = placement_configs.value
        subnet_id           = oci_core_subnet.nodes.id
      }
    }
  }

  ssh_public_key = var.ssh_public_key

  freeform_tags = merge(local.tags_comunes, {
    Arquitectura = "x86_64"
    NodePool     = "np-x86"
  })
}

# ═══════════════════════════════════════════════════════════════════════════════
#  7. Node Pool 2 — A1 Flex (ARM / Ampere aarch64)
#     Workers ARM, ideal para workloads cost-effective
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_containerengine_node_pool" "np_arm" {
  compartment_id     = var.compartment_ocid
  cluster_id         = oci_containerengine_cluster.cluster.id
  kubernetes_version = var.k8s_version
  name               = "${local.prefijo}-np-arm"

  node_shape = var.np_arm_shape
  node_shape_config {
    ocpus         = var.np_arm_ocpus
    memory_in_gbs = var.np_arm_memoria_gb
  }

  node_source_details {
    source_type = "IMAGE"
    image_id    = data.oci_core_images.ol8_arm.images[0].id
  }

  node_config_details {
    size = var.np_arm_size

    dynamic "placement_configs" {
      for_each = [for i in range(min(var.np_arm_size, length(data.oci_identity_availability_domains.ads.availability_domains))) :
        data.oci_identity_availability_domains.ads.availability_domains[i].name
      ]
      content {
        availability_domain = placement_configs.value
        subnet_id           = oci_core_subnet.nodes.id
      }
    }
  }

  ssh_public_key = var.ssh_public_key

  freeform_tags = merge(local.tags_comunes, {
    Arquitectura = "aarch64"
    NodePool     = "np-arm"
  })
}
