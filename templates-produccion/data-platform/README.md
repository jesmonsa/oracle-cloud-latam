# Template: Data Platform

Plataforma de datos con Autonomous Database, Object Storage y
Data Integration para pipelines de datos empresariales. Listo para producción.

## Servicios OCI

| Servicio | Propósito |
|----------|-----------|
| ADB | Autonomous Database Serverless |
| Object Storage | Data Lake para datos crudos y procesados |
| Data Integration | Pipelines ETL/ELT gestionados |
| Vault | Cifrado de datos y gestión de credenciales |
| VCN | Red privada para acceso seguro |
| Logging | Auditoría de acceso a datos |
| Monitoring | Alertas de rendimiento y capacidad |

## Arquitectura

```
Fuentes → Data Integration → Object Storage (raw) → ADB (procesado)
                                    ↓
                        Vault + Logging + Monitoring
```

## Estado

> Próximamente — En desarrollo

## Prerrequisitos

- Completar track Datos (lecciones 01–04)
- Conocimientos de SQL y conceptos de Data Warehousing
