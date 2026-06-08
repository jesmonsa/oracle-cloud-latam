# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  OKE Cluster Básico — Arquitectura de Referencia                            ║
# ║                                                                              ║
# ║  Topología:                                                                  ║
# ║                                                                              ║
# ║    Internet ──► LB Subnet (pública) ──► K8s Service (LoadBalancer)          ║
# ║                                              │                              ║
# ║                                    ┌─────────▼──────────┐                  ║
# ║                                    │   OKE Cluster       │                  ║
# ║                                    │   (Control Plane)   │                  ║
# ║                                    │   API Endpoint ◄─── │─── kubectl       ║
# ║                                    └─────────┬──────────┘                  ║
# ║                                              │                              ║
# ║                                    ┌─────────▼──────────┐                  ║
# ║                                    │    Node Pool        │                  ║
# ║                                    │  (N workers priv.)  │                  ║
# ║                                    │  Flannel Overlay    │                  ║
# ║                                    └────────────────────┘                  ║
# ║                                                                              ║
# ║  Componentes Desplegados:                                                   ║
# ║    • VCN con gateways (NAT, Service Gateway)                               ║
# ║    • 3 subnets: API Endpoint (pública), LB (pública), Nodes (privada)      ║
# ║    • Security Lists optimizadas para Kubernetes                             ║
# ║    • Route Table con NAT y Service Gateway para nodos privados             ║
# ║    • Cluster OKE con Flannel CNI                                            ║
# ║    • Node Pool con workers en subnet privada                                ║
# ║                                                                              ║
# ║  Uso:                                                                        ║
# ║    terraform init        # Inicializa estado remoto                         ║
# ║    terraform plan        # Vista previa                                     ║
# ║    terraform apply       # Desplega la infraestructura                      ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

locals {
  prefijo = "${var.proyecto}-${var.ambiente}"
  tags_comunes = {
    Arquitectura = "oke-cluster-basico"
    Proyecto     = var.proyecto
    Ambiente     = var.ambiente
    Propietario  = var.propietario
    ManagedBy    = "terraform"
  }
}

# ═══════════════════════════════════════════════════════════════════════════════
#  Data Sources
# ═══════════════════════════════════════════════════════════════════════════════

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_images" "ol8_oke" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.node_shape
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
#  1. VCN + Gateways (módulo reusable)
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

# ═══════════════════════════════════════════════════════════════════════════════
#  2. Security Lists para OKE
# ═══════════════════════════════════════════════════════════════════════════════

# Security List para API Endpoint (pública)
resource "oci_core_security_list" "sl_api" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.red.vcn_id
  display_name   = "${local.prefijo}-sl-oke-api"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
  }

  # Kubernetes API — acceso desde kubectl y herramientas de administración
  ingress_security_rules {
    source    = "0.0.0.0/0"
    protocol  = "6"
    stateless = false
    tcp_options {
      min = 6443
      max = 6443
    }
  }

  # Comunicación entre control plane y worker nodes (kubelet API)
  ingress_security_rules {
    source    = var.subnet_nodepool_cidr
    protocol  = "6"
    stateless = false
    tcp_options {
      min = 12250
      max = 12250
    }
  }

  # ICMP para path discovery
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

# Security List para Node Pool (privada)
resource "oci_core_security_list" "sl_nodes" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.red.vcn_id
  display_name   = "${local.prefijo}-sl-oke-nodes"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
  }

  # Comunicación intra-nodos (pods Flannel, kubelet)
  ingress_security_rules {
    source    = var.subnet_nodepool_cidr
    protocol  = "all"
    stateless = false
  }

  # Desde API endpoint (control plane → workers)
  ingress_security_rules {
    source    = var.subnet_api_cidr
    protocol  = "all"
    stateless = false
  }

  # ICMP para path discovery
  ingress_security_rules {
    source    = "0.0.0.0/0"
    protocol  = "1"
    stateless = false
    icmp_options {
      type = 3
      code = 4
    }
  }

  # NodePort range para Services tipo NodePort/LoadBalancer
  ingress_security_rules {
    source    = var.subnet_lb_cidr
    protocol  = "6"
    stateless = false
    tcp_options {
      min = 30000
      max = 32767
    }
  }

  # SSH para debug desde dentro de la VCN
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

# Security List para Load Balancer (pública)
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
#  3. Route Table para Node Pool (NAT + Service Gateway)
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_core_route_table" "rt_nodes" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.red.vcn_id
  display_name   = "${local.prefijo}-rt-oke-nodes"
  freeform_tags  = local.tags_comunes

  # Ruta por defecto a través de NAT Gateway para acceso a internet
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = module.red.nat_gateway_id
  }

  # Ruta a Oracle Services Network a través de Service Gateway
  route_rules {
    destination       = data.oci_core_services.all_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = module.red.service_gateway_id
  }
}

# ═══════════════════════════════════════════════════════════════════════════════
#  4. Subnets (3 subnets dedicadas para OKE)
# ═══════════════════════════════════════════════════════════════════════════════

# Subnet pública para K8s API Endpoint
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

# Subnet pública para OCI Load Balancers (K8s Services tipo LoadBalancer)
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

# Subnet privada para Worker Nodes
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

  # Flannel Overlay CNI — simple y estable para producción
  cluster_pod_network_options {
    cni_type = "FLANNEL_OVERLAY"
  }

  # API Endpoint público — accesible desde kubectl
  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = oci_core_subnet.api.id
  }

  options {
    # Subnet donde OKE crea Load Balancers para Services tipo LoadBalancer
    service_lb_subnet_ids = [oci_core_subnet.lb.id]

    kubernetes_network_config {
      pods_cidr     = var.pods_cidr
      services_cidr = var.services_cidr
    }
  }

  freeform_tags = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  6. Node Pool (Worker nodes en subnet privada)
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_containerengine_node_pool" "pool" {
  compartment_id     = var.compartment_ocid
  cluster_id         = oci_containerengine_cluster.cluster.id
  kubernetes_version = var.k8s_version
  name               = substr("${local.prefijo}-np01", 0, 32)

  node_shape = var.node_shape
  node_shape_config {
    ocpus         = var.node_ocpus
    memory_in_gbs = var.node_memoria_gb
  }

  node_source_details {
    source_type = "IMAGE"
    image_id    = data.oci_core_images.ol8_oke.images[0].id
  }

  node_config_details {
    size = var.node_pool_size

    # Distribución de nodos en ADs disponibles
    dynamic "placement_configs" {
      for_each = [for i in range(min(var.node_pool_size, length(data.oci_identity_availability_domains.ads.availability_domains))) :
        data.oci_identity_availability_domains.ads.availability_domains[i].name
      ]
      content {
        availability_domain = placement_configs.value
        subnet_id           = oci_core_subnet.nodes.id
      }
    }
  }

  ssh_public_key = var.ssh_public_key

  freeform_tags = local.tags_comunes
}
