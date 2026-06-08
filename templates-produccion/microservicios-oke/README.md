# Template: Microservicios OKE

Plataforma de microservicios con Oracle Kubernetes Engine, Ingress Controller,
registro de contenedores y monitoreo integrado. Listo para producción.

## Servicios OCI

| Servicio | Propósito |
|----------|----------|
| OKE | Cluster Kubernetes gestionado |
| Load Balancer | Ingress Controller para tráfico externo |
| OCIR | Registro de imágenes de contenedores |
| VCN | Red con subnets para workers, LB y pods |
| Logging | Logs de cluster y aplicaciones |
| Monitoring | Métricas de nodos, pods y servicios |
| Vault | Secretos de Kubernetes cifrados |

## Arquitectura

```
Internet → LB (Ingress) → OKE Workers (privado) → Pods
                                  ↓
                     OCIR + Vault + Logging + Monitoring
```

## Estado

> Próximamente — En desarrollo

## Prerrequisitos

- Completar track OKE Kubernetes (lecciones 01–05 mínimo)
- Familiaridad con Kubernetes, Helm y contenedores
