# Arquitectura OKE: Almacenamiento Compartido con File Storage Service

## Descripción General

Esta arquitectura de referencia implementa **almacenamiento de archivos compartido empresarial** basado en Oracle File Storage Service (FSS) con acceso ReadWriteMany desde múltiples pods y nodos simultáneamente.

Proporciona:
- Almacenamiento NFS v3/v4.1 totalmente gestionado
- Escalabilidad automática de capacidad (100 GB - 8.3 TB)
- Snapshots automáticos configurables
- Alta disponibilidad y durabilidad
- Encriptación at-rest
- Control de acceso granular por CIDR
- Auditoría de accesos integrada

## Casos de Uso

### Aplicaciones Ideales
- **Almacenamiento de Contenido**: Media files, documentos, assets estáticos
- **Shared Caching**: Redis cluster backups, Memcached persistence
- **Analítica**: Datasets compartidos para processamiento distribuido
- **Colaboración**: Documentos compartidos, wikis, repositorios
- **Backups Centralizados**: Destino de backup para múltiples aplicaciones
- **Machine Learning**: Datasets y modelos compartidos entre pods

### Ventajas Técnicas
- **ReadWriteMany**: Múltiples pods leen/escriben simultáneamente
- **No Bottleneck**: Throughput escalable sin punto único de falla
- **Snapshots Instantáneos**: Backups sin downtime
- **Auto-Expansion**: Crece automáticamente cuando se necesita
- **Costo Eficiente**: Pago por uso, sin reserva de capacidad
- **Integración OCI**: Monitoreo nativo y auditoría

## Componentes Arquitectónicos

### 1. Infraestructura de Red

```
┌───────────────────────────────────────────────────────────┐
│          Virtual Cloud Network (10.3.0.0/16)              │
├───────────────────────────────────────────────────────────┤
│                                                           │
│  ┌─────────────────────────────────────────────────────┐ │
│  │  Subnet Kubernetes (10.3.1.0/24)                    │ │
│  │  - Control Plane                                    │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐ │
│  │  Subnet Nodos (10.3.2.0/24)                         │ │
│  │  - Pod A ──┐                                        │ │
│  │  - Pod B ──┼──► NFS Mount Point 10.3.3.10:2049    │ │
│  │  - Pod C ──┘                                        │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐ │
│  │  Subnet FSS (10.3.3.0/24)                           │ │
│  │  - Mount Target (IP privada: 10.3.3.10)            │ │
│  │    └─► File System (100-8388608 GB)                │ │
│  │        └─► Export (/exportfs)                      │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

### 2. File Storage Service (FSS)

**Características:**
- **Capacidad**: 100 GB - 8.3 TB
- **Auto-Expansion**: Aumenta automáticamente a 80% uso
- **Performance**: Throughput predecible, latencia baja
- **Durabilidad**: Datos replicados dentro del AD
- **Encriptación**: AES-256 at-rest automático

**Topología:**
```
┌──────────────────────────────────────────────┐
│  File System (FSS)                           │
│  Size: 100 GB (expandible a 500 GB)         │
│  Encryption: OCI-Managed (gratis)           │
│  Replication: Dentro de AD                  │
│  Snapshots: Diarios con 30 días retención  │
└──────────────────────────────────────────────┘
          │
          │ (export)
          ▼
┌──────────────────────────────────────────────┐
│  Mount Target                                │
│  IP Privada: 10.3.3.10                      │
│  Protocolo: NFS v3 / v4.1                   │
│  Puertos: 2049 (NFS), 111 (mountd)         │
│  HA: Automático dentro de FSS               │
└──────────────────────────────────────────────┘
          │
          │ (monta)
          ▼
┌──────────────────────────────────────────────┐
│  PersistentVolume (Kubernetes)              │
│  AccessMode: ReadWriteMany                  │
│  Size: 100 GB                               │
│  StorageClass: oci-fss                      │
└──────────────────────────────────────────────┘
```

### 3. Mount Target

**Punto de montaje NFS:**
- Dirección IP privada en subred de FSS
- Acceso desde nodos de trabajo dentro de VCN
- Puerto 2049 para NFS, 111 para mountd
- Network Security Group controla el acceso

**Ejemplo de montaje manual:**
```bash
# En nodo OKE
sudo mkdir -p /mnt/shared
sudo mount -t nfs -o vers=3,proto=tcp 10.3.3.10:/exportfs /mnt/shared

# Verificar montaje
df -h /mnt/shared
```

### 4. Export Set

**Configuración de exportación:**
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: fss-pv
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: 10.3.3.10      # IP del Mount Target
    path: "/exportfs"      # Ruta de exportación
  persistentVolumeReclaimPolicy: Retain
```

**Parámetros:**
- **Server**: IP del Mount Target
- **Path**: Ruta en FSS (/exportfs)
- **Access Modes**: ReadWriteMany (múltiples lectores/escritores)
- **Permissions**: POSIX (owner, group, other)

### 5. Network Security Group

**Reglas de Ingreso:**
```yaml
- Protocol: TCP
  Port: 2049
  Source: 10.3.0.0/16  # Toda la VCN

- Protocol: TCP
  Port: 111
  Source: 10.3.0.0/16  # Toda la VCN

- Protocol: UDP
  Port: 2049
  Source: 10.3.0.0/16

- Protocol: UDP
  Port: 111
  Source: 10.3.0.0/16
```

**Restricción Opcional:**
```yaml
restricted_client_cidr_list = ["10.3.2.0/24"]  # Solo subred de nodos
```

### 6. Snapshots Automáticos

**Política Configurada:**
```
Frecuencia: Diaria (2:00 AM UTC)
Retención: 30 días
Espaciado: 24 horas entre snapshots
Tamaño: Incremental (solo cambios)
Recuperación: Clonación instantánea
```

**Ejemplo de Clonación:**
```bash
# Crear nuevo PV desde snapshot
oci file-storage file-system create-from-snapshot \
  --snapshot-id ocid1.filesystemsnapshot... \
  --availability-domain ChKb:SA-SANTIAGO-1-AD-1 \
  --compartment-id ocid1.compartment...

# Montar en Kubernetes como nuevo PV
kubectl apply -f pv-from-snapshot.yaml
```

### 7. Auto-Expansion

**Monitoreo Automático:**
```
Uso < 50%:  Sin acción
Uso 50-80%: Alertas en dashboard
Uso > 80%:  Expansión automática (+50 GB)
```

**Configuración:**
```yaml
enable_auto_expansion: true
auto_expansion_size_gb: 50
max_fss_size_gb: 500
```

**Proceso:**
1. Sistema monitorea uso cada 10 minutos
2. Al alcanzar 80%, inicia expansión
3. Añade 50 GB (configurable)
4. Nueva capacidad disponible sin downtime
5. Se detiene al alcanzar máximo (500 GB)

## Guía de Instalación

### Requisitos Previos

1. Acceso a OCI con credenciales
2. Terraform >= 1.5.0
3. kubectl >= 1.26
4. Helm >= 3.12

### Paso 1: Configurar Variables

```bash
cp terraform.tfvars.example terraform.tfvars
vi terraform.tfvars
```

**Valores Importantes:**
```hcl
fss_initial_size_gb = 100          # Tamaño inicial
fss_availability_domain = ""        # Auto-detectar
export_path = "/exportfs"           # Ruta de exportación
nfs_version = "NFSv3"               # o NFSv4.1
enable_auto_expansion = true        # Expandir automáticamente
max_fss_size_gb = 500               # Límite máximo
```

### Paso 2: Crear Infraestructura

```bash
terraform init -backend-config="bucket=tf-state" \
               -backend-config="key=oke/fss/terraform.tfstate"

terraform validate
terraform plan -out=tfplan
terraform apply tfplan

# Obtener kubeconfig
oci ce cluster create-kubeconfig \
  --cluster-id $(terraform output -raw cluster_id) \
  --file ~/.kube/oke-config

export KUBECONFIG=~/.kube/oke-config
```

### Paso 3: Instalar Provisioner FSS

```bash
# Agregar repositorio Helm
helm repo add oracle https://oracle.github.io/helm-charts

# Instalar provisioner
helm install oci-fss-provisioner oracle/oci-fss-provisioner \
  --namespace kube-system \
  --set image.tag=v1.3.0

# Verificar
kubectl get pods -n kube-system | grep fss
```

### Paso 4: Crear PVC Compartido

```yaml
# fss-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: shared-storage
  namespace: default
spec:
  accessModes:
    - ReadWriteMany  # Crítico: múltiples accesos
  storageClassName: oci-fss
  resources:
    requests:
      storage: 100Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: consumer-1
spec:
  containers:
  - name: app
    image: ubuntu:22.04
    command: ["sleep", "3600"]
    volumeMounts:
    - name: shared
      mountPath: /data
  volumes:
  - name: shared
    persistentVolumeClaim:
      claimName: shared-storage
```

```bash
kubectl apply -f fss-pvc.yaml

# Esperar a que se monte
kubectl get pvc -w
kubectl get pv -w
```

### Paso 5: Verificar Funcionamiento

```bash
# En Pod 1
kubectl exec -it consumer-1 -- bash
echo "Hola desde Pod 1" > /data/test.txt
cat /data/test.txt

# En Pod 2
kubectl exec -it consumer-2 -- bash
cat /data/test.txt  # Debe ver el mismo archivo
```

## Operaciones Comunes

### Expandir FSS Manualmente

```bash
# Ver tamaño actual
oci file-storage file-system get --file-system-id <FS_ID>

# Expandir a 200 GB
oci file-storage file-system update --file-system-id <FS_ID> \
  --size-gb 200
```

### Crear Snapshot Manual

```bash
# Crear snapshot
oci file-storage snapshot create \
  --file-system-id <FS_ID> \
  --display-name "backup-$(date +%Y%m%d)"

# Listar snapshots
oci file-storage snapshot list --compartment-id <COMP_ID>

# Restaurar desde snapshot
oci file-storage file-system create-from-snapshot \
  --snapshot-id <SNAPSHOT_ID> \
  --availability-domain <AD>
```

### Monitorear Uso

```bash
# Ver uso en OCI Console
oci file-storage file-system get --file-system-id <FS_ID> \
  --query 'data.{id, size_gb: metered_bytes}'

# En Kubernetes
df -h /data  # Dentro de un pod

# Métricas de OCI
oci monitoring metric-data summarize \
  --namespace "oci_fss" \
  --metric-name "MeteredBytes" \
  --dimensions '[{"name":"fsId","value":"<FS_ID>"}]' \
  --statistics '["Sum"]'
```

### Cambiar Permisos de Exportación

```bash
# Solo lectura
oci file-storage export update --export-id <EXPORT_ID> \
  --options '[{"source":"0.0.0.0/0","requires_privileged_source_port":false,"access":"READ_ONLY","identity_squash":"ROOT"}]'

# Lectura-escritura
oci file-storage export update --export-id <EXPORT_ID> \
  --options '[{"source":"0.0.0.0/0","requires_privileged_source_port":false,"access":"READ_WRITE","identity_squash":"ROOT"}]'
```

## Troubleshooting

### PVC No Se Monta

```bash
# 1. Ver eventos
kubectl describe pvc shared-storage

# 2. Ver logs del provisioner
kubectl logs -n kube-system -l app=fss-provisioner --tail=50

# 3. Verificar que Mount Target está activo
oci file-storage mount-target get --mount-target-id <MT_ID>

# 4. Verificar conectividad
kubectl run -it --rm debug --image=alpine --restart=Never -- \
  sh -c "apk add nfs-utils && showmount -e 10.3.3.10"
```

### Montaje Lento o Timeouts

```bash
# Aumentar timeout en opciones NFS
kubectl patch pv <PV_NAME> -p '{"spec":{"nfs":{"mountOptions":["vers=3","timeo=30","retrans=3"]}}}'

# Desmontary remontary PV
kubectl delete pod <POD_NAME>  # Kubernetes remontará

# Aumentar timeouts del Mount Target
oci file-storage export update --export-id <EXPORT_ID> \
  --max-idle-time-seconds 0  # Sin timeout
```

### Espacio Insuficiente

```bash
# Limpiar archivos viejos
kubectl exec -it <POD_NAME> -- bash
find /data -type f -mtime +30 -delete  # Borrar archivos > 30 días

# Expandir FSS
# (Auto-expansion lo hará si está habilitado)
# O manualmente como se mostró arriba
```

## Optimizaciones para Producción

### 1. Read-Only Cache Layer

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: cache-server
spec:
  containers:
  - name: memcached
    image: memcached:latest
    volumeMounts:
    - name: data
      mountPath: /data
      readOnly: true  # Solo lectura
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: shared-storage
```

### 2. Separate Read and Write

```yaml
# PVC con Read-Only para lectores
- name: shared-ro
  persistentVolumeClaim:
    claimName: shared-storage
    readOnly: true

# PVC con Read-Write para escritores
- name: shared-rw
  persistentVolumeClaim:
    claimName: shared-storage
```

### 3. Pod Disruption Budget

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: file-consumer-pdb
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: file-consumer
```

### 4. Quality of Service

```yaml
spec:
  containers:
  - name: app
    resources:
      requests:
        memory: "256Mi"
        cpu: "100m"
      limits:
        memory: "512Mi"
        cpu: "500m"
```

## Costos Estimados (Mensual - Santiago)

| Recurso | Cantidad | Costo |
|---------|----------|--------|
| OKE Cluster | 1 | Gratis |
| Nodos (3 × E4.Flex) | 3 × (2 OCPU, 8GB) | ~$180 |
| FSS 100 GB | 1 | ~$10 |
| Snapshots (30/mes) | 30 | ~$3 |
| **Total Aproximado** | | **~$193** |

*Muy económico para almacenamiento compartido de alto rendimiento.*

## Comparación: Block vs FSS

| Aspecto | Block Volume | FSS |
|---------|-------------|-----|
| AccessMode | ReadWriteOnce | ReadWriteMany |
| Performance | Muy Alta | Alta |
| Caso de Uso | BD, Apps | Contenido, Datos |
| Múltiples Pods | No | Sí |
| Latencia | Muy Baja | Baja |
| Precio | Medio | Bajo |

## Recursos Adicionales

- [OCI File Storage Service](https://docs.oracle.com/en-us/iaas/Content/File/home.htm)
- [OKE FSS Integration](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengcreatingfilesystem.htm)
- [NFS Protocol](https://datatracker.ietf.org/doc/html/rfc7530)
- [Kubernetes NFS PV](https://kubernetes.io/docs/concepts/storage/volumes/#nfs)

---

**Última actualización**: 2026-04-12  
**Versión**: 1.0.0  
**Mantenedor**: Cloud Architecture Team
