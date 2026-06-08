# Catálogo de Arquitecturas de Datos - OCI LATAM

[![Oracle Cloud Infrastructure](https://img.shields.io/badge/OCI-Reference_Architecture-FF6B35?style=for-the-badge&logo=oracle)](https://www.oracle.com/cloud/)
[![Terraform](https://img.shields.io/badge/Terraform-IaC-623CE4?style=for-the-badge&logo=terraform)](https://www.terraform.io/)
[![Idioma: Español](https://img.shields.io/badge/Idioma-Español-FF0000?style=for-the-badge)](https://www.oracle.com/es/)
[![Estatus: Active Development](https://img.shields.io/badge/Estado-Desarrollo_Activo-28A745?style=for-the-badge)](#)
[![Licencia: UPL 1.0](https://img.shields.io/badge/Licencia-UPL_1.0-0051BA?style=for-the-badge)](https://opensource.org/licenses/UPL)

## Descripción

Este catálogo proporciona arquitecturas empresariales de referencia para plataformas de datos en **Oracle Cloud Infrastructure (OCI)**, diseñadas específicamente para casos de uso en América Latina. Incluye soluciones para:

- **Autonomous Database**: Bases de datos totalmente autogestionadas (ATP/ADW)
- **MySQL HeatWave**: Análisis en tiempo real con aceleración analítica
- **NoSQL Database**: Almacenamiento de alto rendimiento clave-valor
- **Data Integration**: Pipelines ETL/ELT empresariales
- **GoldenGate**: Replicación de datos en tiempo real y streaming

Todas las arquitecturas incluyen:
- Componentes de seguridad integrados (encryption, IAM, network)
- Configuración de acceso privado (Private Endpoints)
- Monitoreo y observabilidad
- Ejemplos de código Terraform listo para producción
- Documentación completa en español

## Catálogo de Arquitecturas

| # | Arquitectura | Descripción | Caso de Uso | Deploy |
|---|---|---|---|---|
| 1 | **Autonomous Database (ATP/ADW)** | Bases de datos autogestionadas con endpoint privado y gestión automática de wallets | OLTP, Data Warehousing, Aplicaciones críticas | [![Deploy](https://img.shields.io/badge/Deploy-Cloud_Shell-FF6B35?style=flat-square)](https://cloud.oracle.com/cloudshell?git=https://github.com/jesmonsa/oracle-cloud-latam&git-branch=main) |
| 2 | **MySQL HeatWave** | MySQL con aceleración analítica integrada para OLAP en tiempo real | Analytics, Business Intelligence, HTAP | [![Deploy](https://img.shields.io/badge/Deploy-Cloud_Shell-FF6B35?style=flat-square)](https://cloud.oracle.com/cloudshell?git=https://github.com/jesmonsa/oracle-cloud-latam&git-branch=main) |
| 3 | **NoSQL Database** | Almacenamiento de alto rendimiento para cargas de trabajo de clave-valor | IoT, Real-time Processing, Mobile Apps | [![Deploy](https://img.shields.io/badge/Deploy-Cloud_Shell-FF6B35?style=flat-square)](https://cloud.oracle.com/cloudshell?git=https://github.com/jesmonsa/oracle-cloud-latam&git-branch=main) |
| 4 | **Data Integration** | Pipelines ETL/ELT empresariales para orquestación de datos | Data Pipelines, Cloud Migration, Data Consolidation | [![Deploy](https://img.shields.io/badge/Deploy-Cloud_Shell-FF6B35?style=flat-square)](https://cloud.oracle.com/cloudshell?git=https://github.com/jesmonsa/oracle-cloud-latam&git-branch=main) |
| 5 | **GoldenGate** | Replicación de datos en tiempo real y streaming heterogéneo | CDC, Real-time Replication, Disaster Recovery | [![Deploy](https://img.shields.io/badge/Deploy-Cloud_Shell-FF6B35?style=flat-square)](https://cloud.oracle.com/cloudshell?git=https://github.com/jesmonsa/oracle-cloud-latam&git-branch=main) |

## Estimación de Costos

Las arquitecturas incluyen estimaciones de costos detalladas basadas en:

### Autonomous Database (ATP/ADW)
- **Entrada**: Desde USD $0.70/hora (2 OCPU)
- **Almacenamiento**: USD $0.02/GB/mes (storage mínimo 20 GB)
- **Networking**: Incluido en Always Free tier

### MySQL HeatWave
- **Compute**: USD $0.14/hora por OCPU
- **Almacenamiento**: USD $0.01/GB/mes (storage mínimo 50 GB)
- **HeatWave Node**: USD $0.50/hora por nodo

### NoSQL Database
- **Lectura**: USD $0.00028/1K read units
- **Escritura**: USD $0.0014/1K write units
- **Almacenamiento**: USD $0.004/GB/mes

### Data Integration
- **Integración**: USD $0.006 por tarea ejecutada
- **Transferencia de datos**: Varía por volumen (pricing variable)

### GoldenGate
- **Instancia VM**: USD $0.15/hora (A1 Compute)
- **Almacenamiento**: USD $0.02/GB/mes
- **Networking**: Transferencia de datos saliente con costo

## Requisitos Previos

- **Cuenta OCI** activa con acceso a región LATAM (Sao Paulo, Montreal, etc.)
- **Terraform** >= 1.0 instalado localmente
- **OCI CLI** configurado con credenciales válidas
- **Permisos IAM**: Acceso a Database, Network, Compute servicios
- **VCN existente** (opcional: se puede crear con las arquitecturas)

## Estructura de Directorios

```
datos/
├── README.md                      # Este archivo
├── autonomous-db/                 # Autonomous Database ATP/ADW
│   ├── README.md
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── terraform.tfvars.example
│   └── schema.yaml
├── mysql-heatwave/                # MySQL HeatWave
│   ├── README.md
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── terraform.tfvars.example
│   └── schema.yaml
├── nosql/                         # OCI NoSQL Database
│   ├── README.md
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── terraform.tfvars.example
│   └── schema.yaml
├── data-integration/              # OCI Data Integration
│   ├── README.md
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── terraform.tfvars.example
│   └── schema.yaml
└── golden-gate/                   # OCI GoldenGate
    ├── README.md
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── provider.tf
    ├── terraform.tfvars.example
    └── schema.yaml
```

## Inicio Rápido

### 1. Clonar el repositorio

```bash
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/datos
```

### 2. Seleccionar una arquitectura

```bash
cd autonomous-db  # O mysql-heatwave, nosql, data-integration, golden-gate
```

### 3. Configurar variables

```bash
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars con tus valores específicos
nano terraform.tfvars
```

### 4. Inicializar Terraform

```bash
terraform init
```

### 5. Revisar el plan

```bash
terraform plan
```

### 6. Aplicar la configuración

```bash
terraform apply
```

### 7. Destruir cuando no se necesite (Para evitar costos)

```bash
terraform destroy
```

## Descripción de Arquitecturas

### 1. Autonomous Database (ATP/ADW)

Solución para bases de datos transaccionales (ATP) y analíticas (ADW) completamente autogestionadas.

**Características**:
- Autenticación con Oracle Wallets
- Acceso privado a través de Private Endpoint
- Backup automático y recuperación
- Monitoreo integrado con OCI Monitoring
- IAM integration para acceso seguro

**Documentación**: [autonomous-db/README.md](./autonomous-db/README.md)

### 2. MySQL HeatWave

MySQL de nivel empresarial con motor analítico integrado (HeatWave).

**Características**:
- Análisis en tiempo real sin ETL
- Replica Set para alta disponibilidad
- Subnet privada con acceso controlado
- Integración con OCI Database Backups
- Escalabilidad horizontal con HeatWave Nodes

**Documentación**: [mysql-heatwave/README.md](./mysql-heatwave/README.md)

### 3. NoSQL Database

Almacenamiento clave-valor de alto rendimiento para aplicaciones modernas.

**Características**:
- Throughput bajo demanda (on-demand capacity)
- Consistencia eventual o fuerte
- TTL (Time To Live) configurable
- Indexación flexible
- Multi-region replication (opcional)

**Documentación**: [nosql/README.md](./nosql/README.md)

### 4. Data Integration

Servicio de integración de datos para pipelines ETL/ELT empresariales.

**Características**:
- Connectors para múltiples fuentes (On-prem, Cloud)
- Orquestación de tareas
- Monitoreo y alertas integradas
- Transformaciones SQL/Python
- Scheduling automático

**Documentación**: [data-integration/README.md](./data-integration/README.md)

### 5. GoldenGate

Replicación de datos en tiempo real y captura de cambios (CDC).

**Características**:
- Replicación heterogénea (Oracle, MySQL, PostgreSQL, etc.)
- CDC para aplicaciones en tiempo real
- Filtrado y transformación de datos
- Recuperación ante desastres (DR)
- Bajo impacto en sistemas origen

**Documentación**: [golden-gate/README.md](./golden-gate/README.md)

## Variables Comunes

Todas las arquitecturas comparten estas variables:

```hcl
# Ubicación OCI
region           = "sa-saopaulo-1"  # O la-mexico-1, ca-montreal-1
compartment_id   = "ocid1.compartment.oc1..."

# Nombres
project_name     = "mi-proyecto"
environment      = "prod"           # dev, staging, prod

# Networking
vcn_id           = "ocid1.vcn.oc1..."
subnet_id        = "ocid1.subnet.oc1..."

# Seguridad
enable_backup    = true
backup_retention = 30               # días
enable_monitoring = true
```

## Seguridad

Todas las arquitecturas implementan:

- **Encriptación en reposo**: OCI KMS para encryption keys
- **Encriptación en tránsito**: TLS 1.2+, SSL certificates
- **IAM**: Dynamic Groups, Policies, Roles basadas en principio de menor privilegio
- **Network**: Private subnets, Security Lists, Network Security Groups
- **Auditing**: OCI Audit Logs, Database Activity Monitoring
- **Secrets**: OCI Vault para gestión de credenciales

## Monitoreo y Observabilidad

Cada arquitectura incluye:

- **Métricas**: OCI Monitoring (CPU, Memory, Connections, Throughput)
- **Logs**: OCI Logging Service para auditoría y troubleshooting
- **Alertas**: Notificaciones automáticas vía SNS/Email
- **Dashboards**: Visualización en OCI Console

## Backup y Recuperación

### Autonomous Database
- Backups automáticos diarios
- Retención configurable (1-35 días)
- Restauración a punto en tiempo (PITR)

### MySQL HeatWave
- Backups automáticos en OCI Object Storage
- Retención configurable
- Restauración automática en fallos

### NoSQL
- Replicación automática (3 réplicas por defecto)
- Point-in-time recovery (PITR) con Backups
- Multi-region replication opcional

## Documentación de OCI

- [Autonomous Database Documentation](https://docs.oracle.com/en-us/iaas/Content/Database/Concepts/adboverview.htm)
- [MySQL HeatWave Guide](https://dev.mysql.com/doc/heatwave/en/)
- [NoSQL Database Service](https://docs.oracle.com/en-us/iaas/Content/NoSQL/Concepts/nosqldb.htm)
- [Data Integration Service](https://docs.oracle.com/en-us/iaas/data-integration/home.htm)
- [GoldenGate for OCI](https://docs.oracle.com/en-us/iaas/goldengate/index.html)

## Limitaciones Conocidas

1. **Autonomous Database**: Wallets deben rotarse cada 30 días
2. **MySQL HeatWave**: Máximo 8 nodos HeatWave por instancia
3. **NoSQL**: Partición de datos limitada a 50 GB por tabla (usar multi-table designs)
4. **Data Integration**: Máximo 1000 registros por tarea en preview
5. **GoldenGate**: Requiere puerta abierta TCP 6800+ para replicación

## Solución de Problemas

### Problema: Error de conectividad a la base de datos
**Solución**:
1. Verificar Security Groups/Network Security Groups
2. Confirmar que el subnet tenga ruta a Internet Gateway
3. Revisar firewall corporativo si acceso es desde on-premise

### Problema: Wallet de Autonomous Database expirado
**Solución**:
1. Rotar wallet en OCI Console
2. Descargar nuevo wallet
3. Actualizar aplicaciones con nuevo wallet

### Problema: Alto consumo de unidades de lectura/escritura NoSQL
**Solución**:
1. Analizar patrones de acceso con OCI Logging
2. Usar índices apropiados
3. Considerar sharding de tablas grandes

## Contribuir

Para contribuir a este catálogo:

1. Fork el repositorio
2. Crear rama feature (`git checkout -b feature/nueva-arquitectura`)
3. Commit cambios (`git commit -am 'Add nueva arquitectura'`)
4. Push a la rama (`git push origin feature/nueva-arquitectura`)
5. Abrir Pull Request

## Licencia

Todas las arquitecturas están bajo licencia **UPL 1.0** (Universal Permissive License).
Ver [LICENSE](../../LICENSE) para más detalles.

## Soporte

- **Issues**: Abrir issue en GitHub para bugs/features
- **Discussions**: Usar GitHub Discussions para preguntas
- **Slack**: Unirse a comunidad OCI LATAM (próximamente)
- **Email**: arquitetura-datos@oracle.com

## Changelog

### v1.0.0 (2026-04-12)
- Lanzamiento inicial del catálogo de datos
- Incluye 5 arquitecturas empresariales
- Soporte para regiones LATAM

---

**Última actualización**: 2026-04-12
**Mantenedor**: Oracle Cloud Infrastructure LATAM Team
**Status**: Producción
