# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  13 - OKE (Oracle Kubernetes Engine) — Cluster Gestionado                  ║
# ║                                                                            ║
# ║  Topología:                                                                ║
# ║                                                                            ║
# ║    Internet ──► LB Subnet ──► K8s Service (LoadBalancer)                   ║
# ║                                    │                                       ║
# ║                              ┌─────▼─────┐                                ║
# ║                              │ OKE Cluster│ ◄── API Endpoint (privado)     ║
# ║                              │ (Control)  │                                ║
# ║                              └─────┬─────┘                                ║
# ║                                    │                                       ║
# ║                              ┌─────▼─────┐                                ║
# ║                              │ Node Pool  │ Worker Nodes (privados)        ║
# ║                              │ (1-3 nodos)│                                ║
# ║                              └────────────┘                                ║
# ║                                                                            ║
# ║  Subnets:                                                                  ║
# ║    - API Endpoint:  10.0.0.0/28  (pública, K8s API)                       ║
# ║    - LB Services:   10.0.1.0/24  (pública, Service type LB)              ║
# ║    - Node Pool:     10.0.10.0/24 (privada, worker nodes)                  ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

locals {
  prefijo = "${var.proyecto}-${var.ambiente}"
  tags_comunes = {
    Proyecto     = var.proyecto
    Ambiente     = var.ambiente
    Propietario  = var.propietario
    Arquitectura = "13-oke-kubernetes"
    ManagedBy    = "terraform"
  }
}

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
#  1. VCN + Gateways
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
#  2. SECURITY LISTS para OKE
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_core_security_list" "sl_api" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.red.vcn_id
  display_name   = "${local.prefijo}-sl-api"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
  }

  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "6"
    stateless = false
    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    source   = var.subnet_nodepool_cidr
    protocol = "6"
    stateless = false
    tcp_options {
      min = 12250
      max = 12250
    }
  }

  ingress_security_rules {
    source   = var.subnet_nodepool_cidr
    protocol = "1"
    stateless = false
    icmp_options {
      type = 3
      code = 4
    }
  }

  freeform_tags = local.tags_comunes
}

resource "oci_core_security_list" "sl_nodes" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.red.vcn_id
  display_name   = "${local.prefijo}-sl-nodes"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
  }

  ingress_security_rules {
    source   = var.subnet_nodepool_cidr
    protocol = "all"
    stateless = false
  }

  ingress_security_rules {
    source   = var.subnet_api_cidr
    protocol = "all"
    stateless = false
  }

  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "1"
    stateless = false
    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    source   = var.subnet_lb_cidr
    protocol = "6"
    stateless = false
    tcp_options {
      min = 30000
      max = 32767
    }
  }

  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "6"
    stateless = false
    tcp_options {
      min = 22
      max = 22
    }
  }

  freeform_tags = local.tags_comunes
}

resource "oci_core_security_list" "sl_lb" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.red.vcn_id
  display_name   = "${local.prefijo}-sl-lb"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
  }

  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "6"
    stateless = false
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "6"
    stateless = false
    tcp_options {
      min = 443
      max = 443
    }
  }

  freeform_tags = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  3. ROUTE TABLES
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_core_route_table" "rt_nodes" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.red.vcn_id
  display_name   = "${local.prefijo}-rt-nodes"
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
#  4. SUBNETS
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_core_subnet" "api" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = module.red.vcn_id
  cidr_block                 = var.subnet_api_cidr
  display_name               = "${local.prefijo}-sub-api"
  dns_label                  = "api"
  prohibit_public_ip_on_vnic = false
  route_table_id             = module.red.route_table_publica_id
  security_list_ids          = [oci_core_security_list.sl_api.id]
  freeform_tags              = local.tags_comunes
}

resource "oci_core_subnet" "lb" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = module.red.vcn_id
  cidr_block                 = var.subnet_lb_cidr
  display_name               = "${local.prefijo}-sub-lb"
  dns_label                  = "lb"
  prohibit_public_ip_on_vnic = false
  route_table_id             = module.red.route_table_publica_id
  security_list_ids          = [oci_core_security_list.sl_lb.id]
  freeform_tags              = local.tags_comunes
}

resource "oci_core_subnet" "nodes" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = module.red.vcn_id
  cidr_block                 = var.subnet_nodepool_cidr
  display_name               = "${local.prefijo}-sub-nodes"
  dns_label                  = "nodes"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.rt_nodes.id
  security_list_ids          = [oci_core_security_list.sl_nodes.id]
  freeform_tags              = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  5. OKE CLUSTER
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_containerengine_cluster" "cluster" {
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.k8s_version
  name               = "${local.prefijo}-cluster"
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
#  6. NODE POOL
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_containerengine_node_pool" "pool" {
  compartment_id     = var.compartment_ocid
  cluster_id         = oci_containerengine_cluster.cluster.id
  kubernetes_version = var.k8s_version
  name               = "${local.prefijo}-nodepool"

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

    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      subnet_id           = oci_core_subnet.nodes.id
    }
  }

  ssh_public_key = var.ssh_public_key

  freeform_tags = local.tags_comunes
}
