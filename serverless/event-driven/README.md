# OCI Functions - Arquitectura Orientada a Eventos

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-623CE4?logo=terraform)](https://www.terraform.io/downloads.html)
[![OCI Provider](https://img.shields.io/badge/OCI%20Provider-6.0+-F80000?logo=oracle)](https://registry.terraform.io/providers/oracle/oci/latest)
[![Events Service](https://img.shields.io/badge/OCI%20Events-Supported-green?logo=oracle)](https://www.oracle.com/cloud/events/)

## Descripción

Arquitectura **event-driven** que utiliza OCI Events Service para disparar automáticamente funciones serverless en respuesta a cambios en otros servicios OCI. Ideal para procesamiento asincrónico, integraciones complejas y flujos de trabajo automatizados.

### Características

✓ Events Service nativamente integrado
✓ Múltiples fuentes de eventos (Object Storage, DB, IAM, etc)
✓ Funciones encadenadas y composables
✓ Dead Letter Queue para manejo de errores
✓ Retry automático con backoff exponencial
✓ Auditoría y trazabilidad completa
✓ Notificaciones por Email/SMS
✓ Dashboard de monitoreo

---

## Topología

```
┌────────────────────────────────────────────────────────────┐
│                    FUENTES DE EVENTOS                      │
├────────────────────────────────────────────────────────────┤
│ Object Storage │ Database │ Instance │ Network │ IAM │ API │
└───────────────┬────────────────────────────────────────────┘
                │ (events-filter-rule)
                ▼
        ┌──────────────────┐
        │  Events Service  │
        │  (Event Router)  │
        └────┬─────────┬──────┬────────┐
             │         │      │        │
    ┌────────▼──┐ ┌───▼────┐ │   ┌────▼─────────┐
    │  Function │ │Function│ │   │  SNS Topic   │
    │  Handler1 │ │Handler2│ │   │(Notificaciones)
    │(Process)  │ │(Store) │ │   └──────────────┘
    └────┬──────┘ └───┬────┘ │
         │            │      │
    ┌────▼──────────────▼──┐ │
    │  Object Storage      │ │
    │  (Processed Data)    │ │
    └─────────────────────┘ │
                            │
                    ┌───────▼────────┐
                    │ Dead Letter    │
                    │ Queue (DLQ)    │
                    │(Errores)       │
                    └────────────────┘
```

---

## Componentes

| Componente | Tipo | Descripción | Costo |
|-----------|------|-------------|--------|
| **Events Service** | Events | Event routing centralizado | Gratis |
| **Event Rules** | Events | 5-10 reglas de eventos | Gratis |
| **Functions** | OCI Functions | 2-3 funciones handler | 1M gratis/mes |
| **SNS Topic** | Notifications | Notificaciones por email | USD 0.00 (primeras 1K) |
| **Object Storage** | Storage | Almacenamiento de resultados | USD 0.026/mes |
| **Logging** | Logging | Auditoría y logs | Primeros 10GB gratis |

**Costo Total Estimado**: USD 0.50/mes

---

## Flujo de Eventos

### Ejemplo 1: Procesamiento de Archivos

```
1. Usuario sube archivo a Object Storage
   ↓
2. Events Service detecta evento "ObjectCreated"
   ↓
3. Event Rule router a función "process-image"
   ↓
4. Función procesa imagen (redimensiona, comprime)
   ↓
5. Guarda resultado en Object Storage
   ↓
6. Notifica a usuario vía email
   ↓
7. Si hay error → almacena en DLQ para reintentar
```

### Ejemplo 2: Sincronización de Datos

```
1. Se inserta/actualiza registro en Autonomous Database
   ↓
2. Events Service dispara "DBActivity"
   ↓
3. Event Rule activa función "sync-cache"
   ↓
4. Función invalida caché y refresca datos
   ↓
5. Confirma sincronización en Elasticsearch
```

---

## Casos de Uso

| Caso de Uso | Fuente | Función | Destino |
|-------------|--------|---------|---------|
| **Procesamiento de imágenes** | Object Storage | Resize/Compress | Object Storage |
| **Sincronización caché** | Autonomous DB | Invalidate | Redis/Memcached |
| **Generación de reportes** | Scheduler (CRON) | Report Gen | Email/Slack |
| **Auditoría de seguridad** | IAM Events | Log Filter | SIEM |
| **Auto-scaling** | Metrics | Scale Decision | Compute |
| **Validación de datos** | API Gateway | Data Validate | Database |

---

## Variables Principales

```hcl
variable "event_sources" {
  description = "Fuentes de eventos a monitorear"
  type        = list(string)
  default     = ["object-storage", "database", "compute"]
  
  validation {
    condition = alltrue([
      for source in var.event_sources : contains(
        ["object-storage", "database", "compute", "network", "identity"],
        source
      )
    ])
    error_message = "Fuentes válidas: object-storage, database, compute, network, identity"
  }
}

variable "enable_dlq" {
  description = "Habilitar Dead Letter Queue"
  type        = bool
  default     = true
}

variable "max_retries" {
  description = "Número máximo de reintentos"
  type        = number
  default     = 3
  
  validation {
    condition     = var.max_retries >= 1 && var.max_retries <= 10
    error_message = "Debe estar entre 1 y 10"
  }
}

variable "event_batch_size" {
  description = "Tamaño de lote para procesamiento"
  type        = number
  default     = 10
}
```

---

## Instalación

```bash
cd serverless/event-driven
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

---

## Uso

### Disparar evento manual

```bash
# Publicar evento personalizado
oci events event put-events \
  --entries '[
    {
      "eventTime": "2026-04-12T10:30:00Z",
      "eventType": "com.example.process",
      "source": "custom.application",
      "data": {
        "item_id": "123",
        "action": "created"
      }
    }
  ]'
```

### Ver eventos procesados

```bash
# Ver logs
oci logging-search search-logs \
  --log-group-id <log-group-id> \
  --search-query 'eventType="ObjectCreated"'
```

### Monitorear DLQ

```bash
# Ver mensajes en Dead Letter Queue
oci queue messages get \
  --queue-id <dlq-queue-id> \
  --limit 10
```

---

## Estimación de Costos

### Scenario: 100K eventos/mes, 30% error rate

```
Events Service:              USD 0.00 (gratis)
Functions (100K invoc):      USD 0.00 (dentro de 1M)
Object Storage (100GB):      USD 2.60
SNS Notificaciones (100):    USD 0.00
Logging (500MB):             USD 0.00 (dentro de 10GB)

TOTAL:                        USD 2.60/mes
```

---

## Troubleshooting

### Evento no se dispara

```bash
# 1. Verificar que event rule está active
oci events rule list --compartment-id <id>

# 2. Verificar que función está ACTIVE
oci functions function list --application-id <app-id>

# 3. Ver logs de rule
oci logging-search search-logs --search-query 'ruleName="my-rule"'
```

### Función falla silenciosamente

```bash
# 1. Ver logs de función
oci functions function list-call-logs --function-id <id>

# 2. Ver mensaje de DLQ
oci queue messages get --queue-id <dlq-id>

# 3. Verificar IAM permissions
oci iam policy list --compartment-id <id>
```

---

## Seguridad

✓ Event filtering por tipo y origen
✓ Autenticación JWT para eventos custom
✓ Logging completo de auditoría
✓ Encriptación en tránsito (TLS)
✓ IAM roles con principio de menor privilegio
✓ DLQ para capturar errores y auditar

---

## Monitoreo

Métricas disponibles:
- Eventos procesados/segundo
- Latencia de procesamiento (p50, p95, p99)
- Tasa de error
- Mensajes en DLQ
- Reintentos ejecutados

---

## Mantenimiento

```bash
# Limpieza de eventos antiguos (archivado automático)
# OCI Archive: Los eventos se mantienen 7 días en logs

# Purgar DLQ manualmente
oci queue messages delete --queue-id <dlq-id>

# Actualizar event rule
oci events rule update \
  --rule-id <rule-id> \
  --actions '[...]'
```

---

## Documentación Relacionada

- [OCI Events Service](https://docs.oracle.com/en-us/iaas/Content/Events/home.htm)
- [Event Types Reference](https://docs.oracle.com/en-us/iaas/Content/Events/Reference/eventtypes.htm)
- [OCI Notifications](https://docs.oracle.com/en-us/iaas/Content/Notification/home.htm)

---

## Licencia

UPL 1.0 - Oracle Universal Permissive License
