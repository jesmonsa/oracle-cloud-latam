# Arquitectura OKE: Almacenamiento Persistente con Block Volume

## Descripción General

Esta arquitectura de referencia implementa **almacenamiento persistente de alto rendimiento** basado en Oracle Cloud Infrastructure Block Volume Storage con integración nativa en Kubernetes mediante el CSI (Container Storage Interface) driver.

Proporciona:
- Volúmenes de bloque escalables (50 GB - 16 TB)
- Performance configurables (10-60 VPUs/GB)
- Replicación automática entre zonas de disponibilidad
- Snapshots y backups automáticos
- Encriptación at-rest
- Disaster Recovery integrada
- Clonación rápida de volúmenes

## Casos de Uso

### Aplicaciones Ideales
- **Bases de Datos**: MySQL, PostgreSQL, Oracle DB, MongoDB
- **Data Warehousing**: Elasticsearch, Apache Druid, QuestDB
- **Machine Learning**: TensorFlow datasets, modelo storage
- **Aplicaciones Transaccionales**: Requisitos ACID
- **Aplicaciones Stateful**: Redis, RabbitMQ, Kafka brokers
- **File Servers**: NFS backend con snapshots

### Ventajas Técnicas
- **Rendimiento Predecible**: VPUs garantizadas
- **Durabilidad**: Replicación automática cross-AD
- **Recovery Rápido**: RTO < 5 minutos, RPO < 1 minuto
- **Snapshots Instantáneos**: Clonación sin copia completa
- **Escalabilidad Dinámica**: Aumentar tamaño sin downtime
- **Encriptación Nativa**: AES-256 automático

## Componentes Arquitectónicos

### 1. Infraestructura de Red

```
┌────────────────────────────────────────────────────┐
│   Virtual Cloud Network (10.2.0.0/16)              │
├────────────────────────────────────────────────────┤
│                                                    │
│  AD-1              AD-2              AD-3          │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    │
│  │ Subnet   │    │ Subnet   │    │ Subnet   │    │
│  │ Nodos    │    │ Nodos    │    │ Nodos    │    │
│  │          │    │          │    │          │    │
│  │ Block    │    │ Block    │    │ Block    │    │
│  │ Volume 1 │◄──►│ Volume 2 │◄──►│ Volume 3 │    │
│  │          │    │          │    │          │    │
│  └──────────┘    └──────────┘    └──────────┘    │
│                                                    │
│  Replicación automática (RPO < 1 min)             │
│                                                    │
└────────────────────────────────────────────────────┘
```

**Topología de ADs:**
- 3 Availability Domains (si la región lo permite)
- Volúmenes replicados automáticamente
- Failover manual o automático configurable

### 2. OKE Cluster

**Configuración:**
- Control Plane: Gestionado por Oracle
- Node Pool: Distribuido en múltiples ADs
- CSI Driver: Instalado en kube-system
- RBAC: Permisos configurados

### 3. CSI Driver de OCI

**Características:**
```yaml
# Componentes instalados
- csi-provisioner: Provisioning de PVCs
- csi-attacher: Attachment de volúmenes
- csi-resizer: Redimensionamiento de volúmenes
- csi-snapshotter: Gestión de snapshots
- csi-node-driver: Plugin en cada nodo
```

**Capacidades:**
- Create, Delete, List, Get PersistentVolumes
- Snapshots automáticos y bajo demanda
- Clonación rápida (shallow copy)
- Redimensionamiento online
- Encriptación con claves personalizadas

### 4. Storage Classes

**Clase Estándar:**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: oci-bv-standard
provisioner: blockvolume.csi.oraclecloud.com
allowVolumeExpansion: true
parameters:
  vpusPerGB: "10"          # Standard performance
  kmsKeyId: ""              # Oracle-managed encryption
  perfomanceBasedSnapshots: "true"
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
```

**Clase Alta Rendimiento:**
```yaml
metadata:
  name: oci-bv-high-performance
parameters:
  vpusPerGB: "60"           # Premium performance
  perfomanceBasedSnapshots: "true"
```

### 5. Persistent Volumes y Claims

**Estructura de Storage:**
```
┌─────────────────────────┐
│  PersistentVolumeClaim  │
│  (50 GB solicitados)    │
└────────────┬────────────┘
             │ (vincula)
┌────────────▼────────────┐
│ PersistentVolume        │
│ (50 GB asignados)       │
└────────────┬────────────┘
             │ (usa)
┌────────────▼────────────┐
│ OCI Block Volume        │
│ (100 GB en OCI)         │
│ VPUs: 1000 (10/GB)      │
└─────────────────────────┘
```

**Ejemplo de PVC:**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: database-pvc
  namespace: databases
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: oci-bv-standard
  resources:
    requests:
      storage: 100Gi
```

### 6. Snapshots de Volumen

**VolumeSnapshot:**
```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: database-backup-daily
  namespace: databases
spec:
  volumeSnapshotClassName: csi-oci-bv-snapclass
  source:
    persistentVolumeClaimName: database-pvc
```

**Clonación desde Snapshot:**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: database-clone
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: oci-bv-standard
  dataSource:
    name: database-backup-daily
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
  resources:
    requests:
      storage: 100Gi
```

### 7. Backups Automáticos

**Política de Backups:**
```
Cronograma: Diario a las 2:00 AM UTC
Retención: 30 días
Tipo: Full backup diario
Destino: OCI Object Storage (automático)
```

**Configuración del Volumen:**
```yaml
# En el volumen de OCI
backup_policy:
  backup_type: "INCREMENTAL"
  schedule: "DAILY"
  retention_days: 30
  timezone: "UTC"
  backup_window: "02:00-04:00"
```

### 8. Replicación Cross-AD

**Mecanismo:**
```
Primary Volume (AD-1)
         │
         ├─► Replica (AD-2) [RPO < 1 min]
         │
         └─► Replica (AD-3) [RPO < 1 min]

Failover: Automático (si está habilitado)
o Manual (mediante API/Terraform)
```

**Configuración:**
```yaml
parameters:
  replicationType: "BLOCK"  # BLOCK replication
  sourceVolumeReplicas: "2" # Cantidad de réplicas
```

### 9. Encriptación

**Encriptación at-Rest:**
- **OCI-Managed Keys**: Oracle gestiona las claves (gratis)
- **Customer-Managed Keys**: Usar OCI Vault (costo adicional)

```yaml
# Con OCI Vault (Customer-Managed)
apiVersion: v1
kind: StorageClass
metadata:
  name: oci-bv-encrypted
parameters:
  kmsKeyId: "ocid1.key.oc1.sa-santiago-1..."
  perfomanceBasedSnapshots: "true"
```

## Performance Tiers

| VPUs/GB | Tipo | Caso de Uso | Costo Aproximado |
|---------|------|------------|------------------|
| **10** | Standard | Archivos, backups, general | Bajo |
| **20** | High Perf | Aplicaciones normales | Medio |
| **30** | Higher Perf | Bases de datos OLTP | Medio-Alto |
| **40** | Premium | Heavy OLTP, Data Warehouse | Alto |
| **60** | Maximum | Banca, Trading, Analytics | Muy Alto |

**Cálculo de Performance:**
```
Capacidad IOPS = Tamaño (GB) × VPUs/GB
Throughput (MB/s) = min(tamaño (GB) × VPUs/GB × 0.06, 1040)

Ejemplo (100 GB, 20 VPUs/GB):
IOPS = 100 × 20 = 2000 IOPS
Throughput = 100 × 20 × 0.06 = 120 MB/s
```

## Guía de Instalación

### Requisitos Previos

1. Acceso a OCI con credenciales API
2. Terraform >= 1.5.0
3. kubectl >= 1.26
4. Helm >= 3.12 (para CSI driver)

### Paso 1: Preparar Variables

```bash
cp terraform.tfvars.example terraform.tfvars

# Editar valores
vi terraform.tfvars
```

### Paso 2: Crear Infraestructura

```bash
terraform init -backend-config="bucket=my-tf-state" \
               -backend-config="key=oke/block-storage/terraform.tfstate"

terraform validate && terraform plan -out=tfplan
terraform apply tfplan

# Obtener kubeconfig
oci ce cluster create-kubeconfig \
  --cluster-id $(terraform output -raw cluster_id) \
  --file ~/.kube/oke-config
export KUBECONFIG=~/.kube/oke-config
```

### Paso 3: Verificar Instalación

```bash
# Verificar CSI driver instalado
kubectl get pods -n kube-system | grep csi

# Verificar StorageClass
kubectl get storageclass

# Crear PVC de prueba
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: oci-bv-standard
  resources:
    requests:
      storage: 50Gi
EOF

# Esperar a que se provisione
kubectl get pvc -w
```

### Paso 4: Desplegar Aplicación Stateful

```yaml
# mysql-deployment.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: oci-bv-standard
  resources:
    requests:
      storage: 100Gi
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: mysql
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-data
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-data
        persistentVolumeClaim:
          claimName: mysql-pvc
  volumeClaimTemplates:
  - metadata:
      name: mysql-data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: oci-bv-standard
      resources:
        requests:
          storage: 100Gi
```

```bash
kubectl apply -f mysql-deployment.yaml
kubectl get statefulsets
```

## Operaciones Comunes

### Crear Snapshot

```bash
# Crear snapshot
kubectl apply -f - <<EOF
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: mysql-daily-$(date +%Y%m%d)
spec:
  volumeSnapshotClassName: csi-oci-bv-snapclass
  source:
    persistentVolumeClaimName: mysql-pvc
EOF

# Listar snapshots
kubectl get volumesnapshot
```

### Clonar Volumen

```bash
# Clonar desde snapshot
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-clone
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: oci-bv-standard
  dataSource:
    name: mysql-daily-20260412
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
  resources:
    requests:
      storage: 100Gi
EOF
```

### Expandir Volumen

```bash
# Los volúmenes de OCI permiten expansión online
kubectl patch pvc mysql-pvc -p '{"spec":{"resources":{"requests":{"storage":"200Gi"}}}}'

# En la pod, el filesystem se expande automáticamente
# (para algunos filesystems como ext4, requiere intervención manual)
```

### Ver Métricas de Performance

```bash
# Ver performance actual en OCI
oci bv volume get --volume-id <VOLUME_ID> \
  --query 'data.[id, size_in_gbs, vpus_per_gb, lifecycle_state]'

# Ver uso de IOPS y throughput
oci monitoring metric-data summarize \
  --namespace "oci_blockvolume" \
  --metric-name "VolumeOpsPerSecond" \
  --dimensions '[{"name":"volumeId","value":"<VOLUME_ID>"}]' \
  --statistics '["Sum"]'
```

## Troubleshooting

### PVC Stuck en Pending

```bash
# 1. Ver eventos
kubectl describe pvc mysql-pvc

# 2. Ver logs del CSI provisioner
kubectl logs -n kube-system -l app=csi-provisioner --tail=100

# 3. Verificar quotas
oci limits resource-availability get --service-name bv
```

### Volume Attachment Failed

```bash
# 1. Verificar que el nodo está listo
kubectl get nodes -o wide

# 2. Ver logs del node-driver
kubectl logs -n kube-system -l app=csi-node-driver --tail=100 \
  --previous  # para logs del crash anterior

# 3. Reiniciar CSI daemon en nodo
kubectl delete pods -n kube-system -l app=csi-node-driver \
  --field-selector spec.nodeName=<NODE_NAME>
```

### Snapshot Stuck en Pending

```bash
# 1. Ver eventos del snapshot
kubectl describe volumesnapshot mysql-daily-20260412

# 2. Verificar capacidad disponible de snapshots
oci bv volume-backup-policy get --volume-id <ID>
```

## Optimizaciones para Producción

### 1. Separate I/O y Data

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: database
spec:
  containers:
  - name: mysql
    volumeMounts:
    - name: data
      mountPath: /var/lib/mysql
    - name: logs
      mountPath: /var/log/mysql
    - name: cache
      mountPath: /dev/shm
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: mysql-data-pvc  # Storage estándar
  - name: logs
    persistentVolumeClaim:
      claimName: mysql-logs-pvc  # Storage high-perf
  - name: cache
    emptyDir: {}  # tmpfs
```

### 2. Pod Disruption Budget

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: mysql-pdb
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: mysql
```

### 3. Resource Requests

```yaml
spec:
  containers:
  - name: mysql
    resources:
      requests:
        memory: "4Gi"
        cpu: "2"
      limits:
        memory: "8Gi"
        cpu: "4"
```

## Costos Estimados (Mensual - Santiago)

| Recurso | Cantidad | Costo |
|---------|----------|--------|
| OKE Cluster | 1 | Gratis |
| Nodos (3 × E4.Flex) | 3 × (2 OCPU, 8GB) | ~$180 |
| Block Volume 100GB @10 VPUs | 3 | ~$30 |
| Snapshots (30 diarios) | 30 | ~$5 |
| Backups | Incluido | Gratis |
| **Total Aproximado** | | **~$215** |

## Recursos Adicionales

- [OCI Block Volume](https://docs.oracle.com/en-us/iaas/Content/Block/home.htm)
- [OKE CSI Driver](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengcreatingpersistentvolumeclaim.htm)
- [Kubernetes Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [Kubernetes Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/)

---

**Última actualización**: 2026-04-12  
**Versión**: 1.0.0  
**Mantenedor**: Cloud Architecture Team
