# MySQL HeatWave - Arquitectura de Referencia OCI

[![Oracle Cloud](https://img.shields.io/badge/OCI-MySQL_HeatWave-FF6B35?style=for-the-badge&logo=oracle)](https://www.oracle.com/mysql/)
[![Terraform](https://img.shields.io/badge/Terraform-1.0+-623CE4?style=for-the-badge&logo=terraform)](https://www.terraform.io/)
[![Estado: Producción](https://img.shields.io/badge/Estado-Producci%C3%B3n-28A745?style=for-the-badge)](#)

## Descripción General

MySQL HeatWave en OCI proporciona:

- **Motor Analítico Integrado**: Análisis en tiempo real sin ETL adicional
- **HTAP**: Hybrid Transactional/Analytical Processing
- **Alta Disponibilidad**: Replica Set automático (3 nodos)
- **Acceso Privado**: Private Endpoint en VCN
- **Escalabilidad**: HeatWave Nodes para cargas analíticas
- **Monitoreo Integrado**: OCI Monitoring y MySQL Shell
- **Backup Automático**: Recuperación punto-en-tiempo (PITR)

## Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────────┐
│                    OCI Region (LATAM)                           │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                        VCN                                  │ │
│  │  ┌──────────────────────────────────────────────────────┐  │ │
│  │  │              Private Subnet                          │  │ │
│  │  │                                                      │  │ │
│  │  │  ┌──────────────────────────────────────────────┐   │  │ │
│  │  │  │  MySQL HeatWave Cluster                     │   │  │ │
│  │  │  │                                              │   │  │ │
│  │  │  │  Primary Node (read/write):                 │   │  │ │
│  │  │  │  • Shape: MySQL.HeatWave.VM.Standard       │   │  │ │
│  │  │  │  • vCPU: 4                                  │   │  │ │
│  │  │  │  • Memory: 32 GB                            │   │  │ │
│  │  │  │  • Storage: 100+ GB                         │   │  │ │
│  │  │  │                                              │   │  │ │
│  │  │  │  Secondary Nodes (replicas):                │   │  │ │
│  │  │  │  • Node 2 & 3: Igual configuración         │   │  │ │
│  │  │  │  • Replicación en tiempo real               │   │  │ │
│  │  │  │  • Failover automático                      │   │  │ │
│  │  │  │                                              │   │  │ │
│  │  │  │  HeatWave Nodes (opcional):                 │   │  │ │
│  │  │  │  • Tipo: MySQL.HeatWave.HeatWave           │   │  │ │
│  │  │  │  • Count: 1-32 nodos                        │   │  │ │
│  │  │  │  • Propósito: Análisis en memoria          │   │  │ │
│  │  │  │                                              │   │  │ │
│  │  │  │  Private Endpoint:                           │   │  │ │
│  │  │  │  • Puerto: 3306 (MySQL)                     │   │  │ │
│  │  │  │  • Hostname: {cluster-name}.mysql.oraclecloud.com   │
│  │  │  │                                              │   │  │ │
│  │  │  └──────────────────────────────────────────────┘   │  │ │
│  │  │                                                      │  │ │
│  │  │  Application Instances:                             │  │ │
│  │  │  • Spring Boot, Java, Python, Node.js              │  │ │
│  │  │  • JDBC/Connector/J para MySQL                     │  │ │
│  │  │  • ORM: Hibernate, SQLAlchemy                       │  │ │
│  │  │                                                      │  │ │
│  │  │  Security:                                          │  │ │
│  │  │  • NSG restricción puerto 3306                     │  │ │
│  │  │  • Encryption TLS para conexiones                 │  │ │
│  │  │  • User/Password authentication                   │  │ │
│  │  └──────────────────────────────────────────────────────┘  │ │
│  │                                                              │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  OCI Services:                                                    │
│  • OCI Backup Service: Backups automáticos                       │
│  • OCI Monitoring: Métricas y dashboards                         │
│  • OCI Logging: Event logs                                       │
│  • OCI Notifications: Alertas SNS                                │
│  • OCI MySQL Heatwave: Servicio administrado                     │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

## Componentes Principales

### 1. MySQL HeatWave Cluster
- **Shape**: MySQL.HeatWave.VM.Standard (4 vCPU, 32 GB RAM)
- **Replica Set**: 3 nodos (HA automático)
- **Storage**: 100+ GB block storage
- **Backup**: Automático, retención configurable

### 2. HeatWave Nodes (Opcional)
- **Shape**: MySQL.HeatWave.HeatWave
- **Count**: 1-32 nodos para análisis en memoria
- **Propósito**: Accelerate OLAP queries

### 3. Private Endpoint
- **Puerto**: 3306 (MySQL estándar)
- **TLS**: Encryption obligatorio
- **Subnet**: Privada (sin IGW)

### 4. Replicación
- **Tipo**: Group Replication
- **Modo**: Automático
- **Failover**: Transparente

## Variables de Configuración

```hcl
# Ubicación
region         = "sa-saopaulo-1"
compartment_id = "ocid1.compartment.oc1..."

# MySQL Database
cluster_name   = "myhw-cluster"
mysql_version  = "8.0"  # o 8.1
admin_user     = "admin"
admin_password = "SecurePass123!@#"

# Capacity
mysql_shape    = "MySQL.HeatWave.VM.Standard"
vpcpu_count    = 4
memory_gb      = 32
storage_gb     = 100

# HeatWave Analytics (opcional)
enable_heatwave = true
heatwave_node_count = 2

# Network
vcn_id  = "ocid1.vcn.oc1..."
subnet_id = "ocid1.subnet.oc1..."

# Backup
backup_retention_days = 30
enable_backup = true
```

## Instalación Paso a Paso

```bash
# 1. Configurar variables
cd datos/mysql-heatwave
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

# 2. Inicializar
terraform init

# 3. Validar
terraform validate

# 4. Planificar
terraform plan -out=tfplan

# 5. Aplicar
terraform apply tfplan

# 6. Obtener información de conexión
terraform output -json > connection-info.json
```

## Conexión

### Con MySQL Shell
```bash
mysqlsh --uri admin@{hostname}:3306
```

### Con MySQL Client
```bash
mysql -h {hostname} -u admin -p {database}
```

### Con JDBC (Java)
```
jdbc:mysql://{hostname}:3306/{database}?useSSL=true&serverTimezone=UTC
```

## Estimación de Costos

- **Primary Node**: USD $0.36/hora (4 vCPU)
- **Secondary Node**: USD $0.36/hora × 2 = USD $0.72/hora
- **HeatWave Node**: USD $1.00/hora
- **Storage**: USD $0.002/GB/día

**Ejemplo (cluster + 2 HW nodes)**:
```
Primary: $0.36 × 730 = $262.80/mes
Secondary: $0.72 × 730 = $525.60/mes
HeatWave: $2.00 × 730 = $1,460/mes
Storage: 100 GB × 30 × $0.002 = $6/mes
Total: ~$2,254.40/mes
```

## Características Clave

### HeatWave Analytics
- Aceleración de queries hasta 1000x
- In-memory processing
- Auto-learning para optimización

### Alta Disponibilidad
- Replicación automática (3 nodos)
- Failover transparente < 30s
- No downtime para mantenimiento

### Seguridad
- TLS 1.2+ obligatorio
- Encryption at rest con OCI KMS
- IAM integration
- VPN/Bastion host support

### Monitoreo
- OCI Monitoring integrado
- Performance Schema
- MySQL Enterprise Monitor
- Query analytics

## Casos de Uso

### 1. E-Commerce HTAP
```hcl
cluster_name     = "ecommerce-cluster"
enable_heatwave  = true
heatwave_nodes   = 4
# Real-time inventory + analytics
```

### 2. BI & Analytics
```hcl
cluster_name     = "analytics-cluster"
enable_heatwave  = true
heatwave_nodes   = 8
mysql_shape      = "MySQL.HeatWave.VM.Standard.E4"
# Large dataset analytics
```

### 3. Development/Testing
```hcl
cluster_name     = "dev-cluster"
enable_heatwave  = false
vpcpu_count      = 2
memory_gb        = 16
# Low cost development
```

## Mejores Prácticas

### Performance
- Usar indexes en columnas frequently searched
- Implementar query caching
- Monitorear slow query log
- Usar HeatWave para queries complejas

### Security
- Cambiar default admin password
- Crear usuarios de aplicación
- Usar SSL/TLS para todas las conexiones
- Implementar row-level security (RLS)

### Backup & Recovery
- Probar restores regularmente
- Usar PITR para punto específico en tiempo
- Retención mínima 30 días
- Backup a múltiples regiones si crítico

### Costo
- Usar Pause Cluster para dev
- HeatWave solo cuando sea necesario
- Monitorear consumo de storage
- Reserved Capacity para prod

## Troubleshooting

### Problema: No puedo conectar
**Solución**:
1. Verificar NSG permite puerto 3306
2. Confirmar subnet tiene ruta correcta
3. Revisar usuario/password

### Problema: Bajo rendimiento
**Solución**:
1. Revisar slow query log
2. Crear índices necesarios
3. Usar EXPLAIN para planes de ejecución
4. Considerar HeatWave para queries complejas

### Problema: Storage lleno
**Solución**:
1. Purgar datos antiguos
2. Comprimir tablas
3. Aumentar storage allocation

## Documentación

- [Oracle MySQL HeatWave Docs](https://docs.oracle.com/en-us/iaas/mysql-database/)
- [MySQL Reference Manual](https://dev.mysql.com/doc/)
- [OCI Terraform MySQL Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/mysql_db_system)

**Versión**: 1.0.0 | **Status**: Producción ✓
