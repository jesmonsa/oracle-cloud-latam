# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  PERSISTENT VOLUMES - BLOCK STORAGE — Arquitectura de Referencia OKE         ║
# ║  Estado: PLACEHOLDER — Estructura definida, implementación pendiente         ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ==============================================================================
# RECURSOS A IMPLEMENTAR EN ESTA ARQUITECTURA
# ==============================================================================
#
# 1. NETWORKING (VCN)
#    - Virtual Cloud Network (10.2.0.0/16)
#    - Subredes para Kubernetes y Nodos de Trabajo
#    - Security Groups para acceso iSCSI
#
# 2. OKE CLUSTER
#    - Clúster de Kubernetes
#    - Control Plane gestionado
#    - API Server endpoint
#
# 3. NODE POOL
#    - Pool de nodos VM.Standard.E4.Flex
#    - 3 nodos distribuidos en ADs
#
# 4. CSI DRIVER DE OCI
#    - Helm chart de Block Volume CSI Driver
#    - Version 1.24.0
#    - Permisos RBAC configurados
#    - Webhook para validación de volúmenes
#
# 5. STORAGE CLASS
#    - StorageClass "oci-bv-standard" para provisioning automático
#    - Configuración de performance (VPUs)
#    - Política de reclamación (Delete o Retain)
#    - Snapshots habilitados
#
# 6. PERSISTENT VOLUMES (PV)
#    - Volúmenes de bloque de OCI
#    - Tamaño configurable (50-16384 GB)
#    - Performance configurables (10-60 VPUs/GB)
#    - Encriptación automática
#
# 7. PERSISTENT VOLUME CLAIMS (PVC)
#    - Requests dinámicas de almacenamiento
#    - Vinculación automática a PVs
#    - Modo de acceso ReadWriteOnce
#    - Clases de almacenamiento múltiples
#
# 8. SNAPSHOTS DE VOLUMEN
#    - VolumeSnapshot para backups puntuales
#    - VolumeSnapshotClass configurada
#    - Clonación rápida desde snapshots
#    - Replicación entre ADs
#
# 9. BACKUPS Y DISASTER RECOVERY
#    - Política de backups automáticos
#    - Retención configurable (7-365 días)
#    - Cronograma (diario/semanal/mensual)
#    - Replicación cross-AD para DR
#
# 10. REPLICACIÓN CROSS-AD
#     - Volúmenes replicados en múltiples ADs
#     - RPO (Recovery Point Objective) < 1 minuto
#     - RTO (Recovery Time Objective) < 5 minutos
#     - Failover automático o manual
#
# 11. ENCRIPTACIÓN Y SEGURIDAD
#     - Encriptación at-rest con OCI Vault
#     - Claves de encriptación personalizadas
#     - RBAC para acceso a volúmenes
#     - Network policies para tráfico iSCSI
#
# 12. MONITOREO Y ALERTAS
#     - Métricas de performance en OCI Monitoring
#     - Alertas por uso de capacidad
#     - Health checks de volúmenes
#     - Dashboards de visualización
#
# 13. MANTENIMIENTO AUTOMÁTICO
#     - Garbage collection de snapshots expirados
#     - Limpieza de volúmenes huérfanos
#     - Reconciliación de estados
#     - Rotación de backups
#
# ==============================================================================
# TODO: IMPLEMENTAR RECURSOS ANTERIORES
# ==============================================================================
#
# Pasos para completar esta arquitectura:
# 1. Crear VCN con subredes
# 2. Crear clúster OKE
# 3. Crear node pool distribuido en ADs
# 4. Instalar CSI driver de OCI mediante Helm
# 5. Crear StorageClass con configuración
# 6. Crear ejemplos de PVC
# 7. Crear VolumeSnapshotClass
# 8. Configurar políticas de backup
# 9. Implementar replicación cross-AD
# 10. Configurar encriptación con OCI Vault
# 11. Crear dashboards de monitoreo
# 12. Implementar alertas y escalado automático
#
# ==============================================================================
