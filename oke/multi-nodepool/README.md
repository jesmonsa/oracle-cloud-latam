# 🐳 OKE Multi Node Pool — Arquitectura de Referencia

[![Terraform 1.5+](https://img.shields.io/badge/terraform-%3E%3D%201.5-purple)](https://www.terraform.io) [![OCI Provider 6.0+](https://img.shields.io/badge/OCI%20Provider-%3E%3D%206.0-blue)](https://registry.terraform.io/providers/oracle/oci/latest) [![OKE](https://img.shields.io/badge/OKE-Managed%20Kubernetes-orange)](https://www.oracle.com/cloud/kubernetes-engine/) [![Flannel CNI](https://img.shields.io/badge/CNI-Flannel-yellowgreen)](https://github.com/coreos/flannel) [![Multi-Arch](https://img.shields.io/badge/Multi--Arch-x86%2BARM-red)](https://www.oracle.com/cloud/architecture-center/) [![License](https://img.shields.io/badge/license-UPL--1.0-green)](LICENSE)

## ☁️ Desplegar con un Clic

[![Desplegar en Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/oke-multi-nodepool.zip)

> Requiere una cuenta activa en Oracle Cloud Infrastructure. [Crear cuenta gratuita (300 USD de créditos)](https://www.oracle.com/cloud/free/)

---

## 📖 Descripción

Esta arquitectura de referencia despliega un **cluster OKE heterogéneo y altamente optimizado** con **2 node pools independientes**:

1. **Node Pool x86 (E4.Flex)**: Para cargas de trabajo estándar y aplicaciones heredadas
2. **Node Pool ARM64 (A1.Flex)**: Para workloads ARM-native, 80% más económico

**Beneficios clave:**
- ✅ **Costo-optimizado**: Ahorro de hasta 60-70% combinando x86 + ARM
- ✅ **Diversidad de cargas**: Ejecuta aplicaciones heterogéneas en un cluster unificado
- ✅ **Machine Learning**: ARM Ampere es ideal para inferencia de TensorFlow/PyTorch
- ✅ **Auto-scaling**: Cada pool escala independientemente según demanda
- ✅ **Multi-arquitectura**: Soporte nativo de imágenes ARM64 (Alpine, Ubuntu, Oracle Linux)

**Casos de uso ideales:**
- Clusters de producción con cargas mixtas
- Entornos de machine learning que necesitan inferencia barata
- Migraciones de aplicaciones x86 → ARM progresivas
- Evaluación de Ampere (ARM64) en producción real
- Reducción de TCO (Total Cost of Ownership) en cargas 24/7

**Complejidad:** Intermedia (scheduling, node selectors, tolerations)

---

## 🏗️ Diagrama de Arquitectura

```
┌──────────────────────────────────────────────────────────────────┐
│                          INTERNET                                │
└────────────────────────────┬─────────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │   IGW           │
                    │ Internet Gateway│
                    └────────┬────────┘
                             │
            ┌────────────────┼─────────────────┐
            │                │                 │
   ┌────────▼─────┐ ┌────────▼─────┐ ┌───────▼──────┐
   │ Subnet API   │ │ Subnet LB    │ │ Subnet NODES │
   │ (Pública)    │ │ (Pública)    │ │ (Privada)    │
   │ /28          │ │ /24          │ │ /24          │
   │              │ │              │ │              │
   │ OKE API      │ │ SVC LB       │ │ OKE Workers  │
   │ Endpoint     │ │ Ingress      │ │ (Pods)       │
   └──────────────┘ └──────────────┘ │              │
                                    │              │
                                    ├─ Node Pool 1:│
                                    │  E4.Flex x86 │
                                    │  (3 nodos)   │
                                    │              │
                                    ├─ Node Pool 2:│
                                    │  A1.Flex ARM │
                                    │  (3 nodos)   │
                                    └──────────────┘
                                            │
                                    ┌───────▼────────┐
                                    │ NAT Gateway    │
                                    │ Service GW     │
                                    └───────┬────────┘
                                            │
                                    (Egreso a OCI services)

         ┌─────────────────────────────────────────────────┐
         │      OKE CLUSTER (Kubernetes 1.28+)             │
         ├─────────────────────────────────────────────────┤
         │                                                 │
         │  ┌──────────────────┐  ┌────────────────────┐  │
         │  │ Node Pool x86    │  │ Node Pool ARM64    │  │
         │  │ (E4.Flex)        │  │ (A1.Flex)          │  │
         │  │                  │  │                    │  │
         │  │ Node-1 (2vCPU)   │  │ Node-1 (4vCPU)    │  │
         │  │ Node-2 (2vCPU)   │  │ Node-2 (4vCPU)    │  │
         │  │ Node-3 (2vCPU)   │  │ Node-3 (4vCPU)    │  │
         │  │                  │  │                    │  │
         │  │ Labels:          │  │ Labels:            │  │
         │  │ arch=amd64       │  │ arch=arm64         │  │
         │  │ shape=e4         │  │ shape=a1           │  │
         │  │                  │  │                    │  │
         │  │ Tolerations:     │  │ Tolerations:       │  │
         │  │ node-pool=x86    │  │ node-pool=arm      │  │
         │  └──────────────────┘  └────────────────────┘  │
         │                                                 │
         │  Pods pueden tener nodeSelector y tolerations  │
         │  para decidir en qué pool ejecutarse            │
         │                                                 │
         └─────────────────────────────────────────────────┘

        ┌─────────────────────────────────────────────────┐
        │        Replicación de Pods en Ambos Pools       │
        ├─────────────────────────────────────────────────┤
        │                                                 │
        │ Deployment "web" (nodeSelector: arch=amd64)    │
        │ ├─ Pod-1 → Node x86-1                          │
        │ ├─ Pod-2 → Node x86-2                          │
        │ └─ Pod-3 → Node x86-3                          │
        │                                                 │
        │ Deployment "inference" (nodeSelector: arch=arm)│
        │ ├─ Pod-1 → Node ARM-1                          │
        │ ├─ Pod-2 → Node ARM-2                          │
        │ └─ Pod-3 → Node ARM-3                          │
        │                                                 │
        │ Deployment "generic" (sin restrictions)        │
        │ ├─ Pod-1 → Node x86-1  (preferencia por x86)  │
        │ ├─ Pod-2 → Node x86-2                          │
        │ ├─ Pod-3 → Node ARM-1  (fallback a ARM)        │
        │ └─ Pod-4 → Node ARM-2                          │
        │                                                 │
        └─────────────────────────────────────────────────┘
```

---

## 📦 Componentes Desplegados

| Recurso | Servicio OCI | Descripción | Notas |
|---|---|---|---|
| **VCN** | `oci_core_vcn` | Virtual Cloud Network (10.0.0.0/16) | Mismo que cluster-basico |
| **Internet Gateway** | `oci_core_internet_gateway` | Acceso bidireccional | Solo API y LB públicos |
| **NAT Gateway** | `oci_core_nat_gateway` | Egreso sin IP pública | x86 + ARM usan el mismo |
| **Service Gateway** | `oci_core_service_gateway` | Acceso privado OCI services | Object Storage, OCDB |
| **Subnet API** | `oci_core_subnet` | Pública /28 | 4 IPs para API endpoint |
| **Subnet LB** | `oci_core_subnet` | Pública /24 | Load Balancer services |
| **Subnet Nodes** | `oci_core_subnet` | Privada /24 | Ambos pools comparten |
| **NSG API** | `oci_core_network_security_group` | Puerto 6443 HTTPS | API endpoint rules |
| **NSG Nodes** | `oci_core_network_security_group` | Kubelet, vxlan, peers | Ambos pools |
| **NSG LB** | `oci_core_network_security_group` | 80, 443 | Ingress/LB services |
| **OKE Cluster** | `oci_containerengine_cluster` | Control plane Kubernetes | Fully managed |
| **Node Pool x86** | `oci_containerengine_node_pool` | E4.Flex workers (3) | Imágenes amd64 |
| **Node Pool ARM** | `oci_containerengine_node_pool` | A1.Flex workers (3) | Imágenes arm64 |
| **Instance Config x86** | `oci_core_instance_configuration` | Template E4.Flex config | Metadata, SSH key |
| **Instance Config ARM** | `oci_core_instance_configuration` | Template A1.Flex config | Metadata, SSH key |

---

## ⚙️ Variables de Configuración

### Configuración General

| Variable | Descripción | Valor Defecto | Requerida | Tipo |
|---|---|---|---|---|
| `compartment_ocid` | OCID del compartment de despliegue | | ✅ | string |
| `region` | Región OCI (ej: sp-saopaulo-1) | `us-ashburn-1` | ✅ | string |
| `availability_domain` | AD para despliegue | `AD-1` | | string |
| `proyecto` | Prefijo para nombres de recursos | `mio` | ✅ | string |
| `ambiente` | Env tag (desarrollo, staging, produccion) | `desarrollo` | | string |

### Configuración VCN (Networking)

| Variable | Descripción | Valor Defecto | Tipo |
|---|---|---|---|
| `vcn_cidr` | CIDR block VCN | `10.0.0.0/16` | string |
| `subnet_api_cidr` | CIDR subnet API endpoint | `10.0.1.0/28` | string |
| `subnet_lb_cidr` | CIDR subnet Load Balancer | `10.0.2.0/24` | string |
| `subnet_nodes_cidr` | CIDR subnet worker nodes | `10.0.3.0/24` | string |

### Configuración OKE Cluster

| Variable | Descripción | Valor Defecto | Tipo |
|---|---|---|---|
| `oke_kubernetes_version` | Versión de Kubernetes | `v1.28.2` | string |
| `oke_cluster_name` | Nombre del cluster | `${proyecto}-oke-${ambiente}` | string |
| `kubernetes_api_endpoint_public` | API endpoint público | `true` | bool |
| `oke_cni_type` | CNI a usar (FLANNEL) | `FLANNEL` | string |
| `cluster_kms_key_id` | KMS key para encryption (optional) | | string |

### Node Pool x86 (E4.Flex)

| Variable | Descripción | Valor Defecto | Tipo |
|---|---|---|---|
| `np_x86_name` | Nombre del pool | `${proyecto}-nodepool-x86` | string |
| `np_x86_initial_node_count` | Cantidad inicial de nodos | `3` | number |
| `np_x86_shape` | Flex shape | `VM.Standard.E4.Flex` | string |
| `np_x86_ocpus` | vCPU por nodo | `2` | number |
| `np_x86_memory_gb` | Memoria RAM por nodo | `16` | number |
| `np_x86_max_node_count` | Máximo para auto-scaling | `10` | number |
| `np_x86_min_node_count` | Mínimo para auto-scaling | `3` | number |
| `np_x86_image_id` | Image OCID (auto-detected) | | string |
| `np_x86_ssh_public_key` | Public SSH key para acceso | | string |
| `np_x86_labels` | Labels custom (arch=amd64) | `{arch="amd64"}` | map(string) |
| `np_x86_taints` | Taints (opcional) | | list |

### Node Pool ARM64 (A1.Flex)

| Variable | Descripción | Valor Defecto | Tipo |
|---|---|---|---|
| `np_arm_name` | Nombre del pool | `${proyecto}-nodepool-arm` | string |
| `np_arm_initial_node_count` | Cantidad inicial de nodos | `3` | number |
| `np_arm_shape` | Flex shape ARM | `VM.Standard.A1.Flex` | string |
| `np_arm_ocpus` | vCPU por nodo | `4` | number |
| `np_arm_memory_gb` | Memoria RAM por nodo | `16` | number |
| `np_arm_max_node_count` | Máximo para auto-scaling | `10` | number |
| `np_arm_min_node_count` | Mínimo para auto-scaling | `3` | number |
| `np_arm_image_id` | Image OCID ARM64 (auto-detected) | | string |
| `np_arm_ssh_public_key` | Public SSH key | | string |
| `np_arm_labels` | Labels custom (arch=arm64) | `{arch="arm64"}` | map(string) |
| `np_arm_taints` | Taints (opcional) | | list |

### Etiquetas Globales

| Variable | Descripción | Valor Defecto | Tipo |
|---|---|---|---|
| `tags_common` | Etiquetas aplicadas a todos los recursos | | map(string) |

---

## 📤 Outputs

| Output | Descripción | Ejemplo |
|---|---|---|
| `cluster_id` | OCID del cluster OKE | `ocid1.cluster.oc1.sp...` |
| `cluster_name` | Nombre del cluster | `mio-oke-desarrollo` |
| `kubernetes_api_endpoint` | URL de acceso al API | `https://10.0.1.x:6443` |
| `nodepool_x86_id` | OCID del pool x86 | `ocid1.nodepool.oc1.sp...` |
| `nodepool_arm_id` | OCID del pool ARM | `ocid1.nodepool.oc1.sp...` |
| `kubeconfig` | Archivo kubeconfig YAML | `(contenido completo)` |
| `vcn_id` | OCID de la VCN | `ocid1.vcn.oc1.sp...` |
| `nodes_x86_public_ips` | IPs públicas x86 (si existieran) | `[]` (privadas por defecto) |
| `nodes_arm_public_ips` | IPs públicas ARM (si existieran) | `[]` (privadas por defecto) |

---

## 💰 Costo Estimado

### Precios en Región São Paulo (sp-saopaulo-1)

**Configuración por defecto (3x E4 + 3x A1 Flex)**

| Componente | Cantidad | Precio Unitario | Subtotal Mensual |
|---|---|---|---|
| **OKE Control Plane** | 1 cluster | **GRATIS** | **$0.00** |
| **Pool x86 (E4.Flex 2vCPU/16GB)** | 3 | $0.081/hr | $59.40 |
| **Pool ARM (A1.Flex 4vCPU/16GB)** | 3 | $0.013/hr | $9.43 |
| **Data Transfer (Egreso)** | ~150 GB/mes | $0.04/GB | $6.00 |
| **NAT Gateway** | 1 | $0.045/hr | $32.76 |
| **VCN, Subnets, NSGs** | 1 | Gratis | $0.00 |
| **Service Gateway** | 1 | Gratis | $0.00 |
| | | **TOTAL MENSUAL** | **~$107.59** |

### Optimización: 100% ARM64

Si migras todas las cargas a ARM:

| Componente | Cantidad | Precio Unitario | Subtotal Mensual |
|---|---|---|---|
| **OKE Control Plane** | 1 cluster | **GRATIS** | **$0.00** |
| **Pool ARM (A1.Flex 4vCPU/16GB)** | 6 | $0.013/hr | $18.86 |
| **NAT Gateway** | 1 | $0.045/hr | $32.76 |
| **Otros (networking)** | | | $6.00 |
| | | **TOTAL MENSUAL** | **~$57.62** |

**Ahorro vs 100% x86: 40-50%**

---

## 🚀 Despliegue

### Opción 1: Oracle Resource Manager (Un clic, Recomendado)

1. Haz clic en el botón **Deploy** arriba
2. Inicia sesión en Oracle Cloud Console
3. **Revisa variables** (especialmente formas de OS para x86 vs ARM)
4. **Configura**: Adjust node counts, shapes, memory si es necesario
5. **Create** → **Apply** → **Confirm**
6. Espera 10-18 minutos hasta "Job succeeded"

**Post-Deploy:**
```bash
# Descargar kubeconfig desde outputs de la pila
mkdir -p ~/.kube
echo '<KUBECONFIG_OUTPUT>' > ~/.kube/config
chmod 600 ~/.kube/config

# Verificar que tienes 2 node pools
kubectl get nodes --show-labels
kubectl describe nodes | grep -i "arch"
```

---

### Opción 2: Terraform CLI

```bash
# 1. Clonar
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/oke/multi-nodepool

# 2. Preparar variables
cp terraform.tfvars.example terraform.tfvars
# Edita con tu compartment_ocid, region, shapes, etc.

# 3. Inicializar
terraform init

# 4. Revisar plan
terraform plan -out=tfplan

# 5. Desplegar
terraform apply tfplan
# Espera 10-18 minutos

# 6. Obtener kubeconfig
terraform output -raw kubeconfig > ~/.kube/config
chmod 600 ~/.kube/config

# 7. Verificar conexión
kubectl get nodes -L arch,kubernetes.io/arch
```

---

## 🔧 Scheduling en Clusters Heterogéneos

Esta es la **clave de una arquitectura multi-nodepool**: decirle a Kubernetes dónde ejecutar qué.

### Opción 1: nodeSelector (Simple)

```yaml
# Deploy SOLO en nodes x86
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webserver
spec:
  replicas: 3
  template:
    spec:
      nodeSelector:
        arch: amd64  # Label del pool x86
      containers:
      - name: app
        image: nginx:latest  # x86 image
---
# Deploy SOLO en nodes ARM
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ml-inference
spec:
  replicas: 3
  template:
    spec:
      nodeSelector:
        arch: arm64  # Label del pool ARM
      containers:
      - name: model
        image: myregistry/tensorflow-arm64:latest  # ARM image
```

### Opción 2: Tolerations + Affinidad (Avanzado)

```yaml
# Deploy que prefiere x86, pero tolera ARM si no hay espacio
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flexible-app
spec:
  replicas: 5
  template:
    spec:
      # Preferencia por x86 (soft requirement)
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            preference:
              matchExpressions:
              - key: arch
                operator: In
                values: ["amd64"]
      # Tolerar ambos pools
      tolerations:
      - key: "node-pool"
        operator: "Equal"
        value: "x86"
        effect: "NoSchedule"
      - key: "node-pool"
        operator: "Equal"
        value: "arm"
        effect: "NoSchedule"
      containers:
      - name: app
        image: myregistry/app:latest-multiarch  # Multi-arch image
```

### Opción 3: Pod Disruption Budgets (Producción)

```yaml
# Garantizar que siempre hay réplicas disponibles durante mantenimiento
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: app-pdb
spec:
  minAvailable: 2  # Mínimo 2 pods siempre disponibles
  selector:
    matchLabels:
      app: my-app
```

### Ejemplo Práctico Completo

```bash
# 1. Deploy en x86 solamente
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: x86-app
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: x86-app
  template:
    metadata:
      labels:
        app: x86-app
        arch: amd64
    spec:
      nodeSelector:
        arch: amd64
      containers:
      - name: app
        image: ubuntu:22.04
        command: ["sh", "-c"]
        args: ["echo 'Running on x86' && sleep 3600"]
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - x86-app
              topologyKey: kubernetes.io/hostname
EOF

# 2. Deploy en ARM solamente
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: arm-app
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: arm-app
  template:
    metadata:
      labels:
        app: arm-app
        arch: arm64
    spec:
      nodeSelector:
        arch: arm64
      containers:
      - name: app
        image: arm64v8/ubuntu:22.04
        command: ["sh", "-c"]
        args: ["echo 'Running on ARM64' && sleep 3600"]
EOF

# 3. Verificar distribución
kubectl get pods -o wide
kubectl describe nodes | grep -A5 "Labels:"
```

### Debugging de Scheduling

```bash
# Ver qué pool tiene cada nodo
kubectl get nodes -L arch,kubernetes.io/arch,node.kubernetes.io/instance-type

# Ver eventos de scheduling fallido
kubectl describe pod <pod-name>

# Ver logs del scheduler (si es necesario)
kubectl logs -n kube-system -l component=scheduler --tail=50

# Listar labels de un node
kubectl get node <node-name> --show-labels
```

---

## 📊 Monitoreo Multi-Pool

### Métricas por Pool

```bash
# CPU/Memoria por architecture
kubectl top nodes -L arch

# Pods corriendo en x86
kubectl get pods -A -o wide --field-selector spec.nodeSelector.arch=amd64

# Pods corriendo en ARM
kubectl get pods -A -o wide --field-selector spec.nodeSelector.arch=arm64

# Capacidad total
kubectl describe nodes | grep -E "Name:|Allocatable:" | paste - -
```

### Alertas Recomendadas (Prometheus)

```yaml
# Alert si un pool está al 80% de CPU
- alert: NodePoolHighCPU
  expr: |
    (sum(rate(container_cpu_usage_seconds_total[5m])) by (instance) / 
     on(instance) sum(kube_node_labels{label_arch="amd64"}) by (instance)) > 0.8
  for: 5m
  annotations:
    summary: "Node pool x86 CPU > 80%"
    
# Alert si ARM pool está vacío (puede ahorrar dinero)
- alert: ARMPoolUnderutilized
  expr: |
    count(kubelet_running_pods{arch="arm64"}) == 0
  for: 30m
  annotations:
    summary: "ARM pool has no pods for 30m - consider reducing nodes"
```

---

## 🔐 Consideraciones de Seguridad

Multi-pool introduce consideraciones adicionales:

- ✅ **Imágenes multi-arquitectura**: Usa manifests de Docker para soportar x86 + ARM
  ```bash
  docker buildx build --platform linux/amd64,linux/arm64 -t myapp:latest .
  ```

- ✅ **CNI aislamiento**: Flannel permite comunicación entre pools de forma segura

- ✅ **Network Policies**: Aplicables a ambos pools
  ```yaml
  apiVersion: networking.k8s.io/v1
  kind: NetworkPolicy
  metadata:
    name: pool-isolation
  spec:
    podSelector: {}
    policyTypes:
    - Ingress
    - Egress
    ingress:
    - from:
      - namespaceSelector:
          matchLabels:
            name: allowed-ns
  ```

- ✅ **RBAC por pool**: Restringe acceso de nodos según necesidad
  ```yaml
  apiVersion: rbac.authorization.k8s.io/v1
  kind: Role
  metadata:
    name: x86-only
  rules:
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["get", "list"]
  ```

---

## 🧹 Limpieza y Destrucción

### Con Terraform

```bash
# Revisar qué se va a destruir
terraform plan -destroy

# Destruir ambos pools simultáneamente
terraform destroy
# Confirma "yes"

# Tiempo estimado: 5-8 minutos
```

### Con Oracle Resource Manager

1. OCI Console → Resource Manager → Stacks
2. Selecciona tu stack
3. **Destroy** → Confirm

**Nota:** Se eliminarán ambos node pools, cluster, VCN y todos los recursos creados. Los datos en Object Storage persisten.

---

## 🔗 Arquitecturas Relacionadas

Una vez domines multi-nodepool, considera:

| Arquitectura | Descripción | Próxima? |
|---|---|---|
| **[cluster-basico](../cluster-basico/)** | Single pool (introducción) | Base |
| **ingress-nginx** | Ingress Controller optimizado | Próxima |
| **oke-ocir-registry** | Private registry para imágenes multi-arch | Próxima |
| **observabilidad-oke** | Prometheus + Grafana por pool | Próxima |
| **cluster-autoscaler** | Escalado automático inteligente | Próxima |

---

## ❓ Preguntas Frecuentes (FAQ)

**P: ¿Puedo cambiar imágenes de x86 a ARM después?**
R: No. ARM y x86 tienen arquitecturas incompatibles. Las imágenes deben ser compiladas para la arquitectura destino. Usa imágenes multi-arch (manifest lists) para soportar ambas.

**P: ¿Cómo sé si una imagen es ARM-compatible?**
R: Verifica en Docker Hub o tu registry. Las imágenes ARM generalmente se etiquetan con `-arm64` o `arm64v8/...`.

**P: ¿Puedo tener >2 pools?**
R: Sí, pero no está incluido en esta arquitectura. Terraform permite N pools con `for_each` o `count`.

**P: ¿Cuál es la diferencia de rendimiento x86 vs ARM?**
R: ARM (Ampere) es ~85% del rendimiento x86 a costo 80% menor. Ideal para workloads no CPU-bound (web, APIs, ML inference).

**P: ¿Puedo migrar workloads entre pools sin downtime?**
R: Sí, usando PodDisruptionBudgets y anti-affinidad. Los pods se "drenan" gradualmente del pool viejo al nuevo.

**P: ¿Cómo escalo un pool específico?**
R: Con Terraform: `np_x86_initial_node_count = 5`. O en OCI Console → Node Pool → Edit Quantity.

**P: ¿Qué pasa si un pool se queda sin espacio?**
R: Los pods entran en estado "Pending". El cluster-autoscaler (otra arquitectura) puede escalarlo automáticamente.

---

## 📚 Recursos Adicionales

### Documentación Oficial
- [Oracle Kubernetes Engine - Multi Pool](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengusingmultiplenodepools.htm)
- [ARM on OCI Kubernetes](https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes_summary.htm#ampere)
- [Kubernetes Scheduling and Eviction](https://kubernetes.io/docs/concepts/scheduling-eviction/)

### Guías de Imagen Multi-Arquitectura
- [Docker buildx Multi-Architecture](https://docs.docker.com/build/building/multi-platform/)
- [Building ARM64 Container Images](https://github.com/aws-containers/amazon-container-examples)
- [Ubuntu Multi-Arch Images](https://hub.docker.com/_/ubuntu)

### Herramientas para Multi-Arch
- [Podman Buildah](https://buildah.io/) - Build sin Docker daemon
- [Skopeo](https://github.com/containers/skopeo) - Image inspection/copy
- [Docker Scout](https://docs.docker.com/scout/) - Vulnerability scanning multi-arch

### Comunidad
- [Oracle OKE Slack - Multi-Arch](https://oracledevrel.slack.com/)
- [CNCF Kubernetes Community](https://kubernetes.io/community/)

---

## 📄 Licencia y Atribuciones

Esta arquitectura está bajo licencia **UPL-1.0** (Universal Permissive License).

Basado en FoggyKitchen. Adaptado, mejorado y optimizado para ARM en mercados latinoamericanos por **Jesús Monsa**, Oracle Cloud Architect.

---

**Última actualización:** Abril 2026 | **Versión:** 1.0.0 | **Estado:** Production Ready
