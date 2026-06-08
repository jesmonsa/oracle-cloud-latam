# Templates de Producción

Templates listos para desplegar en ambientes enterprise.
Cada template combina módulos y patrones probados en las arquitecturas
progresivas y los tracks especializados.

| Template | Descripción | Servicios | Estado |
|----------|-------------|-----------|--------|
| [webapp-ha-3tier](webapp-ha-3tier/) | Aplicación web 3 capas con HA, LB, DB y observabilidad | VCN, LB, Compute, DBSystem, Vault, Logging | Próximamente |
| [microservicios-oke](microservicios-oke/) | Plataforma de microservicios con OKE, Ingress, OCIR y monitoring | OKE, LB, OCIR, Logging, Monitoring | Próximamente |
| [data-platform](data-platform/) | Plataforma de datos con ADB, Object Storage y Data Integration | ADB, Object Storage, DI, Vault | Próximamente |

## Diferencia con Arquitecturas y Tracks

- **Arquitecturas (v2)**: Progresivas, educativas, un concepto a la vez
- **Tracks**: Deep-dive en un servicio específico
- **Templates**: Listos para producción, combinan múltiples servicios, incluyen tagging, logging, alarmas y seguridad por defecto
