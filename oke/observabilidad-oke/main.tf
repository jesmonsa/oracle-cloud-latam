# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  OKE Observabilidad Completa — Arquitectura de Referencia                   ║
# ║  Estado: PLACEHOLDER — Estructura definida, implementación pendiente         ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# Esta arquitectura implementará:
# 1. VCN con subnets configuradas
# 2. Cluster OKE con recursos ampliados (4 OCPUs, 32 GB)
# 3. Namespace "monitoring" para componentes de observabilidad
# 4. Prometheus (Helm) con ServiceMonitor y PodMonitor CRDs
# 5. Grafana (Helm) con dashboards preconfigurados para OKE
# 6. Loki (Helm) para aggregación de logs
# 7. AlertManager con reglas de alertas
# 8. Integración con OCI Monitoring
# 9. RBAC y policies de red para componentes
# 10. PersistentVolumes para storage persistente
#
# PILA DE OBSERVABILIDAD:
# - Métricas: Prometheus
# - Visualización: Grafana
# - Logs: Loki + Promtail
# - Alertas: Prometheus + AlertManager
# - Tracing: Opcional (Jaeger)
#
# PRÓXIMOS PASOS:
# - Crear recursos VCN
# - Provisionar cluster OKE
# - Crear namespace monitoring con RBAC
# - Instalar Prometheus Stack vía Helm
# - Configurar Grafana datasources
# - Desplegar Loki y Promtail
# - Importar dashboards preconfigurados
# - Crear reglas de alertas
# - Integración con OCI Monitoring
# - Configurar retención de datos
