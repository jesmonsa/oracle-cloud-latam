# OCI GoldenGate - Arquitectura de Referencia

[![Oracle Cloud](https://img.shields.io/badge/OCI-GoldenGate-FF6B35?style=for-the-badge&logo=oracle)](https://www.oracle.com/goldengate/)
[![Terraform](https://img.shields.io/badge/Terraform-1.0+-623CE4?style=for-the-badge&logo=terraform)](https://www.terraform.io/)
[![Estado: Producción](https://img.shields.io/badge/Estado-Producci%C3%B3n-28A745?style=for-the-badge)](#)

## Descripción General

OCI GoldenGate proporciona replicación de datos en tiempo real y captura de cambios (CDC):

- **Replicación Heterogénea**: Oracle, MySQL, PostgreSQL, SQL Server
- **CDC (Change Data Capture)**: Captura cambios en tiempo real
- **Real-time Streaming**: Kafka, Pub/Sub integration
- **Low Latency**: Replicación < 1 segundo
- **Disaster Recovery**: Data replication para DR
- **Minimal Impact**: Log-based, sin affect a origen

## Casos de Uso

### 1. Disaster Recovery (DR)
- Replicación sincrónica a región secundaria
- RTO: < 1 minuto
- RPO: < 5 segundos

### 2. Real-time Analytics
- Capturar cambios a medida que ocurren
- Enviar a Kafka para procesamiento
- Datos frescos en BI tools

### 3. Database Migration
- Migrate datos on-premise a OCI
- Replicación continua
- Zero downtime cutover

### 4. Multi-directional Replication
- Dos-vías replication para geo-distributed systems
- Conflict resolution automática
- Data consistency

## Componentes

### 1. GoldenGate Instance
- VM en OCI Compute
- Software GoldenGate instalado
- Extract, Replicat, Manager procesos

### 2. Extract
- Conecta a origen (source database)
- Captura logs de cambios
- Envía a trail files

### 3. Replicat
- Conecta a destino (target database)
- Lee trail files
- Aplica cambios en target

### 4. Manager
- Controla Extract y Replicat
- Monitoreo y logging
- Recuperación automática

## Estimación de Costos

- **Compute VM**: USD $0.15/hora (A1.Flex shape)
- **Storage**: USD $0.02/GB/mes
- **Networking**: Data transfer out pricing

**Ejemplo (1 mes)**:
```
VM: $0.15 × 730 = $109.50
Storage: 50 GB × $0.02 = $1.00
Data Transfer: Variable (depende de volumen)
Total: ~$150-300/mes
```

## Instalación

```bash
cd datos/golden-gate
terraform init
terraform plan
terraform apply
```

## Configuración de Replicación

```bash
# En GoldenGate
ADD EXTRACT extract_name
ADD RMTTRAIL /path/to/trail EXTRACT extract_name
REGISTER EXTRACT extract_name DATABASE

ADD REPLICAT replicat_name
START EXTRACT extract_name
START REPLICAT replicat_name
```

## Monitoreo

```bash
# Ver estado de procesos
INFO EXTRACT
INFO REPLICAT

# Ver lag
LAG EXTRACT extract_name
LAG REPLICAT replicat_name

# Ver counters
STATS EXTRACT
```

## Mejores Prácticas

### Performance
- Monitorear Extract lag
- Usar pump para compresión
- Paralelizar Replicat si es posible

### Reliability
- Monitor heartbeat entre source/target
- Configurar auto-restart
- Regular testing de failover

### Security
- Usar OCI Vault para credenciales
- Network isolation con NSG
- Encrypt trail files

## Documentación

- [OCI GoldenGate Docs](https://docs.oracle.com/en-us/iaas/goldengate/index.html)
- [GoldenGate Architecture](https://docs.oracle.com/goldengate/latest/ggref/)
- [Replication Performance Tuning](https://docs.oracle.com/en-us/iaas/goldengate/doc/performance-tuning.html)

**Versión**: 1.0.0 | **Status**: Producción ✓
