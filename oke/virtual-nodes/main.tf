# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  OKE Virtual Nodes (Serverless) — Arquitectura de Referencia                ║
# ║  Estado: PLACEHOLDER — Estructura definida, implementación pendiente         ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# Esta arquitectura implementará:
# 1. VCN con subnets configuradas para Virtual Nodes
# 2. Cluster OKE en modo ENHANCED (requerido para Virtual Nodes)
# 3. Virtual Node Pool (sin nodos físicos)
# 4. Container Instances como backend de ejecución
# 5. Kubernetes Namespaces con tolerancias y afinidad
# 6. Políticas de evicción de pods
# 7. Integración con OCI Monitoring
#
# CARACTERÍSTICAS:
# - Sin gestión de infraestructura de nodos
# - Pago por uso: Solo por tiempo de ejecución de pods
# - Escalado automático basado en demanda
# - Aislamiento de pods a nivel de Container Instance
#
# PRÓXIMOS PASOS:
# - Implementar data sources de compartments
# - Crear recursos VCN con configuración de Virtual Nodes
# - Provisionar cluster OKE ENHANCED mode
# - Crear Virtual Node Pool con configuración de pods
# - Configurar Container Instances backend
# - Crear Namespaces de Kubernetes con taints
# - Implementar tolerancias para workloads
# - Configurar políticas de evicción automática
# - Integrar con OCI Monitoring y alertas
