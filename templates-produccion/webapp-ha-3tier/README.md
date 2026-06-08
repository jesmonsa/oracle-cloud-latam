# Template: Webapp HA 3 Capas

Aplicación web de 3 capas con alta disponibilidad, balanceo de carga,
base de datos y observabilidad completa. Listo para producción.

## Servicios OCI

| Servicio | Propósito |
|----------|----------|
| VCN | Red virtual con subnets públicas y privadas |
| Load Balancer | Balanceo de tráfico HTTPS con certificado |
| Compute | Instancias web en múltiples ADs |
| DB System | Base de datos con Data Guard |
| Vault | Gestión de secretos y llaves de cifrado |
| Logging | Logs centralizados (app + VCN flow) |
| Monitoring | Alarmas de CPU, memoria y salud |
| WAF | Protección contra ataques web |

## Arquitectura

```
Internet → WAF → LB (público) → Webservers (privado) → DB System (privado)
                                       ↓
                                 Vault + Logging + Monitoring
```

## Estado

> Próximamente — En desarrollo

## Prerrequisitos

- Completar arquitecturas 01–17 (fundamentos completos)
- Familiaridad con balanceo de carga y bases de datos en OCI
