# OKE Virtual Nodes - Arquitectura de Referencia (Serverless)

## Descripción General

Esta arquitectura implementa **Oracle Kubernetes Engine (OKE) con Virtual Nodes**, una solución **serverless** que permite ejecutar pods de Kubernetes sin gestionar infraestructura subyacente. Los Virtual Nodes abstraen completamente la administración de máquinas virtuales, permitiendo que se enfoque únicamente en las aplicaciones containerizadas.

### Características Principales

- **Ejecución Serverless**: Pods sin gestión de nodos
- **Pago por Consumo**: Solo se paga por tiempo de ejecución de pods
- **Escalado Instantáneo**: Los pods se inician sin delay
- **Container Instances Backend**: OCI gestiona la ejecución subyacente
- **Aislamiento de Seguridad**: Cada pod en su propia Container Instance
- **Cluster OKE ENHANCED**: Soporte para funcionalidades avanzadas
- **VCN Dedicada**: Red virtual con configuración optimizada

## Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                    Oracle Cloud Region                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────────────────────────────────────────┐ │
│  │              VCN (10.0.0.0/16)                      │ │
│  │                                                     │ │
│  │  ┌─────────────────────────────────────────────┐   │ │
│  │  │   Public Subnet (10.0.1.0/24)              │   │ │
│  │  │                                             │   │ │
│  │  │   ┌─────────────────────────────────────┐   │   │ │
│  │  │   │  OKE ENHANCED Cluster               │   │   │ │
│  │  │   │                                     │   │   │ │
│  │  │   │  ┌──────────────────────────────┐   │   │   │ │
│  │  │   │  │ Master Nodes (OCI-Managed)  │   │   │   │ │
│  │  │   │  └──────────────────────────────┘   │   │   │ │
│  │  │   │                                     │   │   │ │
│  │  │   │  ┌──────────────────────────────┐   │   │   │ │
│  │  │   │  │ VIRTUAL NODE POOL (sin nodos│   │   │   │ │
│  │  │   │  │ infraestructura)            │   │   │   │ │
│  │  │   │  │ + Namespace: virtual-      │   │   │   │ │
│  │  │   │  │   workloads                │   │   │   │ │
│  │  │   │  │ + Taint: virtual-node=true │   │   │   │ │
│  │  │   │  │ + Pod Shape: E4.Flex        │   │   │   │ │
│  │  │   │  └──────────────────────────────┘   │   │   │ │
│  │  │   └─────────────────────────────────────┘   │   │ │
│  │  │                                             │   │ │
│  │  │  Addons:                                    │   │ │
│  │  │  - CoreDNS                                  │   │ │
│  │  │  - kube-proxy                               │   │ │
│  │  │  - VCN-Native Pod Networking                │   │ │
│  │  │  - Virtual Node Provider                    │   │ │
│  │  └─────────────────────────────────────────────┘   │ │
│  │                                                     │ │
│  │  ┌─────────────────────────────────────────────┐   │ │
│  │  │   Internet Gateway                          │   │ │
│  │  │   NAT Gateway (para tráfico de salida)      │   │ │
│  │  │   Route Tables                              │   │ │
│  │  └─────────────────────────────────────────────┘   │ │
│  └──────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│      Container Instances Backend (OCI-Managed)              │
│                                                             │
│  Cuando se despliegan pods en Virtual Nodes:               │
│  - Cada pod se ejecuta en su propia Container Instance     │
│  - Aislamiento completo a nivel de recurso                │
│  - OCI gestiona el ciclo de vida automáticamente           │
│  - Pago granular por minuto de ejecución                  │
│                                                             │
│  Pod 1     Pod 2     Pod 3     Pod 4                      │
│  ┌──┐     ┌──┐     ┌──┐     ┌──┐                         │
│  │CI│     │CI│     │CI│     │CI│  (Container Instances)  │
│  └──┘     └──┘     └──┘     └──┘                         │
│   1 OCPU  1 OCPU   1 OCPU   1 OCPU                       │
│   4 GB    4 GB     4 GB     4 GB                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│           Kubernetes Namespace Configuration               │
│                                                             │
│  system Namespace:  kube-system                            │
│  ├─ Servicios del cluster                                 │
│  └─ Componentes de OKE                                    │
│                                                             │
│  Workload Namespace:  virtual-workloads                   │
│  ├─ Taint: virtual-node=true:NoSchedule                   │
│  ├─ Pods requieren tolerancia a este taint                │
│  ├─ NodeAffinity: Afinidad a Virtual Nodes                │
│  └─ Política de Evicción automática                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Componentes Técnicos

### 1. Virtual Cloud Network (VCN)
- **CIDR Block**: `10.0.0.0/16`
- **Subnet Pública**: `10.0.1.0/24`
- **Internet Gateway**: Acceso público
- **NAT Gateway**: Tráfico de salida anónimo
- **Route Tables**: Optimizadas para Virtual Nodes

### 2. OKE Cluster (ENHANCED)
- **Tipo**: ENHANCED (requerido para Virtual Nodes)
- **Versión**: Kubernetes v1.29
- **Master Nodes**: Gestionados completamente por Oracle
- **Mode de Red**: VCN-Native (más eficiente)
- **Addons**: CoreDNS, kube-proxy, Virtual Node Provider

### 3. Virtual Node Pool
- **Sin Nodos Físicos**: Abstracción completa
- **Pod Shape**: `Pod.Standard.E4.Flex`
- **OCPUs por Pod**: 1 (ajustable desde 0.1 a 64)
- **Memoria por Pod**: 4 GB (ajustable)
- **Límite de Pods**: 10 simultáneos (configurable)
- **Escalado**: Automático basado en demanda

### 4. Container Instances Backend
- **Gerenciado por OCI**: Invisible para usuario
- **Aislamiento por Pod**: Cada pod en su propia instancia
- **Billing Granular**: Minuto de ejecución
- **Logging**: Integración con OCI Logging
- **Networking**: Conecta automáticamente a VCN

### 5. Kubernetes Namespace
- **Namespace Predefinido**: `virtual-workloads`
- **Taints**: `virtual-node=true:NoSchedule`
- **Tolerancias**: Aplicadas automáticamente
- **Políticas de Evicción**: Automáticas con gracia configurable
- **ResourceQuotas**: Límites por namespace

## Ventajas de Virtual Nodes

### 1. Costo
- Pago por uso (minuto de ejecución)
- No hay costo de nodos ociosos
- Escalado a cero cuando no hay pods
- Ideal para workloads bursty o intermitentes

### 2. Operacional
- Sin parches de SO
- Sin gestión de capacidad
- Sin configuración de Security Groups
- Reintentos y recuperación automática

### 3. Seguridad
- Aislamiento por Container Instance
- Encriptación nativa de datos
- Control de acceso IAM integrado
- Auditoría automática de todas las acciones

### 4. Rendimiento
- Startup instantáneo de pods
- Sin overhead de hypervisor compartido
- Recursos dedicados por pod
- Latencia predecible

## Requisitos Previos

### Infraestructura
- Cuenta OCI activa con límites de Container Instances
- Región que soporta Virtual Nodes (ej: sa-santiago-1)
- Cuota disponible de recursos

### Software
- Terraform >= 1.5.0
- OCI CLI >= 3.0.0
- kubectl >= 1.28
- Docker (opcional, para construir imágenes)

### Credenciales
- API Key de usuario IAM con permisos:
  - `container/*` (OKE)
  - `containerinstances/*` (Container Instances)
  - `networking/*` (VCN)
  - `instance/*` (nodos)

### Información Necesaria
- OCID del Tenancy
- OCID del usuario IAM
- Fingerprint de API Key
- Ruta a archivo de clave privada PEM
- OCID del compartment para Container Instances

## Instalación y Despliegue

### 1. Preparación del Entorno

```bash
# Clonar repositorio
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/Arquitectura-base/oke/virtual-nodes

# Inicializar Terraform
terraform init

# Validar
terraform validate
```

### 2. Configurar Variables

```bash
# Copiar archivo de ejemplo
cp terraform.tfvars.example terraform.tfvars

# Editar con valores reales
nano terraform.tfvars

# Variables críticas:
# - tenancy_ocid: De OCI Console > My Profile > Tenancy
# - current_user_ocid: De OCI Console > My Profile > User
# - fingerprint: De OCI Console > My Profile > API Keys
# - private_key_path: Ruta a archivo PEM (~/.oci/oci_api_key.pem)
# - container_instances_compartment_id: OCID del compartment
```

### 3. Plan y Validación

```bash
# Generar plan
terraform plan -out=tfplan

# Revisar cambios
terraform show tfplan
```

### 4. Aplicar Configuración

```bash
# Desplegar
terraform apply tfplan

# Esperar 15-20 minutos
# Monitor: OCI Console > Containers > Kubernetes Clusters
```

### 5. Configurar kubectl

```bash
# Obtener kubeconfig
oci ce cluster create-kubeconfig \
  --cluster-id <CLUSTER_ID> \
  --file $HOME/.kube/config-oke-vn \
  --region sa-santiago-1

# Usar el config
export KUBECONFIG=$HOME/.kube/config-oke-vn

# Verificar
kubectl get nodes
kubectl get namespaces
```

### 6. Verificar Virtual Nodes

```bash
# Ver nodos virtuales
kubectl get nodes

# Información detallada
kubectl describe nodes

# Ver la taint de Virtual Nodes
kubectl describe node <NODE_NAME>

# Verificar namespace
kubectl get namespace virtual-workloads
```

### 7. Desplegar Aplicación de Prueba

```bash
# Crear un deployment de prueba
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-virtual
  namespace: virtual-workloads
spec:
  replicas: 3
  selector:
    matchLabels:
      app: test-virtual
  template:
    metadata:
      labels:
        app: test-virtual
    spec:
      tolerations:
      - key: virtual-node
        operator: Equal
        value: "true"
        effect: NoSchedule
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
EOF

# Verificar pods
kubectl get pods -n virtual-workloads
kubectl logs -n virtual-workloads deployment/test-virtual
```

## Variables Configurables

### Virtual Node Pool
- `virtual_node_pool_name`: Nombre identificativo
- `virtual_node_count`: Cantidad de pods permitidos (1-1000)
- `pod_shape`: Tipo de pod (E4.Flex o E3.Flex)
- `pod_ocpus`: Recursos CPU (0.1-64)
- `pod_memory_gb`: Memoria (0.5-1024 GB)
- `pod_eviction_grace_duration_seconds`: Tiempo de gracia en evicción

### Cluster
- `cluster_name`: Nombre del cluster
- `kubernetes_version`: Versión de K8s
- `cluster_type`: Tipo (debe ser ENHANCED)

### VCN
- `vcn_cidr_block`: Rango CIDR
- `subnet_cidr_block`: Rango de subnet

### Kubernetes
- `app_namespace`: Namespace para workloads
- `virtual_node_taint_key`: Clave del taint
- `virtual_node_taint_value`: Valor del taint

## Outputs

Después del despliegue:

- `cluster_id`: OCID del cluster
- `cluster_kubeconfig`: Información de conexión
- `virtual_node_pool_id`: ID del virtual node pool
- `pod_resources`: Especificación de recursos por pod
- `vcn_id`: OCID de la VCN
- `estimated_cost_per_pod_hour`: Costo estimado

## Seguridad

### Mejores Prácticas

1. **Aislamiento**
   - Cada pod en su propia Container Instance
   - Encriptación nativa de datos
   - Políticas de red mediante Security Lists

2. **Control de Acceso**
   - IAM para acceso a OKE
   - RBAC en Kubernetes
   - ServiceAccounts con permisos mínimos

3. **Monitoreo**
   - OCI Monitoring integrado
   - Logs de Container Instances
   - Métricas de consumo de recursos

4. **Cumplimiento**
   - Auditoría automática en OCI
   - Encriptación en tránsito (TLS)
   - Políticas de retención de logs

## Troubleshooting

### Virtual Nodes no aparecen

```bash
# Verificar estado del cluster
kubectl get nodes

# Ver eventos
kubectl describe node <VIRTUAL_NODE_NAME>

# Revisar logs de OKE
oci ce cluster get --cluster-id <CLUSTER_ID>
```

### Pod no se ejecuta en Virtual Node

```bash
# Verificar tolerancias
kubectl describe pod <POD_NAME> -n virtual-workloads

# Ver taints de Virtual Nodes
kubectl describe node <VIRTUAL_NODE> | grep Taints

# Aplicar tolerancia en pod:
spec:
  tolerations:
  - key: virtual-node
    operator: Equal
    value: "true"
    effect: NoSchedule
```

### Evicción de Pods

```bash
# Revisar eventos de evicción
kubectl get events -n virtual-workloads --sort-by='.lastTimestamp'

# Ver duración de gracia
grep pod_eviction_grace_duration_seconds terraform.tfvars

# Aumentar si es necesario (en segundos)
```

## Ejemplos de Workloads

### 1. Batch Jobs
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: data-processing
  namespace: virtual-workloads
spec:
  template:
    spec:
      tolerations:
      - key: virtual-node
        operator: Equal
        value: "true"
      containers:
      - name: processor
        image: myrepo/processor:latest
        resources:
          requests:
            cpu: 500m
            memory: 1Gi
          limits:
            cpu: 2
            memory: 2Gi
```

### 2. API Serverless
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-serverless
  namespace: virtual-workloads
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api-serverless
  template:
    metadata:
      labels:
        app: api-serverless
    spec:
      tolerations:
      - key: virtual-node
        operator: Equal
        value: "true"
      containers:
      - name: api
        image: myrepo/api:latest
        ports:
        - containerPort: 8080
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
```

### 3. Scheduled Tasks (CronJob)
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cleanup-task
  namespace: virtual-workloads
spec:
  schedule: "0 2 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          tolerations:
          - key: virtual-node
            operator: Equal
            value: "true"
          containers:
          - name: cleanup
            image: myrepo/cleanup:latest
          restartPolicy: OnFailure
```

## Modelo de Costos

### Estructura de Facturación

Componente | Costo
-----------|-------
Container Instance (Pod) | USD $0.0003 por OCPU-hora
Memoria | Incluida en OCPU
Networking | Primeros 10 Gbps incluidos
Storage (logs) | Por GB de logs almacenados

### Ejemplo de Costo Mensual

Escenario: 10 pods, 1 OCPU cada uno, 4 GB RAM, 8 horas/día

```
10 pods × 1 OCPU × $0.0003/OCPU-hora × 8 horas/día × 30 días
= 10 × 1 × 0.0003 × 240 horas/mes
= USD $0.72/mes

Vs. VM.Standard.E4.Flex (3 nodos):
= 3 nodos × 2 OCPUs × ~$0.06/OCPU-hora × 730 horas/mes
= USD ~$262/mes
```

**Ahorro: ~99.7% para workloads intermitentes**

## Destrucción de Recursos

```bash
# Destruir toda la infraestructura
terraform destroy

# Confirmar cuando se solicite
```

## Próximas Etapas

1. **Integración CI/CD**
   - Automatizar despliegues
   - Implementar GitOps
   - Configurar webhooks

2. **Monitoreo y Alertas**
   - Integrar Prometheus
   - Crear dashboards Grafana
   - Configurar alertas OCI

3. **Escalado Avanzado**
   - HPA (Horizontal Pod Autoscaler)
   - VPA (Vertical Pod Autoscaler)
   - Política de costos

4. **Seguridad Adicional**
   - Pod Security Standards
   - Network Policies
   - Scanning de imágenes

## Comparativa: Virtual Nodes vs Node Pool Tradicional

| Aspecto | Virtual Nodes | Node Pool |
|---------|---------------|----------|
| Gestión de Nodos | OCI (automático) | Manual |
| Inicio de Pods | Instantáneo | ~1-2 minutos |
| Costo | Por uso (granular) | Por hora |
| Escalado | Instantáneo | Minutos |
| Overhead | Mínimo | Recursos ociosos |
| Límite de Pods | 1000 | Dependiente de nodos |
| Caso Ideal | Bursty, intermitente | Cargas sostenidas |

## Support y Recursos

- **OCI Virtual Nodes**: https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengoverview.htm
- **Terraform Provider**: https://registry.terraform.io/providers/oracle/oci/latest/docs
- **Container Instances**: https://docs.oracle.com/en-us/iaas/Content/container-instances/home.htm
- **Kubernetes**: https://kubernetes.io/docs/

## Notas Importantes

- Virtual Nodes **no soportan DaemonSets** (por naturaleza)
- Los pods de Virtual Nodes **no pueden usar privilegios**
- Se requiere **cluster ENHANCED** (no compatible con Basic)
- La región debe **soportar Virtual Nodes** (no en todas disponible)
- Cada pod requiere tolerancia explícita a taints de Virtual Node

---

**Última Actualización**: 2026-04-12  
**Versión**: 1.0  
**Mantenedor**: DevOps LATAM
