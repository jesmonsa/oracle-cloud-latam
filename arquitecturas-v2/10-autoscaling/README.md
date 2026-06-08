# Arquitectura 10 — Autoscaling (Instance Pool + Escalado Automático de Compute)

## Descripción General

Esta arquitectura implementa **escalado automático dinámico** de instancias compute basado en métricas de CPU en tiempo real. Es una solución empresarial para cargas de trabajo variables que requieren responder automáticamente a cambios en la demanda, minimizando costos y optimizando performance.

La arquitectura despliega un **Instance Pool** (grupo de instancias gestionado) con una **Autoscaling Configuration** que escala automáticamente entre 1 y 3 instancias cuando la carga de CPU excede o desciende de umbrales predefinidos. Un **Load Balancer** distribuye el tráfico entrante entre todas las instancias del pool, garantizando alta disponibilidad y distribución equitativa de carga.

### Casos de Uso

- **Ecommerce**: Escalar durante campañas, descuentos o Black Friday
- **APIs públicas**: Responder a picos de demanda de clientes externos
- **Procesamiento de eventos**: Escalar con flujo de datos variable
- **Aplicaciones web**: Distribuir usuarios concurrentes
- **Backend asincrónico**: Procesar colas de jobs con paralelismo dinámico
- **Micro-batches**: Ejecutar análisis en horarios específicos
- **Cost Optimization**: Pagar solo por recursos que realmente se usan
- **Multi-tenant SaaS**: Escalar por tenants/clientes

---

## Topología de la Arquitectura

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                                                                              │
│  ┌─────────────────────────────── Región (us-ashburn-1) ──────────────────┐ │
│  │                                                                          │ │
│  │  ┌──────────────────────────────────────────────────────────────────┐  │ │
│  │  │           VCN: 10.0.0.0/16 (Single Region)                      │  │ │
│  │  │                                                                  │  │ │
│  │  │  ┌────────────────────────────────────────────────────────────┐ │  │ │
│  │  │  │         Internet (Clientes Externos)                      │ │  │ │
│  │  │  │         ↓                                                 │ │  │ │
│  │  │  │                                                           │ │  │ │
│  │  │  │  ┌──────────────────────────────────────────────────────┐│ │  │ │
│  │  │  │  │       Subnet Pública: 10.0.0.0/24                   ││ │  │ │
│  │  │  │  │                                                      ││ │  │ │
│  │  │  │  │  ┌────────────────────────────────────────────────┐ ││ │  │ │
│  │  │  │  │  │  Load Balancer Público (Puerto 80/443)        │ ││ │  │ │
│  │  │  │  │  │  • Listening Port: 80/443                     │ ││ │  │ │
│  │  │  │  │  │  • Backend Set: Instance Pool (dinámico)      │ ││ │  │ │
│  │  │  │  │  │  • Health Check: TCP:80 cada 10s              │ ││ │  │ │
│  │  │  │  │  │  • Algoritmo: 5-tuple hash (sticky)           │ ││ │  │ │
│  │  │  │  │  │                                                │ ││ │  │ │
│  │  │  │  │  └────────────────────────────────────────────────┘ ││ │  │ │
│  │  │  │  │         ▼▼▼ Distribución de tráfico ▼▼▼             ││ │  │ │
│  │  │  │  │                                                      ││ │  │ │
│  │  │  │  │  NSG: Tráfico HTTP/HTTPS desde Internet             ││ │  │ │
│  │  │  │  │  (Ingress: 0.0.0.0/0:80,443 → LB)                 ││ │  │ │
│  │  │  │  │                                                      ││ │  │ │
│  │  │  │  └──────────────────────────────────────────────────────┘│ │  │ │
│  │  │  │                                                           │ │  │ │
│  │  │  └───────────────────────────────────────────────────────────┘ │  │ │
│  │  │                          ▼▼▼                                  │  │ │
│  │  │  ┌──────────────────────────────────────────────────────────┐ │  │ │
│  │  │  │       Subnet Privada: 10.0.1.0/24                       │ │  │ │
│  │  │  │       Instance Pool (Min:1 | Inicial:1 | Max:3)         │ │  │ │
│  │  │  │                                                          │ │  │ │
│  │  │  │  ┌─────────────────────────────────────────────────────┐│ │  │ │
│  │  │  │  │ Instancia 1 (ACTIVA - Siempre corriendo)          ││ │  │ │
│  │  │  │  │ • web-auto-1: 10.0.1.10 (E4.Flex, 1 OCPU, 4GB)   ││ │  │ │
│  │  │  │  │ • Apache + Health Check endpoint (/health)       ││ │  │ │
│  │  │  │  │ • CPU: 0-100% (monitoreado en tiempo real)       ││ │  │ │
│  │  │  │  │ • Registrada automáticamente en LB               ││ │  │ │
│  │  │  │  └─────────────────────────────────────────────────────┘│ │  │ │
│  │  │  │                                                          │ │  │ │
│  │  │  │  ┌─────────────────────────────────────────────────────┐│ │  │ │
│  │  │  │  │ Instancia 2 (ESCALA AUTOMÁTICA 1)                  ││ │  │ │
│  │  │  │  │ • web-auto-2: 10.0.1.20 (desde Instance Conf)     ││ │  │ │
│  │  │  │  │ • Creada cuando: CPU_PROMEDIO > 70%               ││ │  │ │
│  │  │  │  │ • Destruida cuando: CPU_PROMEDIO < 30% + cooldown ││ │  │ │
│  │  │  │  │ • Cooldown: 300s entre acciones de escalado       ││ │  │ │
│  │  │  │  └─────────────────────────────────────────────────────┘│ │  │ │
│  │  │  │                                                          │ │  │
│  │  │  │  ┌─────────────────────────────────────────────────────┐│ │  │ │
│  │  │  │  │ Instancia 3 (ESCALA AUTOMÁTICA 2)                  ││ │  │ │
│  │  │  │  │ • web-auto-3: 10.0.1.30 (desde Instance Conf)     ││ │  │ │
│  │  │  │  │ • Creada cuando: CPU_PROMEDIO > 70% nuevamente    ││ │  │ │
│  │  │  │  │ • Máximo permitido: 3 instancias                  ││ │  │ │
│  │  │  │  │ • Escalado dinámico sin intervención manual       ││ │  │ │
│  │  │  │  └─────────────────────────────────────────────────────┘│ │  │ │
│  │  │  │                                                          │ │  │ │
│  │  │  │  NSG Web Pool: Tráfico desde LB (10.0.0.0/24:80,443)  │ │  │ │
│  │  │  │                                                          │ │  │ │
│  │  │  └──────────────────────────────────────────────────────────┘ │  │ │
│  │  │                                                                │  │ │
│  │  │  ┌──────────────────────────────────────────────────────────┐ │  │ │
│  │  │  │      Instance Configuration (Plantilla)                 │ │  │ │
│  │  │  │  • Shape: VM.Standard.E4.Flex (1 OCPU, 4GB RAM)       │ │  │ │
│  │  │  │  • Image: Oracle Linux 9 LTS                           │ │  │ │
│  │  │  │  • UserData: Script de instalación Apache + app        │ │  │ │
│  │  │  │  • VCN/Subnet: Privada (10.0.1.0/24)                  │ │  │ │
│  │  │  │  • SSH Keys: Inyectadas desde metadata                 │ │  │ │
│  │  │  │  • Etiquetas: Aplicadas automáticamente a nuevas inst. │ │  │ │
│  │  │  └──────────────────────────────────────────────────────────┘ │  │ │
│  │  │                                                                │  │ │
│  │  │  ┌──────────────────────────────────────────────────────────┐ │  │ │
│  │  │  │    Autoscaling Configuration (Política Dinámica)        │ │  │ │
│  │  │  │                                                          │ │  │ │
│  │  │  │  REGLA 1: Scale OUT (Aumentar capacidad)               │ │  │ │
│  │  │  │  ├─ Métrica: CPU Utilization                           │ │  │ │
│  │  │  │  ├─ Umbral: > 70%                                      │ │  │ │
│  │  │  │  ├─ Duración: 5 minutos (ventana de muestreo)         │ │  │ │
│  │  │  │  ├─ Acción: Agregar 1 instancia                        │ │  │ │
│  │  │  │  ├─ Cooldown: 300 segundos (5 minutos)                │ │  │ │
│  │  │  │  └─ Máximo: 3 instancias en total                      │ │  │ │
│  │  │  │                                                          │ │  │ │
│  │  │  │  REGLA 2: Scale IN (Reducir capacidad)                │ │  │ │
│  │  │  │  ├─ Métrica: CPU Utilization                           │ │  │ │
│  │  │  │  ├─ Umbral: < 30%                                      │ │  │ │
│  │  │  │  ├─ Duración: 10 minutos (ventana de muestreo)        │ │  │ │
│  │  │  │  ├─ Acción: Remover 1 instancia                        │ │  │ │
│  │  │  │  ├─ Cooldown: 300 segundos (5 minutos)                │ │  │ │
│  │  │  │  └─ Mínimo: 1 instancia siempre corriendo              │ │  │ │
│  │  │  │                                                          │ │  │ │
│  │  │  │  Cronograma (Opcional):                                │ │  │ │
│  │  │  │  └─ Si está habilitado: escalado basado en horario     │ │  │ │
│  │  │  │     (ej: 5 instancias 8am-6pm, 1 instancia 6pm-8am)   │ │  │ │
│  │  │  │                                                          │ │  │ │
│  │  │  └──────────────────────────────────────────────────────────┘ │  │ │
│  │  │                                                                │  │ │
│  │  │  ┌──────────────────────────────────────────────────────────┐ │  │ │
│  │  │  │    Monitoring & Alerting (CloudWatch)                   │ │  │ │
│  │  │  │  ├─ CPU Utilization (promedio del pool)                 │ │  │ │
│  │  │  │  ├─ Instancias activas (1-3)                            │ │  │ │
│  │  │  │  ├─ Network In/Out (bytes/sec)                          │ │  │ │
│  │  │  │  ├─ Load Balancer connection count                      │ │  │ │
│  │  │  │  └─ Alarma: Instancias "Unknown" → PagerDuty           │ │  │ │
│  │  │  │                                                          │ │  │ │
│  │  │  └──────────────────────────────────────────────────────────┘ │  │ │
│  │  │                                                                │  │ │
│  │  │  ┌──────────────────────────────────────────────────────────┐ │  │ │
│  │  │  │    Network & Security                                   │ │  │ │
│  │  │  │  ├─ Internet Gateway (Salida pública)                   │ │  │ │
│  │  │  │  ├─ NAT Gateway (Egreso desde privada)                  │ │  │ │
│  │  │  │  ├─ Network Security Groups (Ingress/Egress)            │ │  │ │
│  │  │  │  └─ Route Tables (10.0.0.0/16 → IGW, 0.0.0.0/0 → NAT)  │ │  │ │
│  │  │  │                                                          │ │  │ │
│  │  │  └──────────────────────────────────────────────────────────┘ │  │ │
│  │  │                                                                │  │ │
│  │  └────────────────────────────────────────────────────────────────┘  │ │
│  │                                                                        │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

Flujo de Escalado Automático:
1. Cliente externo envía tráfico HTTP → Load Balancer (IP pública)
2. LB distribuye entre instancias activas del pool
3. Métricas CPU capturadas cada 60 segundos
4. Si CPU_avg > 70% durante 5 min → Crear web-auto-2
5. Si mantiene > 70% otros 5 min → Crear web-auto-3
6. Si CPU_avg < 30% durante 10 min → Destruir web-auto-3
7. Si sigue < 30% otros 10 min → Destruir web-auto-2
8. Mínimo: 1 instancia (web-auto-1) siempre corriendo
9. Máximo: 3 instancias totales
10. Cooldown 300s evita oscilaciones rápidas (scale up/down)
```

---

## Recursos Desplegados

| Recurso | Descripción | Tipo OCI |
|---------|-------------|----------|
| VCN | Red virtual 10.0.0.0/16 con IG y NAT | Virtual Cloud Network |
| Subnet Pública | 10.0.0.0/24 para Load Balancer | Subnet |
| Subnet Privada | 10.0.1.0/24 para Instance Pool | Subnet |
| Internet Gateway | Salida a Internet desde subnet pública | Internet Gateway |
| NAT Gateway | Egreso controlado desde subnet privada | NAT Gateway |
| Service Gateway | Acceso a servicios OCI sin salir VCN | Service Gateway |
| Instance Configuration | Plantilla para crear instancias dinámicamente | Instance Configuration |
| Instance Pool | Grupo de instancias (1-3) escalable | Instance Pool |
| Compute Instances | Instancias dinámicas (web-auto-1, 2, 3) | Compute Instance |
| Load Balancer | Balanceador público distribuye tráfico | Network Load Balancer |
| Backend Set | Grupo de instancias registradas en LB | Backend Set |
| Health Check | Validación TCP:80 cada 10s | Health Check |
| Autoscaling Config | Política de escalado CPU (metric-based) | Autoscaling Configuration |
| NSG Público | Seguridad subnet pública (HTTP/HTTPS) | Network Security Group |
| NSG Pool | Seguridad subnet privada (desde LB) | Network Security Group |
| Route Table Pública | Rutas: local → 10.0.0.0/16, default → IGW | Route Table |
| Route Table Privada | Rutas: local → 10.0.0.0/16, default → NAT | Route Table |
| Monitoring Alarm | CPU Alta | Alarm |
| Monitoring Alarm | CPU Baja | Alarm |

**Total de recursos**: 19 componentes principales

---

## Variables Principales

| Variable | Valor Predeterminado | Descripción |
|----------|-------------------|-------------|
| `tenancy_ocid` | (requerido) | OCID del tenancy OCI |
| `compartment_id` | (requerido) | OCID del compartment destino |
| `region` | `us-ashburn-1` | Región de despliegue |
| `vcn_cidr` | `10.0.0.0/16` | CIDR de la VCN |
| `pool_tamano_inicial` | `1` | Instancias iniciales al desplegar |
| `pool_tamano_minimo` | `1` | Mínimo de instancias siempre activas |
| `pool_tamano_maximo` | `3` | Máximo de instancias a escalar |
| `instance_shape` | `VM.Standard.E4.Flex` | Shape de las instancias |
| `umbral_cpu_scale_out` | `70` | CPU % para iniciar scale out |
| `umbral_cpu_scale_in` | `30` | CPU % para iniciar scale in |
| `cooldown_segundos` | `300` | Espera entre acciones de escalado (5 min) |

---

## Estimación de Costos

### Modelo Always Free (Desarrollo/Testing)

```
Configuración: 1 instancia E4.Flex (1 OCPU, 4GB) escala a máx 3 instancias

Escenario Baseline (1 instancia):
  • 1x Compute (E4.Flex, 1 OCPU, 4GB): Gratis (Always Free)
  • Load Balancer: $0.025/hora = ~$18/mes
  ────────────────────────────────
  Total: ~$18/mes

Escenario Pico (3 instancias, 10% del tiempo):
  • 3x Compute: Gratis (crédito Always Free cubre el pool)
  • Load Balancer: $18/mes
  ────────────────────────────────
  Total: ~$18/mes
```

---

## Despliegue Rápido

### Opción 1: Deploy Button (Recomendado)

[![Deploy to OCI](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-10-autoscaling.zip)

### Opción 2: CLI Local

```bash
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/arquitecturas-v2/10-autoscaling
terraform init -backend-config=../00-bootstrap-remotestate/backend.hcl
terraform plan -out=tfplan
terraform apply tfplan
```

---

## Verificación y Validación

```bash
# Obtener IP del LB
LB_IP=$(terraform output -raw lb_ip)
curl -v http://$LB_IP
```

---

## Limpieza (Destrucción)

```bash
terraform plan -destroy
terraform destroy -auto-approve
```

---

## Referencias y Documentación

- [OCI Instance Pools](https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/managinginstancepools.htm)
- [OCI Autoscaling](https://docs.oracle.com/en-us/iaas/Content/Autoscaling/home.htm)
- [OCI Load Balancer](https://docs.oracle.com/en-us/iaas/Content/NetworkLoadBalancer/home.htm)
- [Terraform Instance Pool Resources](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance_pool)
- [OCI Pricing Calculator](https://www.oracle.com/cloud/price-list/)
- [Always Free Tier Limits](https://www.oracle.com/cloud/free/)

---

**Última actualización**: Abril 2026 | **Terraform OCI Provider**: 6.0.0+ | **Versión Arquitectura**: 2.0
