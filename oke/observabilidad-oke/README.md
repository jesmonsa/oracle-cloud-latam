# OKE Observabilidad Completa - Arquitectura de Referencia

## Descripción General

Esta arquitectura implementa una **solución completa de observabilidad** en Oracle Kubernetes Engine (OKE) con **Prometheus + Grafana + Loki** integrado con **OCI Monitoring**, proporcionando visibilidad completa de métricas, logs y alertas en tiempo real.

### Características Principales

- **Prometheus**: Recolección y almacenamiento de métricas
- **Grafana**: Visualización avanzada con dashboards
- **Loki**: Agregación centralizada de logs
- **AlertManager**: Gestión de alertas y notificaciones
- **ServiceMonitor/PodMonitor**: Autodiscovery de targets
- **OCI Monitoring**: Integración nativa con OCI
- **Dashboards Preconfigurados**: OKE, Nodes, Pods, Prometheus
- **Enterprise-Ready**: Retención configurable, HA, RBAC

## Arquitectura

```
┌──────────────────────────────────────────────────────────────┐
│              Observabilidad Stack en OKE                    │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │     Monitoring Namespace (Segregado)                   │ │
│  │                                                        │ │
│  │  ┌─────────────────────────────────────────────────┐   │ │
│  │  │ Prometheus (Recolección de Métricas)           │   │ │
│  │  │ - 2 réplicas para HA                           │   │ │
│  │  │ - Retención: 15 días                           │   │ │
│  │  │ - PVC: 50 GB persistente                       │   │ │
│  │  │ - ServiceMonitor/PodMonitor autodiscovery      │   │ │
│  │  │ - AlertManager integrado                       │   │ │
│  │  └─────────────────────────────────────────────────┘   │ │
│  │                                                        │ │
│  │  ┌─────────────────────────────────────────────────┐   │ │
│  │  │ Grafana (Visualización)                        │   │ │
│  │  │ - Admin accesible (contraseña segura)         │   │ │
│  │  │ - Dashboards preconfigurados:                 │   │ │
│  │  │   * OKE Cluster Overview                       │   │ │
│  │  │   * Node Exporter (Host Resources)             │   │ │
│  │  │   * Pod Resources                              │   │ │
│  │  │   * Prometheus Stats                           │   │ │
│  │  │ - Data source a Prometheus                     │   │ │
│  │  │ - PVC: 10 GB para configuración               │   │ │
│  │  └─────────────────────────────────────────────────┘   │ │
│  │                                                        │ │
│  │  ┌─────────────────────────────────────────────────┐   │ │
│  │  │ Loki + Promtail (Log Aggregation)             │   │ │
│  │  │ - Loki: Almacenamiento de logs                │   │ │
│  │  │ - Promtail: Recolección desde nodos           │   │ │
│  │  │ - Retención: 7 días                           │   │ │
│  │  │ - PVC: 30 GB persistente                      │   │ │
│  │  │ - Integración con Grafana                     │   │ │
│  │  └─────────────────────────────────────────────────┘   │ │
│  │                                                        │ │
│  │  ┌─────────────────────────────────────────────────┐   │ │
│  │  │ AlertManager (Alertas)                         │   │ │
│  │  │ - Gestión de alertas desde Prometheus         │   │ │
│  │  │ - Configuración de rutas                      │   │ │
│  │  │ - Silencio de alertas                         │   │ │
│  │  │ - Integraciones (Slack, PagerDuty, etc.)      │   │ │
│  │  └─────────────────────────────────────────────────┘   │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │     Application Workloads (Con Observabilidad)        │ │
│  │                                                        │ │
│  │  Pods exponen métricas en /metrics (port 8080)        │ │
│  │  ↓                                                      │ │
│  │  ServiceMonitor descubre automáticamente              │ │
│  │  ↓                                                      │ │
│  │  Prometheus las recolecta cada 30s                   │ │
│  │  ↓                                                      │ │
│  │  AlertManager evalúa reglas                          │ │
│  │  ↓                                                      │ │
│  │  Grafana visualiza en dashboards                     │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│           Integración con OCI Monitoring                    │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Prometheus → OCI Metrics (Agent)                           │
│             ↓                                                │
│  OCI Monitoring Console                                     │
│  - Dashboards adicionales                                  │
│  - Alertas OCI nativas                                     │
│  - Análisis histórico                                      │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## Componentes Técnicos

### 1. Prometheus
- **Versión**: 25.3.1 (Helm chart)
- **Réplicas**: 2 (HA)
- **Almacenamiento**: 50 GB PVC
- **Retención**: 15 días (configurable)
- **Scrape Interval**: 30 segundos
- **Targets**:
  - Kubernetes API Server
  - Kubelet (nodes)
  - Pods con ServiceMonitor
  - Prometheus mismo

### 2. Grafana
- **Versión**: 7.0.8 (Helm chart)
- **Admin Password**: Configurable (sensitivo)
- **Almacenamiento**: 10 GB PVC
- **Data Sources**: Prometheus, Loki
- **Dashboards Preconfigurados**:
  - OKE Cluster Overview
  - Node Exporter (Host Resources)
  - Pod Resources
  - Prometheus Internal Stats

### 3. Loki
- **Versión**: 5.41.2 (Helm chart)
- **Almacenamiento**: 30 GB PVC
- **Retención**: 7 días (configurable)
- **Recolector**: Promtail en cada nodo
- **Indexación**: Etiquetas (namespace, pod, container)
- **Búsqueda**: Integrada en Grafana

### 4. AlertManager
- **Almacenamiento**: 5 GB PVC
- **Rutas**: Configurable por severidad
- **Integraciones**: Slack, Email, PagerDuty, etc.
- **Silencio**: Temporal de alertas

### 5. ServiceMonitor y PodMonitor
- **Autodiscovery**: Detección automática de targets
- **Labels**: Afinidad por namespace/etiquetas
- **Relabeling**: Transformación de etiquetas
- **TLS**: Soportado para scrapes seguros

### 6. OCI Monitoring Integration
- **Agent**: Exporta métricas a OCI
- **Namespace**: OCI compartido
- **Métricas**: CPU, memoria, red, storage
- **Alertas**: Nativas de OCI

## Requisitos Previos

### Infraestructura
- Cuenta OCI activa
- Nodos con **mínimo 4 OCPUs, 32 GB RAM**
- Storage disponible (95 GB PVC total)

### Software
- Terraform >= 1.5.0
- OCI CLI >= 3.0.0
- kubectl >= 1.28
- Helm 3.0+

### Credenciales
- API Key con permisos:
  - `containerengine/*`
  - `monitoring/*`
  - `networking/*`

## Instalación y Despliegue

### 1. Preparación

```bash
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/Arquitectura-base/oke/observabilidad-oke
terraform init
```

### 2. Configurar Variables

```bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

# Configurar contraseña segura para Grafana
grafana_admin_password = "Tu_Contraseña_Muy_Segura_123!"
```

### 3. Desplegar

```bash
terraform plan -out=tfplan
terraform apply tfplan
# Esperar 25-30 minutos
```

### 4. Acceder a Grafana

```bash
# Port-forward a Grafana
kubectl port-forward -n monitoring svc/grafana 3000:80

# Abrir http://localhost:3000
# Usuario: admin
# Contraseña: (la que configuraste)
```

### 5. Verificar Prometheus

```bash
# Port-forward a Prometheus
kubectl port-forward -n monitoring svc/prometheus 9090:9090

# Abrir http://localhost:9090
# Navegar a Status > Targets
```

### 6. Ver Logs en Loki

```bash
# En Grafana:
# Cambiar data source a Loki
# Navegar a Explore
# Escribir: {job="kubelet"}
```

## Variables Configurables

### Recursos del Cluster
- `initial_node_count`: Mínimo 3 para observabilidad
- `node_ocpus`: 4+ OCPUs recomendado
- `node_memory_gb`: 32+ GB recomendado

### Prometheus
- `prometheus_retention_days`: 15 por defecto (1-365)
- `prometheus_storage_size_gb`: 50 por defecto (10-1000)

### Grafana
- `grafana_admin_password`: **CAMBIAR ESTE VALOR**
- `grafana_storage_size_gb`: 10 por defecto
- `enable_grafana_dashboards`: Habilitar/deshabilitar dashboards

### Loki
- `loki_retention_days`: 7 por defecto (1-365)
- `loki_storage_size_gb`: 30 por defecto (10-500)

### Alertas
- `enable_alert_manager`: Habilitar/deshabilitar
- `alertmanager_storage_size_gb`: 5 por defecto

## Ejemplos de Uso

### Crear Métrica Personalizada

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-metrics
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "8080"
    prometheus.io/path: "/metrics"
spec:
  containers:
  - name: app
    image: myapp:latest
    ports:
    - containerPort: 8080
      name: metrics
```

### Crear ServiceMonitor

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: my-app
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: my-app
  endpoints:
  - port: metrics
    interval: 30s
```

### Crear Regla de Alerta

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: app-alerts
  namespace: monitoring
spec:
  groups:
  - name: app.rules
    interval: 30s
    rules:
    - alert: HighCPUUsage
      expr: sum(rate(container_cpu_usage_seconds_total[5m])) > 0.9
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Alto uso de CPU detectado"
```

### Ver Métricas en Grafana

```
# CPU por Pod:
sum(rate(container_cpu_usage_seconds_total{pod!=""}[5m])) by (pod)

# Memoria por Node:
sum(container_memory_working_set_bytes{node!=""}) by (node)

# Logs de errores:
{level="ERROR"}

# Tasa de errores por servicio:
sum(rate(http_requests_total{status=~"5.."}[5m])) by (service)
```

## Troubleshooting

### Prometheus sin datos

```bash
# Verificar targets
kubectl port-forward -n monitoring svc/prometheus 9090:9090
# http://localhost:9090/targets

# Ver logs de Prometheus
kubectl logs -n monitoring prometheus-0
```

### Grafana sin datasource

```bash
# Verificar Prometheus es accesible
kubectl exec -it prometheus-0 -n monitoring -- \
  wget -O- http://prometheus:9090/-/healthy

# Re-crear datasource en Grafana
```

### Loki sin logs

```bash
# Verificar Promtail está corriendo
kubectl get pods -n monitoring -l app=promtail

# Ver logs de Promtail
kubectl logs -n monitoring -l app=promtail

# Verificar Loki accesible
kubectl port-forward -n monitoring svc/loki 3100:3100
curl http://localhost:3100/ready
```

### AlertManager no envía alertas

```bash
# Verificar AlertManager
kubectl get pods -n monitoring -l app.kubernetes.io/name=alertmanager

# Ver configuración
kubectl get secret alertmanager -n monitoring -o yaml

# Logs
kubectl logs -n monitoring -l app.kubernetes.io/name=alertmanager
```

## Dashboards Preconfigurados

### 1. OKE Cluster Overview
- Estado del cluster
- Nodos disponibles/ociosos
- Pods en ejecución
- CPU y memoria global
- Tasa de errores

### 2. Node Exporter
- CPU por núcleo
- Memoria disponible
- Disk I/O
- Tráfico de red
- Carga del sistema

### 3. Pod Resources
- CPU por pod
- Memoria por pod
- Network I/O
- Almacenamiento
- Escalado (replicas)

### 4. Prometheus Internal
- Tasa de scrape
- Targets arriba/abajo
- Tamaño de TSDB
- Velocidad de consulta

## Alertas Recomendadas

```yaml
# CPU High
sum(rate(container_cpu_usage_seconds_total[5m])) > 0.9

# Memory High
sum(container_memory_working_set_bytes) / sum(container_spec_memory_limit_bytes) > 0.85

# Disk High
node_filesystem_avail_bytes / node_filesystem_size_bytes < 0.1

# Node NotReady
kube_node_status_condition{condition="Ready",status="true"} == 0

# Pod CrashLooping
rate(kube_pod_container_status_restarts_total[15m]) > 0.1

# OOMKilled
increase(kube_pod_container_status_last_terminated_reason{reason="OOMKilled"}[5m]) > 0
```

## Modelo de Costos

### Componentes
- OKE Cluster: ~$51/mes (master)
- Worker Nodes (3x 4OCPUs, 32GB): ~$400/mes
- Storage PVC (95 GB): ~$5/mes
- OCI Monitoring: Variable (primeros 5GB/mes gratis)
- **Total**: ~$456/mes

### Optimizaciones
- Reducir `prometheus_retention_days` (7-14)
- Compartir nodos con workloads
- Usar `node_exporter` sin exportar histórico externo

## Seguridad

### Best Practices
1. **RBAC**: ServiceAccount con permisos mínimos
2. **Network Policies**: Aislamiento de namespace
3. **Secrets**: Contraseña de Grafana encriptada
4. **Auditoría**: OCI Audit integrado
5. **Backups**: Regular de PVC

### Configuración de Alertas Segura

```yaml
# Alertas a Slack (via webhook)
apiVersion: v1
kind: Secret
metadata:
  name: alertmanager-config
  namespace: monitoring
type: Opaque
stringData:
  alertmanager.yml: |
    global:
      resolve_timeout: 5m
    route:
      receiver: 'slack'
      routes:
        - match:
            severity: critical
          receiver: 'pagerduty'
    receivers:
    - name: 'slack'
      slack_configs:
      - api_url: $SLACK_WEBHOOK_URL
        channel: '#alerts'
    - name: 'pagerduty'
      pagerduty_configs:
      - service_key: $PAGERDUTY_KEY
```

## Integración con CI/CD

```yaml
# Gitlab CI: Verificar métricas post-deploy
post_deploy:
  script:
    - |
      query='up{job="my-app"} == 1'
      curl "http://prometheus:9090/api/v1/query?query=$query" \
        | jq '.data.result[] | select(.value[1] != "1")'
      if [ $? -eq 0 ]; then
        echo "App no está disponible"
        exit 1
      fi
```

## Próximas Etapas

1. **Tracing Distribuido**: Jaeger/Tempo
2. **Profiling**: Pyroscope
3. **Sar/Metrics**: kube-state-metrics mejorado
4. **Dashboards Personalizados**: Por equipo
5. **SLO/SLI**: Definición y alertas basadas en SLO

## Destrucción de Recursos

```bash
terraform destroy
```

## Support y Recursos

- **Prometheus**: https://prometheus.io/docs/
- **Grafana**: https://grafana.com/docs/
- **Loki**: https://grafana.com/docs/loki/
- **OCI Monitoring**: https://docs.oracle.com/en-us/iaas/monitoring/home.htm

## Notas Importantes

- **Espacio en Disco**: 95 GB total requerido (50+30+10+5)
- **Contraseña Grafana**: Cambiar en terraform.tfvars ANTES de desplegar
- **Retención**: Equilibrio entre visibilidad y costos
- **Backup**: Implementar estrategia de backup de PVC
- **Escalado**: Los nodos deben tener suficiente capacidad

---

**Última Actualización**: 2026-04-12  
**Versión**: 1.0  
**Mantenedor**: DevOps LATAM
