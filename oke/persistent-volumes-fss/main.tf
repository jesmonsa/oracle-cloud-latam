# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  PERSISTENT VOLUMES - FILE STORAGE SERVICE — Arquitectura OKE                ║
# ║  Estado: PLACEHOLDER — Estructura definida, implementación pendiente         ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ==============================================================================
# RECURSOS A IMPLEMENTAR EN ESTA ARQUITECTURA
# ==============================================================================
#
# 1. NETWORKING (VCN)
#    - Virtual Cloud Network (10.3.0.0/16)
#    - Subredes para Kubernetes, Nodos, FSS
#    - Network Security Groups con reglas NFS
#    - Internet Gateway y NAT Gateway
#
# 2. OKE CLUSTER
#    - Clúster de Kubernetes
#    - Control Plane gestionado
#    - Node Pool distribuido
#
# 3. FILE STORAGE SERVICE (FSS)
#    - Sistema de archivos NFS v3/v4.1
#    - Tamaño inicial: 100-8388608 GB
#    - Auto-expansion configurada
#    - Encriptación at-rest
#
# 4. MOUNT TARGET
#    - Mount Target en subred de FSS
#    - Configuración de ruta de exportación
#    - Export Set para gestión de permisos
#    - NFS port y mountd port configurables
#
# 5. EXPORT CONFIGURATION
#    - Ruta de exportación (/exportfs)
#    - Permiso de lectura/escritura
#    - Control de acceso por CIDR
#    - Versión de NFS seleccionada
#
# 6. NETWORK SECURITY GROUP
#    - Ingress rules para NFS (puerto 2049)
#    - Ingress para mountd (puerto 111)
#    - Egress rules configuradas
#    - Source CIDR configurable
#
# 7. PROVISIONER DE OCI FSS
#    - Helm chart para provisioner
#    - Integración con CSI
#    - Soporte para ReadWriteMany
#    - Validación de permisos
#
# 8. STORAGE CLASS
#    - StorageClass "oci-fss" para PVCs
#    - Configuración de mount point
#    - Política de reclamación
#    - Validación de volume
#
# 9. SNAPSHOTS
#    - Snapshots automáticos del FSS
#    - Políticas configurables
#    - Retención de 7-365 días
#    - Clonación desde snapshots
#
# 10. AUTO-EXPANSION
#     - Monitoreo de uso de capacity
#     - Expansión automática a 80% uso
#     - Límite máximo configurable
#     - Alertas de capacidad
#
# 11. MONITOREO Y ALERTAS
#     - Métricas de uso en OCI Monitoring
#     - Alertas por capacidad
#     - Health checks de Mount Target
#     - Dashboard de visualización
#
# 12. SEGURIDAD
#     - IAM para control de acceso
#     - Encriptación at-rest con OCI Vault
#     - Audit logging de accesos
#     - Network policies en Kubernetes
#
# ==============================================================================
# TODO: IMPLEMENTAR RECURSOS ANTERIORES
# ==============================================================================
#
# Pasos para completar esta arquitectura:
# 1. Crear VCN con subredes especializadas
# 2. Crear File Storage Service (FSS)
# 3. Crear Mount Target en subred de FSS
# 4. Configurar Export Set
# 5. Crear Network Security Groups
# 6. Instalar provisioner de FSS mediante Helm
# 7. Crear StorageClass
# 8. Crear ejemplos de PVC ReadWriteMany
# 9. Configurar snapshots automáticos
# 10. Implementar auto-expansion
# 11. Configurar monitoreo y alertas
# 12. Implementar seguridad y auditoría
#
# ==============================================================================
