# OCI NoSQL Database - Arquitectura de Referencia

[![Oracle Cloud](https://img.shields.io/badge/OCI-NoSQL_Database-FF6B35?style=for-the-badge&logo=oracle)](https://www.oracle.com/database/nosql/)
[![Terraform](https://img.shields.io/badge/Terraform-1.0+-623CE4?style=for-the-badge&logo=terraform)](https://www.terraform.io/)
[![Estado: Producción](https://img.shields.io/badge/Estado-Producci%C3%B3n-28A745?style=for-the-badge)](#)

## Descripción General

OCI NoSQL Database es un almacenamiento clave-valor completamente administrado para:

- **Alta Throughput**: Millones de operaciones/segundo
- **On-Demand Pricing**: Pagar solo por lo que usas
- **Global Distribution**: Multi-region replication (opcional)
- **Flexible Schema**: JSON documents con índices dinámicos
- **Integración OCI**: IAM, Monitoring, Backup integrados
- **TTL Support**: Expiración automática de datos
- **Encryption**: En reposo y en tránsito

## Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────────┐
│                    OCI Region (LATAM)                           │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │           OCI NoSQL Database Service                     │   │
│  │                                                          │   │
│  │  ┌──────────────────────────────────────────────────┐   │   │
│  │  │  NoSQL Tables (JSON Documents)                   │   │   │
│  │  │                                                  │   │   │
│  │  │  Table: Users                                   │   │   │
│  │  │  • Key: user_id (STRING)                       │   │   │
│  │  │  • JSON: {name, email, created_at}            │   │   │
│  │  │  • TTL: 7 dias (optional)                       │   │   │
│  │  │  • Indexes: email, created_at                  │   │   │
│  │  │  • Capacity: On-Demand                         │   │   │
│  │  │                                                  │   │   │
│  │  │  Table: Sessions                               │   │   │
│  │  │  • Key: session_id (STRING)                    │   │   │
│  │  │  • TTL: 1 hora (sessions expire)               │   │   │
│  │  │                                                  │   │   │
│  │  │  Table: Analytics                              │   │   │
│  │  │  • Key: date#user_id (COMPOSITE)               │   │   │
│  │  │  • Capacity: Fixed (1000 RU/WU)                │   │   │
│  │  │                                                  │   │   │
│  │  │  Replication (opcional):                        │   │   │
│  │  │  • Region local: Sao Paulo                     │   │   │
│  │  │  • Region remota: Montreal                     │   │   │
│  │  │  • Sincronización: Automática                  │   │   │
│  │  └──────────────────────────────────────────────────┘   │   │
│  │                                                          │   │
│  │  Access Control:                                        │   │
│  │  • OCI IAM Policies (user roles)                       │   │
│  │  • Resource-based Access Control                       │   │
│  │  • API Keys para aplicaciones                         │   │
│  │                                                          │   │
│  │  Monitoring:                                            │   │
│  │  • Read/Write Units consumed                           │   │
│  │  • Throttled requests                                  │   │
│  │  • Storage consumed                                     │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
│  Application Instances:                                          │
│  • API Gateway → NoSQL (REST/gRPC)                              │
│  • Java, Python, Node.js SDK                                     │
│  • Connection pooling built-in                                   │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

## Componentes Principales

### 1. NoSQL Tables
- **JSON Storage**: Flexible schema documents
- **Capacity Modes**:
  - On-Demand: Pagar por uso real (recomendado para variable)
  - Fixed: Capacity reservada (recomendado para predecible)
- **TTL**: Expiración automática de records
- **Indexes**: Crear índices en campos JSON

### 2. Replication (Opcional)
- **Multi-Region**: Sincronización automática
- **Eventual Consistency**: Default
- **Strong Consistency**: Opción disponible

### 3. Security
- **Encryption at Rest**: OCI KMS
- **Encryption in Transit**: TLS 1.2+
- **IAM Policies**: Role-based access
- **Audit Logging**: Todos los accesos

### 4. Monitoring
- **OCI Monitoring**: Métricas de RU/WU
- **Throttling Alerts**: Cuando capacidad sobrepasada
- **Storage Alerts**: Cuando se acerca límite

## Variables de Configuración

```hcl
# Ubicación
region         = "sa-saopaulo-1"
compartment_id = "ocid1.compartment.oc1..."

# Tablas NoSQL
tables = {
  users = {
    key_columns = ["user_id"]
    ttl_days    = 0  # Sin expiración
  }
  sessions = {
    key_columns = ["session_id"]
    ttl_days    = 1  # Expira después 1 día
  }
  analytics = {
    key_columns = ["date", "user_id"]  # Composite key
    ttl_days    = 0
  }
}

# Capacity
capacity_mode = "ON_DEMAND"  # O FIXED
fixed_read_units  = 1000
fixed_write_units = 1000

# Replication
enable_replication = false
replica_region     = "ca-montreal-1"
```

## Instalación

```bash
cd datos/nosql
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

## Casos de Uso

### 1. Sessions Store (TTL)
```hcl
sessions = {
  key_columns = ["session_id"]
  ttl_days = 1
  capacity_mode = "ON_DEMAND"
}
```

### 2. User Profiles
```hcl
users = {
  key_columns = ["user_id"]
  ttl_days = 0
  indexes = ["email", "username"]
}
```

### 3. Time Series Data
```hcl
metrics = {
  key_columns = ["timestamp", "metric_id"]
  ttl_days = 30  # Retención 30 días
  capacity_mode = "FIXED"
  read_units = 5000
  write_units = 5000
}
```

## Estimación de Costos

### On-Demand (Variable)
- **Read**: USD $0.00028 / 1K read units
- **Write**: USD $0.0014 / 1K write units
- **Storage**: USD $0.004 / GB/mes

**Ejemplo**: 1M reads + 100K writes + 100GB storage/mes
```
Reads: (1,000,000 / 1,000) × $0.00028 = $0.28
Writes: (100,000 / 1,000) × $0.0014 = $0.14
Storage: 100 × $0.004 = $0.40
Total: ~$0.82/mes
```

### Fixed Capacity
- **Provisioned**: USD $0.0048 / hour per 100 RU
- **Provisioned**: USD $0.024 / hour per 100 WU

**Ejemplo**: 1000 RU + 1000 WU
```
RU: (1000/100) × $0.0048 × 730h = $35.04/mes
WU: (1000/100) × $0.024 × 730h = $175.20/mes
Storage: Variable ($0.004/GB/mes)
Total: ~$210+ /mes
```

## API & SDKs

### REST API
```bash
curl -X POST https://nosql.region.oraclecloud.com/20223 \
  -H "Authorization: Bearer $TOKEN" \
  -d @table-row.json
```

### Java SDK
```java
NoSQLClient client = new NoSQLClient(region);
TableRequest req = new TableRequest()
  .setTableName("users")
  .setRow(mapToRow(userData));
TableResult res = client.tableRequest(req);
```

### Python SDK
```python
from oci.nosql import NoSQLClient
client = NoSQLClient(config)
request = operations.PutRequest(
  table_name='users',
  item={'user_id': '123', 'name': 'John'}
)
response = client.put(request)
```

## Mejores Prácticas

### Diseño de Schema
- Usar composite keys para range queries
- Crear índices en columnas frecuentemente buscadas
- Mantener documentos < 400 KB

### Performance
- Usar batch operations cuando sea posible
- Implementar connection pooling
- Monitorear RU/WU consumption

### Costo
- Usar On-Demand para cargas variables
- Fixed Capacity para cargas predecibles
- TTL para limpiar datos automáticamente
- Evaluar necesidad de multi-region

## Troubleshooting

### Problema: Throttling (429)
**Solución**:
1. Aumentar capacity (RU/WU)
2. Optimizar queries para menos lecturas
3. Considerar Fixed Capacity si predecible

### Problema: Datos inconsistentes entre regiones
**Solución**:
1. Usar Strong Consistency si crítico
2. Esperar propagación (usually < 1s)
3. Monitorear replication lag

### Problema: Storage Limit Exceeded
**Solución**:
1. Implementar TTL para limpiar automáticamente
2. Purgar datos antiguos manualmente
3. Mover datos a archival storage

## Documentación

- [OCI NoSQL Database Docs](https://docs.oracle.com/en-us/iaas/Content/NoSQL/Concepts/nosqldb.htm)
- [NoSQL Java SDK](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/java.htm)
- [Design Best Practices](https://docs.oracle.com/en-us/iaas/nosql-database/doc/designing-tables.html)

**Versión**: 1.0.0 | **Status**: Producción ✓
