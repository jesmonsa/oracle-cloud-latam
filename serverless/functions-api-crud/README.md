# OCI Functions - REST API CRUD

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-623CE4?logo=terraform)](https://www.terraform.io/downloads.html)
[![OCI Provider](https://img.shields.io/badge/OCI%20Provider-6.0+-F80000?logo=oracle)](https://registry.terraform.io/providers/oracle/oci/latest)
[![API Gateway](https://img.shields.io/badge/OCI%20API%20Gateway-Supported-green?logo=oracle)](https://www.oracle.com/cloud/api-gateway/)

## Descripción

Arquitectura **serverless empresarial** que implementa una REST API completa con operaciones CRUD integrada con Oracle Autonomous Database. Ideal para aplicaciones de gestión de datos, catálogos de productos, CRM y portales administrativos.

### Características

✓ REST API con métodos GET, POST, PUT, DELETE
✓ OCI Functions escalables automáticamente
✓ Autonomous Database Always-Free incluido
✓ Autenticación con API Keys y JWT
✓ Documentación Swagger/OpenAPI
✓ Validación de datos con schema
✓ Paginación y filtrado
✓ Transacciones ACID garantizadas
✓ Backup automático diario
✓ Disaster Recovery automático

---

## Topología

```
                      CLIENTES HTTP
                           │
            ┌──────────────┴──────────────┐
            │                             │
        ┌───▼──────────┐          ┌──────▼────────┐
        │ API Gateway  │          │  Rate Limiter │
        │ (Validación) │          │  & Throttling │
        └───┬──────────┘          └──────┬────────┘
            │                             │
        ┌───▼─────────────────────────────▼────┐
        │     OCI Functions (Node.js/Python)    │
        │  - GET /items      (List all)        │
        │  - GET /items/:id  (Get by ID)       │
        │  - POST /items     (Create)          │
        │  - PUT /items/:id  (Update)          │
        │  - DELETE /items/:id (Delete)        │
        └───┬──────────────────────────────────┘
            │
        ┌───▼──────────────────────────┐
        │  Autonomous Database (Always  │
        │  Free 20GB or Flex)          │
        │  - ACID Transactions         │
        │  - Automatic Backup          │
        │  - DRI replication           │
        └──────────────────────────────┘
```

---

## Componentes

| Componente | Tipo | Descripción | Costo |
|-----------|------|-------------|--------|
| **Functions Application** | OCI Functions | Contenedor serverless | Incluido |
| **Functions (CRUD)** | OCI Functions | 5 funciones Node.js | 1M gratis/mes |
| **API Gateway** | API Gateway | REST endpoint con auth | USD 3.65/mes |
| **Autonomous Database** | ADB | 20GB siempre gratis | USD 0.00 |
| **VCN/Networking** | Networking | Red virtual aislada | Gratis |
| **Object Storage** | Storage | Backups automáticos | USD 0.026/mes |
| **Logging** | Logging | Auditoría completa | Primeros 10GB gratis |

**Costo Total Estimado**: USD 3.70/mes (sin excedentes)

---

## Componentes de Arquitectura

### Database Schema

```sql
CREATE TABLE items (
  id NUMBER PRIMARY KEY,
  name VARCHAR2(255) NOT NULL,
  description CLOB,
  price NUMBER(10,2),
  quantity NUMBER,
  status VARCHAR2(50) DEFAULT 'ACTIVE',
  created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
  updated_at TIMESTAMP DEFAULT SYSTIMESTAMP,
  created_by VARCHAR2(255),
  updated_by VARCHAR2(255)
);

CREATE INDEX idx_items_status ON items(status);
CREATE INDEX idx_items_created_at ON items(created_at);
```

### API Endpoints

```
GET    /items              # Listar todos los items (paginado)
GET    /items/:id          # Obtener item específico
POST   /items              # Crear nuevo item
PUT    /items/:id          # Actualizar item existente
DELETE /items/:id          # Eliminar item
GET    /items/search       # Búsqueda avanzada
```

### Request/Response Examples

**GET /items** (Listar con paginación)
```json
// Request
GET /items?page=1&limit=10&status=ACTIVE

// Response 200
{
  "data": [
    {
      "id": 1,
      "name": "Producto A",
      "description": "...",
      "price": 99.99,
      "quantity": 50,
      "status": "ACTIVE",
      "created_at": "2026-04-12T10:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 150,
    "pages": 15
  }
}
```

**POST /items** (Crear)
```json
// Request
POST /items
Content-Type: application/json

{
  "name": "Nuevo Producto",
  "description": "Descripción detallada",
  "price": 199.99,
  "quantity": 100,
  "status": "ACTIVE"
}

// Response 201
{
  "id": 151,
  "name": "Nuevo Producto",
  "status": "ACTIVE",
  "created_at": "2026-04-12T10:35:00Z"
}
```

**PUT /items/:id** (Actualizar)
```json
// Request
PUT /items/151
Content-Type: application/json

{
  "name": "Producto Actualizado",
  "price": 249.99,
  "quantity": 75
}

// Response 200
{
  "id": 151,
  "name": "Producto Actualizado",
  "price": 249.99,
  "updated_at": "2026-04-12T10:40:00Z"
}
```

---

## Variables Principales

```hcl
variable "database_version" {
  description = "Versión de Autonomous Database"
  type        = string
  default     = "21c"
  validation {
    condition     = contains(["19c", "21c", "23c"], var.database_version)
    error_message = "Debe ser 19c, 21c o 23c"
  }
}

variable "database_admin_password" {
  description = "Contraseña admin de la base de datos"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.database_admin_password) >= 12
    error_message = "Debe tener al menos 12 caracteres"
  }
}

variable "database_workload_type" {
  description = "Tipo de carga de trabajo"
  type        = string
  default     = "OLTP"
  validation {
    condition     = contains(["OLTP", "DW"], var.database_workload_type)
    error_message = "Debe ser OLTP o DW"
  }
}

variable "enable_auto_backup" {
  description = "Habilitar backups automáticos"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Días de retención de backups"
  type        = number
  default     = 30
  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 60
    error_message = "Debe estar entre 1 y 60 días"
  }
}
```

---

## Instalación

### Paso 1: Variables

```bash
cp terraform.tfvars.example terraform.tfvars
# Editar con credenciales OCI
```

### Paso 2: Inicializar

```bash
terraform init
terraform plan
```

### Paso 3: Desplegar

```bash
terraform apply

# Esperar 10-15 minutos para ADB
```

### Paso 4: Obtener credenciales

```bash
terraform output database_connection_string
terraform output api_endpoint
terraform output admin_user
```

---

## Uso

### Conectarse a la Base de Datos

```bash
# Descargar wallet
oci db autonomous-database get-wallet \
  --autonomous-database-id <adb-id> \
  --file ~/wallet.zip

# Conectar con sqlplus
sqlplus admin@<db_name>_medium
```

### Probar API

```bash
# Variables
API=$(terraform output -raw api_endpoint)
AUTH_KEY=$(terraform output -raw api_auth_key)

# GET
curl -H "Authorization: Bearer $AUTH_KEY" \
  "$API/items?page=1&limit=10"

# POST
curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer $AUTH_KEY" \
  -d '{"name":"Test","price":99.99}' \
  "$API/items"

# PUT
curl -X PUT -H "Content-Type: application/json" \
  -H "Authorization: Bearer $AUTH_KEY" \
  -d '{"price":149.99}' \
  "$API/items/1"

# DELETE
curl -X DELETE \
  -H "Authorization: Bearer $AUTH_KEY" \
  "$API/items/1"
```

---

## Estimación de Costos

### Escenario: 100K requests/mes, 500 items

```
Autonomous Database (Always Free):  USD 0.00
  - Máximo: 20 GB storage
  - Máximo: 1 OCPU

API Gateway:                         USD 3.65/mes
  - Incluido: 100K requests/mes
  - Próximos 100K: USD 0.01 cada uno

Functions:                           USD 0.00
  - Primeras 1M invocaciones gratis
  - Típicamente 1-5 invocaciones por request

Logging/Monitoring:                  USD 0.00
  - Primeros 10 GB/mes gratis

TOTAL:                               USD 3.65/mes
```

---

## Troubleshooting

### Problema: Conexión a ADB rechazada

```bash
# Solución:
# 1. Verificar que función tiene permisos
oci db autonomous-database list --compartment-id <id>

# 2. Recrear wallet
oci db autonomous-database get-wallet \
  --autonomous-database-id <adb-id> \
  --file ~/wallet.zip
```

### Problema: Queries lentas

```bash
# Analizar planes de ejecución
EXPLAIN PLAN FOR SELECT * FROM items WHERE status='ACTIVE';

# Crear índices adicionales
CREATE INDEX idx_items_price ON items(price);
```

### Problema: API retorna 500

```bash
# Ver logs
oci logging-search search-logs \
  --log-group-id <id> \
  --search-query 'severity=ERROR'
```

---

## Seguridad

✓ Autenticación JWT
✓ Validación de entrada
✓ SQL Injection prevención
✓ Rate limiting (100 req/min)
✓ CORS configurado
✓ HTTPS obligatorio (TLS 1.2+)
✓ Encriptación de datos en tránsito y en reposo

---

## Monitoreo

Métricas disponibles:
- Invocaciones de API/segundo
- Latencia p50, p95, p99
- Errores 4xx y 5xx
- Conexiones activas a BD
- Uso de almacenamiento
- Transacciones/segundo

---

## Mantenimiento

```bash
# Reindex de base de datos
ALTER INDEX idx_items_status REBUILD;

# Estadísticas de tabla
ANALYZE TABLE items COMPUTE STATISTICS;

# Backup manual
oci db autonomous-database create-backup \
  --autonomous-database-id <id> \
  --backup-display-name manual-backup
```

---

## Documentación Relacionada

- [OCI Autonomous Database](https://docs.oracle.com/en-us/iaas/Content/Database/home.htm)
- [OCI Functions Node.js SDK](https://docs.oracle.com/en-us/iaas/Content/Functions/Tasks/functionsconfiguringcoderespository.htm)
- [REST API Best Practices](https://docs.oracle.com/en-us/iaas/Content/APIGateway/home.htm)

---

## Licencia

UPL 1.0 - Oracle Universal Permissive License
