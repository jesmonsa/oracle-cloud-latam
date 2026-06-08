# OKE con OCIR Registry - Arquitectura de Referencia

## Descripción General

Esta arquitectura implementa un **cluster de Kubernetes Enterprise (OKE)** en Oracle Cloud Infrastructure integrado con **Oracle Cloud Infrastructure Registry (OCIR)**, proporcionando una solución completa para orquestar aplicaciones containerizadas con un registro privado de imágenes.

### Características Principales

- **Cluster OKE Administrado**: Kubernetes completamente gestionado por Oracle
- **OCIR Privado**: Registro de contenedores privado dentro de OCI
- **VCN Aislada**: Red virtual dedicada con subnets segmentadas
- **Node Pool Escalable**: Configuración flexible de nodos con ajuste de recursos
- **Kubernetes ImagePullSecret**: Integración segura entre cluster y registry
- **Namespace Isolation**: Aislamiento de workloads por namespace
- **Enterprise-Ready**: Validaciones, tagging, y best practices aplicados

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
│  │  │   │  OKE Cluster (Enhanced)             │   │   │ │
│  │  │   │                                     │   │   │ │
│  │  │   │  ┌──────────────────────────────┐   │   │   │ │
│  │  │   │  │ Master Nodes (OCI-Managed)  │   │   │   │ │
│  │  │   │  └──────────────────────────────┘   │   │   │ │
│  │  │   │                                     │   │   │ │
│  │  │   │  ┌──────────────────────────────┐   │   │   │ │
│  │  │   │  │ Worker Node Pool             │   │   │   │ │
│  │  │   │  │ (3x VM.Standard.E4.Flex)    │   │   │   │ │
│  │  │   │  │ + Namespace: ocir-workloads │   │   │   │ │
│  │  │   │  │ + ImagePullSecret: OCIR     │   │   │   │ │
│  │  │   │  └──────────────────────────────┘   │   │   │ │
│  │  │   └─────────────────────────────────────┘   │   │ │
│  │  │                                             │   │ │
│  │  │  Addons:                                    │   │ │
│  │  │  - CoreDNS                                  │   │ │
│  │  │  - kube-proxy                               │   │ │
│  │  │  - VCN-Native Pod Networking                │   │ │
│  │  └─────────────────────────────────────────────┘   │ │
│  │                                                     │ │
│  │  ┌─────────────────────────────────────────────┐   │ │
│  │  │   Internet Gateway                          │   │ │
│  │  │   NAT Gateway (para tráfico de salida)      │   │ │
│  │  │   Route Tables                              │   │ │
│  │  └─────────────────────────────────────────────┘   │ │
│  └──────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐ │
│  │        Oracle Cloud Infrastructure Registry          │ │
│  │                  (OCIR - Privado)                   │ │
│  │                                                     │ │
│  │  Repositorio: sa-santiago-1.ocir.io/namespace/    │ │
│  │              mi-aplicacion                         │ │
│  │                                                     │ │
│  │  - Almacenamiento: Object Storage (backend)        │ │
│  │  - Encriptación: Managed Keys                      │ │
│  │  - Acceso: IAM + Credenciales Docker              │ │
│  └──────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│           Kubernetes Namespace Isolation                     │
│                                                             │
│  Namespace: ocir-workloads                                 │
│  ├─ Secret: ocir-pull-secret (Docker credentials)         │
│  ├─ ServiceAccount: ocir-sa (con permiso de pull)         │
│  ├─ NetworkPolicy: Solo tráfico interno a OCIR            │
│  └─ Pods: Heredan ImagePullSecret del namespace           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Componentes Técnicos

### 1. Virtual Cloud Network (VCN)
- **CIDR Block**: `10.0.0.0/16` (configurable)
- **Subnet Pública**: `10.0.1.0/24`
- **Internet Gateway**: Para acceso público
- **NAT Gateway**: Para tráfico de salida de nodos
- **Route Tables**: Configuración de rutas con reglas de egreso

### 2. OKE Cluster
- **Versión**: Kubernetes v1.29 (configurable)
- **Modo**: Enhanced (con features avanzados)
- **Master Nodes**: Gestionados por Oracle (HA)
- **CIDR de Pods**: Configurable (usualmente 10.244.0.0/16)
- **CIDR de Servicios**: Configurable (usualmente 10.96.0.0/12)
- **Add-ons**: CoreDNS, kube-proxy, VCN-Native

### 3. Node Pool
- **Shape**: `VM.Standard.E4.Flex` (personalizable)
- **OCPUs**: 2 (configurable)
- **Memoria**: 16 GB (configurable)
- **Nodos Iniciales**: 3 (configurable)
- **Imágenes**: Oracle Linux 8
- **Labels**: Para organización de workloads
- **Taints**: Opcionales para workloads especializadas

### 4. OCIR Repository
- **Namespace**: Basado en compartment
- **Nombre Repositorio**: `mi-aplicacion`
- **Privacidad**: Por defecto privado
- **Encriptación**: Soportada
- **Versionado**: Etiquetas Docker estándar
- **Retención**: Configurable con políticas de limpieza

### 5. Kubernetes Configuration
- **Namespace**: `ocir-workloads` (aislamiento)
- **ImagePullSecret**: Credenciales de OCIR
- **RBAC**: ServiceAccount con permisos mínimos
- **NetworkPolicy**: Restricción de tráfico de pods
- **ResourceQuotas**: Límites por namespace

## Requisitos Previos

### Infraestructura
- Cuenta de Oracle Cloud Infrastructure activa
- Límites de recursos disponibles (compute, VCN)
- Cuota de compartments para organizar recursos

### Software
- Terraform >= 1.5.0
- OCI CLI >= 3.0.0
- kubectl >= 1.28
- Docker CLI (para pruebas de push a OCIR)

### Credenciales y Permisos
- API Key de usuario IAM con permisos de:
  - `networking/*` (para VCN)
  - `container/*` (para OKE)
  - `artifacts-container-repository/*` (para OCIR)
  - `instance/*` (para nodos)

### Información Necesaria
- OCID del Tenancy
- OCID del usuario IAM
- Fingerprint de API Key
- Ruta al archivo de clave privada PEM
- Nombre del registry namespace de OCIR
- OCID del compartment para imágenes

## Instalación y Despliegue

### 1. Preparación del Entorno

```bash
# Clonar repositorio
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/Arquitectura-base/oke/oke-ocir-registry

# Instalar dependencias
terraform init

# Validar configuración
terraform validate
```

### 2. Configuración de Variables

```bash
# Copiar archivo de ejemplo
cp terraform.tfvars.example terraform.tfvars

# Editar con valores reales
nano terraform.tfvars
```

Variables críticas a completar:
- `tenancy_ocid`: Obtenido de OCI Console
- `current_user_ocid`: Tu usuario IAM
- `fingerprint`: De tu API Key
- `private_key_path`: Ruta a archivo PEM
- `registry_namespace`: Tu namespace en OCIR
- `image_compartment_id`: Compartment para imágenes

### 3. Plan y Validación

```bash
# Generar plan de Terraform
terraform plan -out=tfplan

# Revisar cambios (sin aplicar aún)
terraform show tfplan
```

### 4. Aplicar Configuración

```bash
# Aplicar el plan
terraform apply tfplan

# Esperar 15-20 minutos para provisionamiento
# Monitor en OCI Console: Kubernetes > Clusters
```

### 5. Configuración Local de kubectl

```bash
# Obtener kubeconfig
oci ce cluster create-kubeconfig \
  --cluster-id <CLUSTER_ID> \
  --file $HOME/.kube/config-oke \
  --region sa-santiago-1

# Configurar kubectl
export KUBECONFIG=$HOME/.kube/config-oke

# Verificar conexión
kubectl get nodes
kubectl get namespaces
```

### 6. Configuración de OCIR

```bash
# Obtener credenciales de OCIR
# 1. Console > Container Registries > Repositories
# 2. Generar token de lectura/escritura
# 3. Crear credenciales Docker

docker login -u <username> -p <password> \
  sa-santiago-1.ocir.io

# Verificar acceso
docker pull sa-santiago-1.ocir.io/namespace/mi-aplicacion:latest
```

### 7. Prueba de Integración

```bash
# Verificar namespace
kubectl get namespace ocir-workloads

# Ver secret de pull
kubectl get secret ocir-pull-secret \
  -n ocir-workloads -o yaml

# Desplegar un pod de prueba
kubectl run test-pod \
  --image=sa-santiago-1.ocir.io/namespace/mi-aplicacion:latest \
  -n ocir-workloads \
  --overrides='{"spec":{"imagePullSecrets":[{"name":"ocir-pull-secret"}]}}'

# Verificar status
kubectl get pods -n ocir-workloads
kubectl logs test-pod -n ocir-workloads
```

## Variables Configurables

### Cluster
- `cluster_name`: Nombre identificativo del cluster
- `kubernetes_version`: Versión de K8s (v1.28, v1.29, v1.30)
- `initial_node_count`: Cantidad de nodos iniciales (1-100)
- `node_shape`: Tipo de instancia (E4.Flex, E5.Flex, A1.Flex)
- `node_ocpus`: OCPUs por nodo (1-64)
- `node_memory_gb`: Memoria por nodo (1-1024 GB)

### VCN
- `vcn_cidr_block`: Rango CIDR de la VCN
- `subnet_cidr_block`: Rango CIDR de la subnet
- `vcn_name`: Nombre de la VCN

### OCIR
- `registry_namespace`: Namespace en OCIR
- `repository_name`: Nombre del repositorio
- `image_compartment_id`: Compartment para almacenar imágenes
- `is_public_registry`: Privacidad del repositorio (true/false)

### Kubernetes
- `kubernetes_namespace`: Namespace para aplicaciones
- `image_pull_secret_name`: Nombre del secret de credenciales

### Tagging
- `tags`: Etiquetas de OCI (required tags)
- `freeform_tags`: Etiquetas libres para clasificación

## Outputs

Después del despliegue, Terraform exporta:

- `cluster_id`: OCID del cluster (para referencias posteriores)
- `cluster_kubeconfig`: Información para configurar kubectl
- `node_pool_id`: OCID del pool de nodos
- `ocir_repository_url`: URL completa del repositorio OCIR
- `kubernetes_namespace_id`: ID del namespace K8s
- `image_pull_secret_name`: Nombre del secret de autenticación
- `vcn_id`: OCID de la VCN
- `subnet_id`: OCID de la subnet

## Seguridad

### Mejores Prácticas Implementadas

1. **Cifrado**
   - Encriptación en tránsito (TLS para API de K8s)
   - Encriptación en reposo (Object Storage backend de OCIR)
   - Secrets de K8s encriptados en etcd

2. **Control de Acceso (RBAC)**
   - ServiceAccount dedicada por namespace
   - Roles con permisos mínimos (least privilege)
   - ImagePullSecret segregado por namespace

3. **Network Security**
   - VCN aislada con CIDR privado
   - Security Lists para filtrado de tráfico
   - NAT Gateway para anonimizar tráfico de salida
   - Network Policies en Kubernetes (si se requiere)

4. **Identidad**
   - Autenticación IAM de OCI
   - Credenciales Docker versionadas
   - Tokens de acceso con expiración

### Recomendaciones Adicionales

1. **Monitoreo**
   - Habilitar OCI Monitoring para cluster
   - Integrar con alertas de OCI
   - Recolectar logs con Fluentd/Logstash

2. **Backup y Recuperación**
   - Configurar snapshots de Object Storage
   - Implementar política de retención (30 días)
   - Probar restauración regularmente

3. **Compliance**
   - Aplicar políticas de retención de imágenes
   - Auditar acceso a OCIR
   - Documentar cadena de custodia de imágenes

## Troubleshooting

### Cluster no inicia

```bash
# Verificar estado del cluster
oci ce cluster get --cluster-id <CLUSTER_ID> \
  --query 'data | {status: lifecycle_state, message: error_message}'

# Revisar logs en OCI Console
# Compute > Instances > Verificar estado de nodos
```

### ImagePullSecret falla

```bash
# Verificar credenciales
kubectl get secret ocir-pull-secret \
  -n ocir-workloads \
  -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq

# Re-crear secret si es necesario
kubectl delete secret ocir-pull-secret \
  -n ocir-workloads
kubectl create secret docker-registry ocir-pull-secret \
  --docker-server=sa-santiago-1.ocir.io \
  --docker-username=<username> \
  --docker-password=<password> \
  --docker-email=noreply@oracle.com \
  -n ocir-workloads
```

### Connectivity a OCIR

```bash
# Verificar DNS
kubectl run -it --rm debug --image=busybox \
  -n ocir-workloads -- nslookup sa-santiago-1.ocir.io

# Probar conectividad
kubectl run -it --rm debug --image=curlimages/curl \
  -n ocir-workloads -- curl -v \
  https://sa-santiago-1.ocir.io/v2/
```

## Mantenimiento

### Actualizaciones de Kubernetes

```bash
# Verificar versión disponible
terraform plan | grep kubernetes_version

# Actualizar variable en tfvars
# kubernetes_version = "v1.30"

# Aplicar actualización
terraform apply

# El cluster se actualizará de forma gradual
# sin downtime de aplicaciones
```

### Escalado de Nodos

```bash
# Modificar initial_node_count
# node_count = 5

terraform apply
```

### Rotación de Credenciales OCIR

```bash
# 1. Generar nuevas credenciales en Console
# 2. Actualizar secret en Kubernetes
kubectl patch secret ocir-pull-secret \
  -n ocir-workloads -p \
  '{"data":{".dockerconfigjson":"'$(cat ~/.docker/config.json | base64)'"}}'

# 3. Rotar pods existentes
kubectl rollout restart deployment/<app> \
  -n ocir-workloads
```

## Costos Estimados

Componente | Costo Mensual | Notas
-----------|--------------|-------
OKE (Master) | ~$51 USD | Cluster gratuito, pago solo por nodos
VM.Standard.E4.Flex (3x) | ~$180 USD | 2 OCPUs, 16 GB RAM cada uno
VCN | Incluido | Primeros 10 Gbps de tráfico incluidos
OCIR | ~$0.018/GB | Basado en almacenamiento de imágenes
Tráfico de Datos | Variable | Egreso a internet cargado por Gbps

**Total Estimado**: $230-350 USD/mes (sin aplicaciones adicionales)

## Destrucción de Recursos

```bash
# Destruir toda la infraestructura
terraform destroy

# Confirmar eliminación cuando se solicite
# ADVERTENCIA: Esto elimina el cluster, OCIR, VCN y todos los recursos
```

## Próximas Etapas

1. **Deploys de Aplicaciones**
   - Crear manifiestos Kubernetes (Deployment, Service)
   - Configurar autoscaling con HPA
   - Implementar liveness/readiness probes

2. **Observabilidad**
   - Instalar Prometheus + Grafana
   - Integrar con OCI Monitoring
   - Configurar alertas

3. **CI/CD**
   - Integrar con Jenkins/GitLab CI
   - Automatizar builds y pushes a OCIR
   - Implementar GitOps con ArgoCD

4. **Seguridad Avanzada**
   - Implementar Pod Security Policies
   - Integrar con OCI Security Advisor
   - Configurar Network Policies

## Support y Recursos

- **OCI Documentation**: https://docs.oracle.com/en-us/iaas/Content/container-kubernetes/home.htm
- **Terraform OCI Provider**: https://registry.terraform.io/providers/oracle/oci/latest/docs
- **OCI OCIR Guide**: https://docs.oracle.com/en-us/iaas/Content/Registry/home.htm
- **Kubernetes Docs**: https://kubernetes.io/docs/

## Notas Importantes

- Este despliegue usa configuración de **producción** (3 nodos, alta disponibilidad)
- Se recomienda **revision mensual** de tamaño de nodos según utilización
- Mantener **Terraform state** seguro (considerar remoto en OCI)
- Implementar **política de cleanup** de imágenes antiguas en OCIR
- Realizar **backup de etcd** regularmente

---

**Última Actualización**: 2026-04-12  
**Versión**: 1.0  
**Mantenedor**: DevOps LATAM
