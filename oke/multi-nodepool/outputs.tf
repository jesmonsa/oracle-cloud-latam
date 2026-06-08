# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Outputs — OKE Multi Node Pool                                               ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ============================================================================
# CLUSTER OUTPUTS
# ============================================================================

output "cluster_id" {
  description = "OCID del cluster de Kubernetes"
  value       = oci_containerengine_cluster.oke.id
}

output "cluster_name" {
  description = "Nombre del cluster de Kubernetes"
  value       = oci_containerengine_cluster.oke.name
}

output "kubernetes_version" {
  description = "Versión de Kubernetes"
  value       = oci_containerengine_cluster.oke.kubernetes_version
}

output "cluster_endpoints" {
  description = "Endpoints del cluster Kubernetes"
  value = {
    kubernetes_api = oci_containerengine_cluster.oke.endpoints[0].kubernetes
    public_endpoint = try(
      oci_containerengine_cluster.oke.endpoints[0].public_endpoint,
      null
    )
  }
}

# ============================================================================
# NODE POOL x86 OUTPUTS
# ============================================================================

output "node_pool_x86_id" {
  description = "OCID del node pool x86 (E4 Flex)"
  value       = oci_containerengine_node_pool.np_x86.id
}

output "node_pool_x86_name" {
  description = "Nombre del node pool x86"
  value       = oci_containerengine_node_pool.np_x86.name
}

output "node_pool_x86_info" {
  description = "Información del node pool x86"
  value = {
    shape          = var.np_x86_shape
    ocpus          = var.np_x86_ocpus
    memory_gb      = var.np_x86_memoria_gb
    nodes          = var.np_x86_size
    kubernetes_ver = oci_containerengine_node_pool.np_x86.kubernetes_version
    architecture   = "x86_64"
    os             = "Ubuntu 22.04 LTS"
  }
}

# ============================================================================
# NODE POOL ARM OUTPUTS
# ============================================================================

output "node_pool_arm_id" {
  description = "OCID del node pool ARM (A1 Flex)"
  value       = oci_containerengine_node_pool.np_arm.id
}

output "node_pool_arm_name" {
  description = "Nombre del node pool ARM"
  value       = oci_containerengine_node_pool.np_arm.name
}

output "node_pool_arm_info" {
  description = "Información del node pool ARM"
  value = {
    shape          = var.np_arm_shape
    ocpus          = var.np_arm_ocpus
    memory_gb      = var.np_arm_memoria_gb
    nodes          = var.np_arm_size
    kubernetes_ver = oci_containerengine_node_pool.np_arm.kubernetes_version
    architecture   = "aarch64"
    os             = "Ubuntu 22.04 LTS"
  }
}

# ============================================================================
# NETWORK OUTPUTS
# ============================================================================

output "vcn_id" {
  description = "OCID de la Virtual Cloud Network"
  value       = module.vcn.vcn_id
}

output "subnet_api_id" {
  description = "OCID de la subred API"
  value       = oci_core_subnet.api.id
}

output "subnet_lb_id" {
  description = "OCID de la subred Load Balancer"
  value       = oci_core_subnet.lb.id
}

output "subnet_nodepool_id" {
  description = "OCID de la subred Node Pool"
  value       = oci_core_subnet.nodepool.id
}

output "network_config" {
  description = "Configuración de red del cluster"
  value = {
    vcn_cidr             = var.vcn_cidr
    pods_cidr            = var.pods_cidr
    services_cidr        = var.services_cidr
    cni_type             = "FLANNEL_OVERLAY"
    subnet_api_cidr      = var.subnet_api_cidr
    subnet_lb_cidr       = var.subnet_lb_cidr
    subnet_nodepool_cidr = var.subnet_nodepool_cidr
  }
}

# ============================================================================
# KUBECONFIG COMMAND
# ============================================================================

output "kubeconfig_cmd" {
  description = "Comando para obtener el kubeconfig del cluster"
  value = join(" ", [
    "oci ce cluster create-kubeconfig",
    "--cluster-id ${oci_containerengine_cluster.oke.id}",
    "--file $HOME/.kube/${oci_containerengine_cluster.oke.name}-config",
    "--region ${var.region}"
  ])
}

output "kubectl_config_command" {
  description = "Comando alternativo para configurar kubectl"
  value = "kubectl config use-context ${oci_containerengine_cluster.oke.name}"
}

# ============================================================================
# RESUMEN DE DESPLIEGUE
# ============================================================================

output "resumen_despliegue" {
  description = "Resumen de la arquitectura desplegada"
  value = <<-EOT
╔════════════════════════════════════════════════════════════════════╗
║         OKE Multi Node Pool — Arquitectura de Referencia          ║
╚════════════════════════════════════════════════════════════════════╝

┌─ CLUSTER KUBERNETES ───────────────────────────────────────────┐
│ Nombre:           ${oci_containerengine_cluster.oke.name}
│ Versión K8s:      ${oci_containerengine_cluster.oke.kubernetes_version}
│ CNI:              FLANNEL_OVERLAY
│ Pod CIDR:         ${var.pods_cidr}
│ Service CIDR:     ${var.services_cidr}
└────────────────────────────────────────────────────────────────┘

┌─ NODE POOL x86 (E4 Flex) ──────────────────────────────────────┐
│ Nombre:           ${oci_containerengine_node_pool.np_x86.name}
│ Shape:            ${var.np_x86_shape}
│ OCPUs:            ${var.np_x86_ocpus}
│ Memoria:          ${var.np_x86_memoria_gb} GB
│ Nodos:            ${var.np_x86_size}
│ Arquitectura:     x86_64
│ Sistema:          Ubuntu 22.04 LTS
└────────────────────────────────────────────────────────────────┘

┌─ NODE POOL ARM (A1 Flex) ──────────────────────────────────────┐
│ Nombre:           ${oci_containerengine_node_pool.np_arm.name}
│ Shape:            ${var.np_arm_shape}
│ OCPUs:            ${var.np_arm_ocpus}
│ Memoria:          ${var.np_arm_memoria_gb} GB
│ Nodos:            ${var.np_arm_size}
│ Arquitectura:     aarch64 (ARM64)
│ Sistema:          Ubuntu 22.04 LTS
└────────────────────────────────────────────────────────────────┘

┌─ INFRAESTRUCTURA DE RED ───────────────────────────────────────┐
│ VCN CIDR:         ${var.vcn_cidr}
│ Subred API:       ${var.subnet_api_cidr}
│ Subred LB:        ${var.subnet_lb_cidr}
│ Subred NodePool:  ${var.subnet_nodepool_cidr}
│ NAT Gateway:      Habilitado
│ Service Gateway:  Habilitado
└────────────────────────────────────────────────────────────────┘

┌─ PASOS SIGUIENTES ────────────────────────────────────────────┐
│ 1. Obtener kubeconfig:
│    ${join(" ", [
    "oci ce cluster create-kubeconfig",
    "--cluster-id ${oci_containerengine_cluster.oke.id}",
    "--file kubeconfig.yaml"
  ])}
│
│ 2. Verificar nodos del cluster:
│    export KUBECONFIG=kubeconfig.yaml
│    kubectl get nodes -o wide
│
│ 3. Verificar node pools:
│    kubectl get nodes -L kubernetes.io/arch
│
│ 4. Desplegar aplicaciones con afinidad:
│    # Para x86_64:  nodeSelector: kubernetes.io/arch: amd64
│    # Para ARM64:   nodeSelector: kubernetes.io/arch: arm64
└────────────────────────────────────────────────────────────────┘
EOT
}

# ============================================================================
# ETIQUETAS APLICADAS
# ============================================================================

output "tags_aplicados" {
  description = "Tags empresariales aplicados a todos los recursos"
  value = {
    Arquitectura = "oke-multi-nodepool"
    Proyecto     = var.proyecto
    Ambiente     = var.ambiente
    Propietario  = var.propietario
    ManagedBy    = "Terraform"
  }
}
