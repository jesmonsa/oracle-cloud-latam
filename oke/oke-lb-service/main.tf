# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  OKE LOAD BALANCER SERVICE — Arquitectura de Referencia OKE                  ║
# ║  Estado: PLACEHOLDER — Estructura definida, implementación pendiente         ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ==============================================================================
# RECURSOS A IMPLEMENTAR EN ESTA ARQUITECTURA
# ==============================================================================
#
# 1. NETWORKING (VCN)
#    - Virtual Cloud Network (VCN) con CIDR 10.1.0.0/16
#    - 3 Subredes (Kubernetes, Nodos de Trabajo, Load Balancer)
#    - Internet Gateway para acceso público
#    - NAT Gateway para salida de tráfico
#    - Network Security Groups (NSG) con reglas para puertos 80/443
#    - Route Tables y reglas de enrutamiento
#
# 2. OKE CLUSTER
#    - Clúster de Kubernetes Enterprise Edition
#    - Control Plane gestionado por Oracle
#    - API Server endpoint público/privado
#    - Integración con OCI Identity and Access Management
#
# 3. NODE POOL
#    - Pool de nodos VM.Standard.E4.Flex
#    - Auto-scaling habilitado
#    - Labels para selección de pods
#    - Integración con Container Registry
#
# 4. LOAD BALANCER DE OCI (NATIVO)
#    - Load Balancer público/privado configurable
#    - Listeners para HTTP (80) y HTTPS (443)
#    - Backend sets con algoritmo de balanceo configurable
#    - Health checks personalizables
#    - SSL/TLS termination (si certificate_ocid proporcionado)
#
# 5. SERVICIOS KUBERNETES LOADBALANCER
#    - Service de tipo LoadBalancer en múltiples namespaces
#    - Anotaciones OCI para configurar Load Balancer
#    - Integración automática con OCI LB
#    - Control de puertos y protocolos
#
# 6. HEALTH CHECKS
#    - Health checks TCP en puerto del servicio
#    - Health checks HTTP en ruta configurable
#    - Intervalos y thresholds configurables
#    - Monitoreo del estado de backends
#
# 7. PERSISTENCIA DE SESIONES
#    - Sticky sessions para mantener afinidad de cliente
#    - Configuración de timeout de sesión
#    - Basado en cookie o dirección IP
#
# 8. SECURITY GROUPS
#    - Ingress rules para puertos HTTP/HTTPS
#    - Egress rules para salida de tráfico
#    - Restricción de orígenes de tráfico
#    - Network ACLs
#
# 9. LOGGING Y MONITOREO
#    - Access logs en OCI Logging
#    - Métricas en OCI Monitoring
#    - Alertas basadas en salud de backends
#    - Dashboards de visualización
#
# 10. CONFIGURACIÓN SSL/TLS (OPCIONAL)
#     - Certificados de OCI Certificates
#     - Terminación TLS en Load Balancer
#     - Redirección HTTP a HTTPS
#     - Cipher suites personalizables
#
# ==============================================================================
# TODO: IMPLEMENTAR RECURSOS ANTERIORES
# ==============================================================================
#
# Pasos para completar esta arquitectura:
# 1. Crear recursos de VCN y subredes
# 2. Crear Network Security Groups con reglas
# 3. Crear clúster OKE
# 4. Crear node pool con auto-scaling
# 5. Crear Load Balancer de OCI
# 6. Crear backend sets con health checks
# 7. Crear listeners HTTP y HTTPS
# 8. Crear servicios Kubernetes LoadBalancer
# 9. Configurar anotaciones OCI en servicios
# 10. Implementar logging y monitoreo
# 11. Crear certificados SSL si es necesario
# 12. Configurar persistencia de sesiones
#
# ==============================================================================
