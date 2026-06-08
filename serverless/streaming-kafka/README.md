# OCI Streaming - Kafka Compatible

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-623CE4?logo=terraform)](https://www.terraform.io/downloads.html)
[![OCI Provider](https://img.shields.io/badge/OCI%20Provider-6.0+-F80000?logo=oracle)](https://registry.terraform.io/providers/oracle/oci/latest)
[![Streaming](https://img.shields.io/badge/OCI%20Streaming-Kafka-green?logo=oracle)](https://www.oracle.com/cloud/streaming/)

## Descripción

OCI Streaming es un servicio **Kafka-compatible** completamente administrado que permite construir aplicaciones de **streaming en tiempo real**. Integrado con Functions, permite procesar millones de eventos por segundo sin gestionar infraestructura.

### Características

✓ 100% compatible con Kafka (cliente Kafka estándar)
✓ Producción completamente administrada
✓ Múltiples consumidores con consumer groups
✓ Retención configurable (24h a 7 días)
✓ Replicación automática de 3x
✓ Particiones con ordenamiento garantizado
✓ Integración nativa con Functions
✓ Métricas detalladas por partición

---

## Topología

```
┌──────────────────────────────────┐
│    PRODUCTORES DE DATOS          │
├──────────────────────────────────┤
│ API   │ Logs   │ Sensores │ Apps │
└───────┬─────────────────────┬────┘
        │                     │
        ▼                     ▼
    ┌─────────────────────────────────┐
    │   OCI STREAMING (Kafka)         │
    ├─────────────────────────────────┤
    │ Topic: events                   │
    │  ├─ Partition 0                 │
    │  ├─ Partition 1                 │
    │  └─ Partition 2                 │
    │                                 │
    │ Topic: transactions             │
    │  ├─ Partition 0                 │
    │  └─ Partition 1                 │
    └─────────────────────────────────┘
            │         │         │
    ┌───────▼───┐ ┌──▼──────┐ ┌▼──────────┐
    │ Consumer  │ │Consumer │ │Consumer   │
    │Functions │ │Functions│ │Functions  │
    │(Process) │ │(Alert)  │ │(Archive)  │
    └───────┬───┘ └──┬──────┘ └┬──────────┘
            │        │         │
    ┌───────▼────────▼─────────▼────┐
    │  DESTINOS                      │
    ├────────────────────────────────┤
    │ ADB  │ ES  │ Object Storage   │
    │ Data Warehouse Analytics       │
    └────────────────────────────────┘
```

---

## Componentes

| Componente | Tipo | Descripción | Costo |
|-----------|------|-------------|--------|
| **Streaming (Kafka)** | Streaming | Stream topics | USD 50-200/mes (por throughput) |
| **Stream Partition** | Streaming | 1 partición = 1MB/s entrada | Incluido |
| **Consumer Functions** | Functions | Consumers escalables | 1M gratis/mes |
| **Object Storage** | Storage | Archival de datos | USD 0.026/GB/mes |
| **Autonomous DB** | Database | Warehouse para analytics | Always-Free 20GB |

**Costo Total Estimado**: USD 50-300/mes (según volumen)

---

## Casos de Uso

| Caso de Uso | Productor | Topic | Consumer |
|-------------|-----------|-------|----------|
| **Log Streaming** | App logs | logs | Archive to Storage |
| **Real-time Analytics** | Events | events | Stream to ADB |
| **IoT Data** | Sensores | metrics | Process & Alert |
| **Financial Transactions** | Payment API | transactions | Risk Detection |
| **Social Media** | Posts | feed | ML Model Inference |

---

## Stream Topics Schema

### Topic: events

```json
{
  "event_id": "uuid",
  "timestamp": "2026-04-12T10:30:45Z",
  "source": "mobile-app|web|api",
  "event_type": "user_login|purchase|view",
  "user_id": "user123",
  "metadata": {
    "ip": "192.168.1.1",
    "device": "mobile",
    "session_id": "sess456"
  }
}
```

### Topic: transactions

```json
{
  "transaction_id": "txn789",
  "timestamp": "2026-04-12T10:30:45Z",
  "amount": 99.99,
  "currency": "USD",
  "user_id": "user123",
  "merchant_id": "merchant456",
  "status": "completed|pending|failed"
}
```

---

## Variables Principales

```hcl
variable "num_partitions" {
  description = "Número de particiones en stream"
  type        = number
  default     = 3
  
  validation {
    condition     = var.num_partitions >= 1 && var.num_partitions <= 32
    error_message = "Debe estar entre 1 y 32"
  }
}

variable "retention_hours" {
  description = "Horas de retención de mensajes"
  type        = number
  default     = 24
  
  validation {
    condition     = contains([24, 72, 168], var.retention_hours)
    error_message = "Valores válidos: 24 (1 día), 72 (3 días), 168 (7 días)"
  }
}

variable "consumer_group_name" {
  description = "Nombre del consumer group"
  type        = string
  default     = "default-group"
}

variable "enable_auto_offset_reset" {
  description = "Reset automático de offset"
  type        = bool
  default     = true
}
```

---

## Instalación

```bash
cd serverless/streaming-kafka
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

---

## Uso

### Producir eventos

```bash
# Via Kafka CLI
kafka-console-producer.sh \
  --broker-list stream.example.com:9092 \
  --topic events \
  --security-protocol SASL_SSL \
  --sasl-mechanism PLAIN \
  --sasl-jaas-config '...'

# Via SDK (Python)
from confluent_kafka import Producer

producer = Producer({
    'bootstrap.servers': 'stream.example.com:9092',
    'security.protocol': 'SASL_SSL',
    'sasl.username': 'ocid1.user...',
    'sasl.password': 'auth_token',
    'sasl.mechanism': 'PLAIN'
})

producer.produce('events', json.dumps(event_data))
producer.flush()
```

### Consumir eventos

```bash
# Via Kafka CLI
kafka-console-consumer.sh \
  --bootstrap-server stream.example.com:9092 \
  --topic events \
  --from-beginning \
  --security-protocol SASL_SSL \
  --sasl-mechanism PLAIN

# Via SDK (Python)
from confluent_kafka import Consumer

consumer = Consumer({
    'bootstrap.servers': 'stream.example.com:9092',
    'group.id': 'my-group',
    'auto.offset.reset': 'earliest',
    'security.protocol': 'SASL_SSL',
    'sasl.username': 'ocid1.user...',
    'sasl.password': 'auth_token'
})

consumer.subscribe(['events'])

while True:
    msg = consumer.poll(timeout=1.0)
    if msg:
        print(f"Received: {msg.value()}")
```

---

## Estimación de Costos

### Escenario 1: Bajo Volumen (10 MB/s = 1 partición)

```
Streaming:              USD 50.00/mes
  (10 MB/s × USD 5/MB/s)

Functions Consumers:    USD 0.00
  (100K invocaciones = dentro de limite gratis)

Object Storage:         USD 0.026/mes
  (50 GB × USD 0.026/GB)

TOTAL:                  USD 50.03/mes
```

### Escenario 2: Mediano Volumen (100 MB/s = 5 particiones)

```
Streaming:              USD 250.00/mes
  (100 MB/s × USD 5/MB/s ÷ 2 para multi-tenant)

Functions:              USD 1.00/mes
  (1M invocaciones = dentro de limite gratis)

Autonomous DB:          USD 0.00
  (Always Free)

Object Storage:         USD 5.20/mes
  (200 GB × USD 0.026/GB)

TOTAL:                  USD 256.20/mes
```

---

## Consumer Functions (Ejemplos)

### Consumer 1: Archive to Object Storage

```python
def process_event(ctx, event):
    """
    Archiva eventos en Object Storage
    """
    message = event['records'][0]['value']
    
    # Guardar en Object Storage
    os.object_put(
        bucket='event-archive',
        object=f"events/{date.today()}/{uuid4()}.json",
        body=message
    )
    
    return {'status': 'archived'}
```

### Consumer 2: Real-time Analytics

```python
def stream_to_db(ctx, event):
    """
    Transmite eventos a Autonomous Database
    """
    for record in event['records']:
        data = json.loads(record['value'])
        
        conn.execute("""
            INSERT INTO events_raw (
                event_id, timestamp, source, event_type
            ) VALUES (:id, :ts, :src, :type)
        """, data)
    
    conn.commit()
    return {'rows_inserted': len(event['records'])}
```

### Consumer 3: Alert on Anomalies

```python
def detect_anomalies(ctx, event):
    """
    Detecta transacciones anormales
    """
    alerts = []
    
    for record in event['records']:
        txn = json.loads(record['value'])
        
        # Verificar anomalías
        if txn['amount'] > 10000:
            alerts.append({
                'transaction_id': txn['transaction_id'],
                'reason': 'High amount',
                'amount': txn['amount']
            })
        
        if is_fraud_detected(txn):
            alerts.append({
                'transaction_id': txn['transaction_id'],
                'reason': 'Fraud detected'
            })
    
    # Enviar alertas
    if alerts:
        sns.publish(topic='fraud-alerts', message=alerts)
    
    return {'alerts_generated': len(alerts)}
```

---

## Troubleshooting

### Consumer lag es alto

```bash
# Ver consumer group status
kafka-consumer-groups.sh \
  --bootstrap-server stream.example.com:9092 \
  --group my-group \
  --describe

# Reiniciar consumer desde beginning
kafka-consumer-groups.sh \
  --bootstrap-server stream.example.com:9092 \
  --group my-group \
  --reset-offsets \
  --to-earliest \
  --execute
```

### Mensajes no se entreguen

```bash
# Verificar health de stream
oci streaming stream describe --stream-id <stream-id>

# Ver logs de consumer function
oci functions function list-call-logs --function-id <fn-id>

# Revisar DLQ
oci queue messages get --queue-id <dlq-id>
```

---

## Monitoreo

Métricas disponibles:
- Mensajes/segundo por partición
- Bytes/segundo
- Consumer lag
- Errores de entrega
- Latencia end-to-end

```hcl
# Alarma para consumer lag alto
variable "consumer_lag_threshold" {
  description = "Umbral de consumer lag en mensajes"
  type        = number
  default     = 10000
}

# Alarma para throughput bajo
variable "throughput_threshold_mbps" {
  description = "Umbral mínimo de throughput"
  type        = number
  default     = 5
}
```

---

## Documentación Relacionada

- [OCI Streaming Documentation](https://docs.oracle.com/en-us/iaas/Content/Streaming/home.htm)
- [Kafka Client Compatibility](https://docs.oracle.com/en-us/iaas/Content/Streaming/Tasks/usingkafkacompatibleapi.htm)
- [Confluent Kafka Clients](https://docs.confluent.io/kafka-clients/python/current/overview.html)

---

## Licencia

UPL 1.0 - Oracle Universal Permissive License
