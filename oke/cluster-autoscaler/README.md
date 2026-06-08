# OKE Cluster Autoscaler - Arquitectura de Referencia

## Descripción General

Esta arquitectura implementa **escalado automático en Oracle Kubernetes Engine (OKE)** mediante **Cluster Autoscaler** y **Horizontal Pod Autoscaler (HPA)**, proporcionando una solución completa para optimizar recursos y costos en tiempo real.

### Características Principales

- **Cluster Autoscaler**: Escala nodos basado en demanda de pods
- **Horizontal Pod Autoscaler (HPA)**: Escala réplicas basado en métricas
- **Metrics Server**: Proporciona CPU y memoria de pods
- **Node Pools con Límites**: Min/max configurables
- **Scale-Down Automático**: Elimina nodos infrautilizados
- **Prometheus Optional**: Monitoreo avanzado de métricas
- **Enterprise-Ready**: Validaciones, tagging, y best practices

## Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                    Oracle Cloud Region                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────────────────────────────────────────┐ │
│  │              VCN (10.0.0.0/16)                      │ │
│  │                                                     │ │
│  │  ┌─────────────────────────────────────────────┐   │ │
│  │  │   OKE Cluster with Autoscaling             │   │ │
│  │  │                                             │   │ │
│  │  │  Master Nodes (OCI-Managed, HA)            │   │ │
│  │  │                                             │   │ │
│  │  │  ┌─────────────────────────────────────┐   │   │ │
│  │  │  │ Worker Node Pool (Autoscaled)      │   │   │ │
│  │  │  │ Min: 2 | Current: 3 | Max: 10     │   │   │ │
│  │  │  │ Shape: VM.Standard.E4.Flex         │   │   │ │
│  │  │  │                                    │   │   │ │
│  │  │  │ Nodo 1  Nodo 2  Nodo 3             │   │   │ │
│  │  │  │ ┌──┐    ┌──┐    ┌──┐              │   │   │ │
│  │  │  │ │Pod1   │Pod2   │Pod3 ...│        │   │   │ │
│  │  │  │ └──┘    └──┘    └──┘              │   │   │ │
│  │  │  │                                    │   │   │ │
│  │  │  │  Cluster Autoscaler (2 réplicas)  │   │   │ │
│  │  │  │  └─ Monitorea pods pendientes    │   │   │ │
│  │  │  │  └─ Escala UP si hay demanda      │   │   │ │
│  │  │  │  └─ Escala DOWN si hay exceso     │   │   │ │
│  │  │  └─────────────────────────────────────┘   │   │ │
│  │  │                                             │   │ │
│  │  │  Metrics Server (Proporciona métricas)    │   │ │
│  │  │                                             │   │ │
│  │  └─────────────────────────────────────────────┘   │ │
│  │                                                     │ │
│  │  Addons:                                            │ │
│  │  - CoreDNS, kube-proxy                              │ │
│  │  - VCN-Native Pod Networking                        │ │
│  │  - Kubernetes Dashboard (opcional)                  │ │
│  └──────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│        Escalado Automático - Flujo de Trabajo              │
│                                                             │
│  1. Application Deployment                                 │
│     ├─ Especifica recursos (CPU, memoria)                 │
│     └─ Configura HPA si se requiere                      │
│                                                             │
│  2. Metrics Server                                         │
│     ├─ Recolecta métricas de pods cada 15s               │
│     └─ Expone métricas vía API de Kubernetes             │
│                                                             │
│  3. HPA (Pod Level)                                        │
│     ├─ Compara métricas vs targets (70% CPU, 80% mem)    │
│     └─ Escala réplicas automáticamente                   │
│                                                             │
│  4. Cluster Autoscaler (Node Level)                       │
│     ├─ Detecta pods pending (sin scheduling)             │
│     ├─ Si hay pods sin nodos: Escala UP                  │
│     └─ Si hay nodos vacíos/subutilizados: Escala DOWN   │
│                                                             │
│  5. Prometheus (Monitoreo Opcional)                       │
│     ├─ Almacena métricas históricas                      │
│     └─ Proporciona datos para alertas                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Componentes Técnicos

### 1. Cluster Autoscaler
- **Propósito**: Escala nodos basado en demanda de pods
- **Criterios de Scale-UP**:
  - Hay pods en estado Pending
  - No hay suficientes recursos en nodos existentes
- **Criterios de Scale-DOWN**:
  - Nodos con utilización < umbral (65% por defecto)
  - Por más tiempo que `scale_down_unneeded_time` (10 min)
  - Luego de `scale_down_delay_after_add` (10 min) de haber agregado un nodo
- **Configuración**:
  - Instalación vía Helm
  - 2 réplicas para HA
  - RBAC con permisos mínimos

### 2. Metrics Server
- **Propósito**: Proporciona métricas CPU/memoria
- **Fuente**: Kubelet en cada nodo
- **Intervalo**: Actualiza cada 15 segundos
- **Uso**: HPA lo utiliza para decisiones de escalado

### 3. Horizontal Pod Autoscaler (HPA)
- **Propósito**: Escala réplicas de pods
- **Basado en**: Métricas de CPU/memoria
- **Targets**: CPU 70%, Memoria 80% (configurables)
- **Ejemplo incluido**: Deployment de nginx con HPA

### 4. Node Pool Autoscalable
- **Min Nodos**: 2 (para HA)
- **Max Nodos**: 10 (límite de costos)
- **Inicial**: 3 nodos
- **Shape**: VM.Standard.E4.Flex
- **Resources**: 2 OCPUs, 16 GB RAM

### 5. Prometheus (Opcional)
- **Propósito**: Monitoreo histórico
- **Retención**: 15 días configurable
- **Métricas**: Escalado, utilización, eventos

## Ventajas del Autoscaling

### 1. Costos
- Paga solo por recursos utilizados
- Scale-down automático evita nodos ociosos
- Estimado: 30-40% ahorro vs. capacidad fija

### 2. Operacional
- Sin monitoreo manual de capacidad
- Respuesta automática a cambios de carga
- HA sin intervención humana

### 3. Rendimiento
- Pods se ejecutan con recursos suficientes
- Escalado predecible basado en métricas
- Menos contención de recursos

## Requisitos Previos

### Infraestructura
- Cuenta OCI activa
- Límites de compute disponibles
- VCN disponible

### Software
- Terraform >= 1.5.0
- OCI CLI >= 3.0.0
- kubectl >= 1.28
- Helm 3.0+ (para Cluster Autoscaler)

### Credenciales
- API Key de usuario IAM con permisos:
  - `containerengine/*`
  - `networking/*`
  - `instance/*`

## Instalación y Despliegue

### 1. Preparación

```bash
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/Arquitectura-base/oke/cluster-autoscaler
terraform init
terraform validate
```

### 2. Configurar Variables

```bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

# Completar:
# - Credenciales OCI
# - min_nodes, max_nodes
# - scale_down_utilization_threshold
# - hpa_target_cpu_utilization
```

### 3. Desplegar

```bash
terraform plan -out=tfplan
terraform apply tfplan
# Esperar 20-25 minutos
```

### 4. Configurar kubectl

```bash
oci ce cluster create-kubeconfig \
  --cluster-id <CLUSTER_ID> \
  --file $HOME/.kube/config-autoscaler \
  --region sa-santiago-1

export KUBECONFIG=$HOME/.kube/config-autoscaler
kubectl get nodes
```

### 5. Verificar Cluster Autoscaler

```bash
# Ver logs
kubectl logs -n kube-system \
  deployment/cluster-autoscaler \
  -f

# Ver estado
kubectl describe nodes

# Verificar HPA
kubectl get hpa
kubectl describe hpa hpa-example
```

## Variables Configurables

### Node Pool Autoscaling
- `min_nodes`: Mínimo (recomendado >= 2 para HA)
- `max_nodes`: Máximo (para control de costos)
- `initial_node_count`: Inicial (entre min y max)

### Cluster Autoscaler
- `scale_down_enabled`: Habilitar/deshabilitar scale-down
- `scale_down_delay_after_add`: Esperar X min después de agregar nodo
- `scale_down_utilization_threshold`: Umbral de utilización (0.0-1.0)
- `scale_down_unneeded_time`: Minutos antes de considerar scale-down

### HPA
- `hpa_target_cpu_utilization`: 70% recomendado
- `hpa_target_memory_utilization`: 80% recomendado

### Monitoreo
- `enable_prometheus`: Habilitar Prometheus
- `prometheus_retention_days`: Días de retención (recomendado 15-30)

## Ejemplos de Uso

### Generar Carga para Probar Escalado

```bash
# Crear deployment con HPA
kubectl create deployment nginx --image=nginx
kubectl autoscale deployment nginx --min=1 --max=10 \
  --cpu-percent=70

# Generar carga
kubectl run -i --tty load-generator \
  --rm --image=busybox \
  --restart=Never -- /bin/sh -c \
  "while sleep 0.01; do wget -q -O- http://nginx; done"

# En otra terminal, monitorear escalado
watch kubectl top pods
watch kubectl top nodes
watch kubectl get hpa
```

### Ver Eventos de Escalado

```bash
# Cluster Autoscaler events
kubectl describe nodes | grep -A 5 "Allocated resources"

# HPA events
kubectl get events --all-namespaces \
  --field-selector involvedObject.kind=HorizontalPodAutoscaler

# Logs de autoscaler
kubectl logs -n kube-system \
  -l app=cluster-autoscaler \
  --tail=100 -f
```

### Monitorear Prometheus

```bash
# Port-forward a Prometheus
kubectl port-forward -n monitoring svc/prometheus 9090:9090

# URL: http://localhost:9090
# Ejemplas de queries:
# - cluster_autoscaler_nodes_target_total
# - cluster_autoscaler_unschedulable_pods_count
# - container_cpu_usage_seconds_total
# - container_memory_usage_bytes
```

## Troubleshooting

### Cluster Autoscaler no escala UP

```bash
# Verificar logs
kubectl logs -n kube-system deployment/cluster-autoscaler

# Chequear si hay pods pending
kubectl get pods --all-namespaces --field-selector=status.phase=Pending

# Ver recursos disponibles
kubectl describe nodes | grep -A 5 "Allocated resources"

# Chequear permisos IAM
# El Cluster Autoscaler necesita permisos para:
# - compute/*
# - instance/*
```

### Scale-DOWN no ocurre

```bash
# Verificar configuración
grep scale_down terraform.tfvars

# Monitorear utilización de nodos
kubectl top nodes

# Ver si hay pods que impiden scale-down
# (ej: DaemonSets, local storage)
kubectl get pods --all-namespaces -o wide | grep <NODE>

# Aumentar escala de Cluster Autoscaler si es necesario
kubectl scale deployment cluster-autoscaler \
  -n kube-system --replicas=3
```

### HPA no escala pods

```bash
# Verificar Metrics Server
kubectl get deployment metrics-server -n kube-system

# Ver métricas
kubectl top pods --all-namespaces

# Chequear HPA status
kubectl describe hpa <HPA_NAME>

# Ver eventos de HPA
kubectl get events --field-selector \
  involvedObject.kind=HorizontalPodAutoscaler
```

## Parámetros Recomendados

### Para Cargas Estables
```hcl
min_nodes = 2
max_nodes = 5
scale_down_utilization_threshold = 0.70
scale_down_unneeded_time = 15
hpa_target_cpu_utilization = 75
```

### Para Cargas Bursty
```hcl
min_nodes = 1
max_nodes = 20
scale_down_utilization_threshold = 0.50
scale_down_unneeded_time = 5
hpa_target_cpu_utilization = 60
```

### Para Máxima Disponibilidad
```hcl
min_nodes = 3
max_nodes = 10
scale_down_utilization_threshold = 0.80
scale_down_unneeded_time = 30
hpa_target_cpu_utilization = 80
```

## Modelo de Costos

### Scenario: 5 pods en promedio, carga variable

Componente | Costo Mensual
-----------|---------------
Nodos base (2x) | ~$120
Nodos de escalado (promedio 2) | ~$120
VCN, networking | Incluido
OCI Monitoring | ~$5
Prometheus | Incluido
Total | ~$245/mes

Vs. Capacidad Fija (10 nodos): ~$600/mes
**Ahorro: ~59%**

## Seguridad

### Best Practices
1. RBAC: ServiceAccount con permisos mínimos
2. Network Policies: Restricción de tráfico
3. Resource Quotas: Límites por namespace
4. Pod Security Standards: Validación de pods

## Integración con CI/CD

### GitOps Workflow
```bash
# 1. Commit cambios a variables
git commit -am "Update autoscaler targets"

# 2. Terraform Plan en pipeline
terraform plan

# 3. Manual approval

# 4. Terraform Apply
terraform apply
```

## Destrucción de Recursos

```bash
terraform destroy
```

## Próximas Etapas

1. **Vertical Pod Autoscaler (VPA)**: Optimizar requests de recursos
2. **Keda**: Escalado basado en eventos
3. **Network Policies**: Restricción de tráfico inter-pods
4. **Pod Disruption Budgets**: Protección durante mantenimiento

## Comparativa: Estrategias de Escalado

| Estrategia | Velocidad | Costo | Complejidad |
|-----------|-----------|-------|------------|
| Manual | Lenta | Alto | Bajo |
| HPA Solo | Media | Medio | Medio |
| CA Solo | Media | Medio | Medio |
| **CA + HPA** | **Rápida** | **Bajo** | **Alto** |
| VPA | Lenta | Bajo | Alto |

## Support y Recursos

- **Cluster Autoscaler**: https://github.com/kubernetes/autoscaler
- **HPA Docs**: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
- **Metrics Server**: https://github.com/kubernetes-sigs/metrics-server
- **OCI Provider**: https://registry.terraform.io/providers/oracle/oci/latest/docs

## Notas Importantes

- Cluster Autoscaler y HPA **trabajan juntos**, no compiten
- No deshabilitar scale-down sin razón (aumenta costos)
- Configurar **Resource Requests/Limits** en todos los pods
- Monitorear con Prometheus para decisiones informadas
- Revisar costos mensualmente y ajustar `max_nodes`

---

**Última Actualización**: 2026-04-12  
**Versión**: 1.0  
**Mantenedor**: DevOps LATAM
