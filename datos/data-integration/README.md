# OCI Data Integration - Arquitectura de Referencia

[![Oracle Cloud](https://img.shields.io/badge/OCI-Data_Integration-FF6B35?style=for-the-badge&logo=oracle)](https://www.oracle.com/data-integration/)
[![Terraform](https://img.shields.io/badge/Terraform-1.0+-623CE4?style=for-the-badge&logo=terraform)](https://www.terraform.io/)
[![Estado: Producción](https://img.shields.io/badge/Estado-Producci%C3%B3n-28A745?style=for-the-badge)](#)

## Descripción General

OCI Data Integration proporciona un servicio de integración ETL/ELT completamente administrado:

- **Pipelines ETL/ELT**: Orquestación de movimiento de datos
- **Múltiples Conectores**: Oracle, MySQL, PostgreSQL, Snowflake, etc.
- **Transformaciones**: SQL, Python, PySpark
- **Scheduling**: Cron-based task scheduling
- **Monitoring**: Logs y alertas integradas
- **Escalabilidad**: Procesamiento en OCI Compute
- **Costos Bajos**: USD $0.006 por tarea ejecutada

## Casos de Uso

### 1. Cloud Migration
- Migrar datos on-premise a OCI
- Replicación continua
- Validación de integridad

### 2. Data Consolidation
- Consolidar datos de múltiples fuentes
- Transformar a formato estándar
- Cargar a Data Warehouse

### 3. Real-time Analytics
- ETL continuo (micro-batches)
- Cargar a Oracle Analytics Cloud
- Dashboards frescos

### 4. Data Quality
- Validación y limpieza de datos
- Deduplicación
- Enriquecimiento de datos

## Componentes

### 1. Data Integration Workspace
- Espacio de trabajo para proyectos
- Versionado de pipelines
- Team collaboration

### 2. Pipelines
- DAG (Directed Acyclic Graph) de tareas
- Operadores: Source, Transform, Target
- Condicionales y loops

### 3. Connectors
- **Database**: Oracle, MySQL, PostgreSQL, MongoDB
- **Cloud**: Snowflake, Redshift, BigQuery
- **Files**: SFTP, FTP, Object Storage
- **APIs**: REST endpoints

### 4. Tasks
- **Source**: Lee de connector origen
- **Transform**: SQL/Python transformations
- **Target**: Escribe a connector destino
- **Mapping**: Field-level transformations

## Estimación de Costos

- **Por Tarea Ejecutada**: USD $0.006
- **Ejemplo**: 100 tareas/día × 30 días = 3,000 × $0.006 = USD $18/mes
- **Infraestructura**: OCI Compute (variable)
- **Storage**: Object Storage para datos (variable)

## Arquitectura Típica

```
On-Premise DB → OCI Data Integration → OCI Data Warehouse
                                     ↓
                              OCI Analytics Cloud
```

## Variables Configurables

```hcl
# Ubicación
region         = "sa-saopaulo-1"
compartment_id = "ocid1.compartment.oc1..."

# Workspace
workspace_name = "data-integration-ws"
description    = "ETL pipeline workspace"

# Pipelines
pipelines = {
  migration = {
    source_connector = "source-database"
    target_connector = "target-data-warehouse"
    schedule = "0 2 * * *"  # 2 AM daily
  }
}

# Connectors
connectors = {
  source-database = {
    type = "ORACLE"
    host = "source.example.com"
    port = 1521
    database = "ORCL"
  }
  target-data-warehouse = {
    type = "ORACLE"
    resource_id = oci_database_autonomous_database.adw.id
  }
}
```

## Instalación

```bash
cd datos/data-integration
terraform init
terraform plan
terraform apply
```

## Mejores Prácticas

### Pipeline Design
- Usar Data Map para transformaciones visuales
- Implementar error handling
- Monitorear logs regularmente

### Performance
- Usar connectors nativos cuando sea posible
- Batch large operations
- Optimizar SQL transformations

### Security
- No hardcode passwords (usar OCI Vault)
- Usar Private Endpoints cuando sea posible
- Implementar audit logging

## Documentación

- [OCI Data Integration Docs](https://docs.oracle.com/en-us/iaas/data-integration/home.htm)
- [Pipeline & Task Design](https://docs.oracle.com/en-us/iaas/data-integration/using/creating-pipelines.html)
- [Connectors Reference](https://docs.oracle.com/en-us/iaas/data-integration/using/supported-connectors.html)

**Versión**: 1.0.0 | **Status**: Producción ✓
