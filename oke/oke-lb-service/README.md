# Arquitectura OKE: Service Load Balancer con Integración Nativa OCI

## Descripción General

Esta arquitectura de referencia implementa un **Service Load Balancer de grado empresarial** directamente en Oracle Kubernetes Engine usando el Load Balancer nativo de Oracle Cloud Infrastructure. 

Proporciona:
- Load balancing nativo de OCI sin intermediarios
- Health checks personalizables a nivel de infraestructura
- Persistencia de sesiones (sticky sessions) configurables
- Soporte para SSL/TLS termination
- Integración profunda con Network Security Groups de OCI
- Algoritmos de balanceo avanzados (Round Robin, Least Connections, IP Hash)

## Casos de Uso

### Empresas Ideales
- **Aplicaciones Críticas**: Requieren baja latencia y alta disponibilidad
- **Cargas Heterogéneas**: Múltiples servicios con requisitos diferentes
- **Integración OCI Profunda**: Necesitan features específicas de OCI
- **Aplicaciones Stateful**: Requieren afinidad de sesión
- **APIs Internas/Externas**: Servicios internos o expuestos públicamente

### Ventajas Técnicas
- **Menor Latencia**: Load Balancer en la infraestructura, no en contenedor
- **Métricas Nativas**: Integración con OCI Monitoring
- **Control Fino**: Anotaciones Kubernetes para customización OCI
- **Escalabilidad**: Maneja miles de conexiones concurrentes
- **Disponibilidad**: Control de salud independiente del cluster

## Componentes Arquitectónicos

### 1. Infraestructura de Red

```
┌─────────────────────────────────────────────────────┐
│         Virtual Cloud Network (10.1.0.0/16)         │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │  Internet Gateway                            │  │
│  └──────────────────────────────────────────────┘  │
│                   │                                │
│  ┌──────────────────────────────────────────────┐  │
│  │  Subnet Load Balancer (10.1.3.0/24)          │  │
│  │  - OCI Load Balancer                         │  │
│  │  - IP Pública (flexible/100Mbps/400Mbps)     │  │
│  │  - Network Security Group                    │  │
│  └──────────────────────────────────────────────┘  │
│                   │                                │
│  ┌──────────────────────────────────────────────┐  │
│  │  Subnet Kubernetes (10.1.1.0/24)             │  │
│  │  - Control Plane                             │  │
│  └──────────────────────────────────────────────┘  │
│                   │                                │
│  ┌──────────────────────────────────────────────┐  │
│  │  Subnet Workers (10.1.2.0/24)                │  │
│  │  - Node Pool (3 nodos)                       │  │
│  │  - Service Endpoints                         │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### 2. OCI Load Balancer (Nativo)

**Topología:**
```
┌──────────────────────────────┐
│   OCI Load Balancer          │
│   (Flexible 10-100 Mbps)     │
│                              │
│   Listeners:                 │
│   - HTTP:80                  │
│   - HTTPS:443 (si cert)      │
└──────────────────────────────┘
          │
    ┌─────┼─────┐
    │     │     │
    ▼     ▼     ▼
  Node1 Node2 Node3
  :8080 :8080 :8080
```

**Características:**
- **Listeners**: HTTP (80) y HTTPS (443)
- **Backend Sets**: Agrupación lógica de backends
- **Health Checks**: TCP (puerto) o HTTP (ruta)
- **Algoritmos**: Round Robin, Least Connections, IP Hash
- **Session Persistence**: Sticky sessions por Cookie o IP
- **SSL/TLS**: Terminación en el Load Balancer

### 3. Kubernetes Services LoadBalancer

**Anotaciones OCI Soportadas:**
```yaml
apiVersion: v1
kind: Service
metadata:
  annotations:
    # Forma del Load Balancer
    oci-load-balancer.oraclecloud.com/shape: "flexible"
    oci-load-balancer.oraclecloud.com/shape-flex-min: "10"
    oci-load-balancer.oraclecloud.com/shape-flex-max: "100"
    
    # Load Balancer privado o público
    oci-load-balancer.oraclecloud.com/internal: "false"
    
    # Network Security Groups
    oci-load-balancer.oraclecloud.com/security-list-management-mode: "All"
    oci-load-balancer.oraclecloud.com/network-security-groups: "ocid1.nsg.oc1..."
    
    # Health checks
    oci-load-balancer.oraclecloud.com/health-check-protocol: "HTTP"
    oci-load-balancer.oraclecloud.com/health-check-port: "8080"
    oci-load-balancer.oraclecloud.com/health-check-interval-ms: "10000"
    oci-load-balancer.oraclecloud.com/health-check-timeout-ms: "3000"
    oci-load-balancer.oraclecloud.com/health-check-healthy-threshold: "3"
    oci-load-balancer.oraclecloud.com/health-check-unhealthy-threshold: "3"
    
    # SSL/TLS
    oci-load-balancer.oraclecloud.com/ssl-ports: "443"
    oci-load-balancer.oraclecloud.com/backend-protocol: "HTTP"
    oci-load-balancer.oraclecloud.com/ssl-cert: "ocid1.certificate..."
    
spec:
  type: LoadBalancer
  selector:
    app: my-app
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
```

### 4. Health Checks

**Mecanismos de Verificación:**

1. **TCP Health Check** (Conectividad)
```yaml
health_check_protocol: "TCP"
health_check_port: 8080
# Solo verifica que el puerto esté abierto
```

2. **HTTP Health Check** (Aplicación)
```yaml
health_check_protocol: "HTTP"
health_check_port: 8080
health_check_url_path: "/health"
health_check_return_code: "200"
# Verifica respuesta HTTP 200 OK
```

**Umbrales Configurables:**
- `healthy_threshold`: 3 checks exitosos → HEALTHY
- `unhealthy_threshold`: 3 checks fallidos → UNHEALTHY
- `interval_ms`: 30 segundos entre checks
- `timeout_ms`: 3 segundos máximo por check

### 5. Persistencia de Sesiones

**Sticky Sessions (Session Persistence):**

```
Cliente 1 → LB → Node1 (primer intento)
             ↓
           Cache en LB
             ↓
Cliente 1 → LB → Node1 (intentos siguientes)

Timeout: 30 minutos (configurable)
```

**Métodos:**
- **APP_COOKIE**: Basado en cookie de aplicación
- **LB_COOKIE**: Generada por Load Balancer
- **SOURCE_IP**: Basado en dirección IP del cliente

### 6. Algoritmos de Balanceo

| Algoritmo | Caso de Uso | Ventajas | Desventajas |
|-----------|------------|----------|-------------|
| **ROUND_ROBIN** | Por defecto, carga uniforme | Simple, predecible | No considera capacidad |
| **LEAST_CONNECTIONS** | Conexiones largas | Distribuye mejor | Mayor CPU en LB |
| **IP_HASH** | Afinidad de cliente | Determinista | Desbalanceo posible |

### 7. Monitoreo y Observabilidad

**Métricas Disponibles:**
- Conexiones activas
- Bytes entrantes/salientes
- Errores 4xx/5xx
- Latencia de respuesta
- Estado de backends
- CPU y memoria del LB

**Logging:**
- Access logs de Load Balancer
- Cambios de estado de backends
- Eventos de salud
- Errores de conexión

## Flujo de Tráfico

```
┌─────────────┐
│   Cliente   │
│ (Internet)  │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────┐
│  OCI Load Balancer          │
│  IP Pública: X.X.X.X        │
│  Puertos: 80, 443           │
└──────────┬──────────────────┘
           │
    ┌──────┼──────┐
    │      │      │
    ▼      ▼      ▼
┌──────┬──────┬──────┐
│ Pod1 │ Pod2 │ Pod3 │ (Node Pool)
│:8080 │:8080 │:8080 │
└──────┴──────┴──────┘
```

**Ejemplo con Persistencia de Sesión:**
1. Cliente → LB (primer request)
2. LB selecciona Node1, crea cookie de sesión
3. Cliente → LB (requests siguientes)
4. LB lee cookie, enruta a Node1
5. Timeout después de 30 minutos sin actividad

## Guía de Instalación

### Requisitos Previos

1. **Acceso a OCI**: Tenencia activa con credenciales
2. **Terraform**: >= 1.5.0
3. **kubectl**: >= 1.26
4. **OCI CLI**: Configurado con credenciales

### Paso 1: Configurar Variables

```bash
cp terraform.tfvars.example terraform.tfvars
# Editar con valores reales
```

### Paso 2: Inicializar Terraform

```bash
terraform init -backend-config="bucket=my-tf-state" \
               -backend-config="key=oke/oke-lb-service/terraform.tfstate"

terraform validate
terraform plan -out=tfplan
```

### Paso 3: Crear Infraestructura

```bash
terraform apply tfplan
# Esperar ~20 minutos

# Obtener kubeconfig
oci ce cluster create-kubeconfig \
  --cluster-id $(terraform output -raw cluster_id) \
  --file ~/.kube/oke-config
```

### Paso 4: Desplegar Servicio con Load Balancer

```yaml
# my-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-lb
  namespace: default
  annotations:
    oci-load-balancer.oraclecloud.com/shape: "flexible"
    oci-load-balancer.oraclecloud.com/shape-flex-min: "10"
    oci-load-balancer.oraclecloud.com/shape-flex-max: "100"
    oci-load-balancer.oraclecloud.com/health-check-protocol: "HTTP"
    oci-load-balancer.oraclecloud.com/health-check-port: "8080"
    oci-load-balancer.oraclecloud.com/health-check-interval-ms: "30000"
spec:
  type: LoadBalancer
  selector:
    app: my-app
  ports:
  - name: http
    port: 80
    targetPort: 8080
    protocol: TCP
  - name: https
    port: 443
    targetPort: 8443
    protocol: TCP
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: app
        image: my-app:latest
        ports:
        - containerPort: 8080
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 10
```

```bash
kubectl apply -f my-service.yaml

# Obtener IP del Load Balancer
kubectl get svc my-app-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

## Configuración Post-Despliegue

### 1. Agregar Certificado SSL

```bash
# Obtener OCID del certificado OCI
CERT_OCID="ocid1.certificate.oc1..."

# Actualizar servicio
kubectl patch svc my-app-lb -p '{"metadata":{"annotations":{"oci-load-balancer.oraclecloud.com/ssl-cert":"'"$CERT_OCID"'"}}}'

# Habilitar redirección HTTP → HTTPS
kubectl patch svc my-app-lb -p '{"metadata":{"annotations":{"oci-load-balancer.oraclecloud.com/backend-protocol":"HTTPS","oci-load-balancer.oraclecloud.com/ssl-ports":"443"}}}'
```

### 2. Cambiar Algoritmo de Balanceo

```bash
# Cambiar a Least Connections
kubectl patch svc my-app-lb -p '{"metadata":{"annotations":{"oci-load-balancer.oraclecloud.com/load-balancer-method":"LEAST_CONNECTIONS"}}}'

# Cambiar a IP Hash
kubectl patch svc my-app-lb -p '{"metadata":{"annotations":{"oci-load-balancer.oraclecloud.com/load-balancer-method":"IP_HASH"}}}'
```

### 3. Configurar Health Checks Personalizados

```bash
# Health check HTTP a ruta específica
kubectl patch svc my-app-lb -p '{"metadata":{"annotations":{
  "oci-load-balancer.oraclecloud.com/health-check-protocol":"HTTP",
  "oci-load-balancer.oraclecloud.com/health-check-port":"8080",
  "oci-load-balancer.oraclecloud.com/health-check-url-path":"/api/health",
  "oci-load-balancer.oraclecloud.com/health-check-interval-ms":"20000",
  "oci-load-balancer.oraclecloud.com/health-check-timeout-ms":"5000"
}}}'
```

### 4. Habilitar Persistencia de Sesión

```bash
# Sticky sessions por cookie
kubectl patch svc my-app-lb -p '{"metadata":{"annotations":{
  "oci-load-balancer.oraclecloud.com/load-balancer-cookie-persistence-configuration":"enabled",
  "oci-load-balancer.oraclecloud.com/load-balancer-cookie-persistence-configuration-cookie-name":"LBcookie",
  "oci-load-balancer.oraclecloud.com/load-balancer-cookie-persistence-configuration-disable-fallback":"true"
}}}'
```

## Mantenimiento y Operaciones

### Monitorear Salud de Backends

```bash
# Ver estado del Load Balancer
oci lb load-balancer get --load-balancer-id <LB_ID>

# Ver backends
oci lb backend list --load-balancer-id <LB_ID> --backend-set-name <SET_NAME>

# Ver salud de backend específico
oci lb backend-health get --load-balancer-id <LB_ID> \
                          --backend-set-name <SET_NAME> \
                          --backend-name <BACKEND>
```

### Escalar Servicios

```bash
# Aumentar réplicas
kubectl scale deployment my-app --replicas=5

# El Load Balancer detecta automáticamente nuevos pods
# (toma algunos segundos)
kubectl get endpoints my-app-lb
```

### Actualizar Ancho de Banda

```bash
# Para Load Balancer Flexible
kubectl patch svc my-app-lb -p '{"metadata":{"annotations":{
  "oci-load-balancer.oraclecloud.com/shape-flex-max":"200"
}}}'

# De flexible a 100Mbps
kubectl patch svc my-app-lb -p '{"metadata":{"annotations":{
  "oci-load-balancer.oraclecloud.com/shape":"100Mbps"
}}}'
```

### Cambiar a Load Balancer Privado

```bash
# Desde público a privado
kubectl patch svc my-app-lb -p '{"metadata":{"annotations":{
  "oci-load-balancer.oraclecloud.com/internal":"true"
}}}'

# Ahora solo accesible desde dentro de VCN
```

## Troubleshooting

### Servicio en "Pending" sin IP asignada

```bash
# 1. Ver eventos del servicio
kubectl describe svc my-app-lb

# 2. Ver logs de controlador
kubectl logs -n kube-system -l k8s-app=oke-controller-manager --tail=100

# 3. Verificar quotas de OCI
oci limits resource-availability get --service-name loadbalancer
```

### Backends marcados como "Unhealthy"

```bash
# 1. Verificar que el pod está corriendo
kubectl get pods -l app=my-app

# 2. Ver logs de la aplicación
kubectl logs -l app=my-app --tail=50

# 3. Probar conectividad
kubectl exec -it <POD_NAME> -- curl http://localhost:8080/health

# 4. Aumentar timeouts de health check
kubectl patch svc my-app-lb -p '{"metadata":{"annotations":{
  "oci-load-balancer.oraclecloud.com/health-check-timeout-ms":"5000",
  "oci-load-balancer.oraclecloud.com/health-check-interval-ms":"60000"
}}}'
```

### Latencia alta o timeouts

```bash
# 1. Verificar recursos del nodo
kubectl top nodes

# 2. Aumentar réplicas
kubectl scale deployment my-app --replicas=5

# 3. Cambiar algoritmo a LEAST_CONNECTIONS
# (ver sección "Cambiar Algoritmo")

# 4. Ver métricas en OCI Console
# Load Balancer → Metrics
```

### Certificado SSL no funciona

```bash
# 1. Verificar certificado existe en OCI
oci certificates-management cert get --cert-id <CERT_OCID>

# 2. Verificar anotación es correcta
kubectl get svc my-app-lb -o yaml | grep ssl-cert

# 3. Reiniciar servicio
kubectl delete svc my-app-lb
# Volver a crear con anotación correcta
```

## Optimizaciones para Producción

### 1. Pod Disruption Budget

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: my-app-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: my-app
```

### 2. Horizontal Pod Autoscaler

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### 3. Network Policy

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: my-app-network-policy
spec:
  podSelector:
    matchLabels:
      app: my-app
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector: {}
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector: {}
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: TCP
      port: 443
```

## Costos Estimados (Mensual - Región Santiago)

| Componente | Cantidad | Costo |
|-----------|----------|--------|
| OKE Cluster | 1 | Gratis |
| Nodos E4.Flex | 3 × (2 OCPU, 8GB) | ~$180 |
| Load Balancer Flexible | 1 | ~$25 |
| Data Transfer | 500GB/mes | ~$50 |
| **Total Aproximado** | | **~$255** |

## Recursos Adicionales

- [OKE Documentation](https://docs.oracle.com/en-us/iaas/Content/ContEng/home.htm)
- [OCI Load Balancer](https://docs.oracle.com/en-us/iaas/Content/Balance/home.htm)
- [OCI Load Balancer Annotations](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengcreatingloadbalancer.htm)
- [Kubernetes Service](https://kubernetes.io/docs/concepts/services-networking/service/)

---

**Última actualización**: 2026-04-12  
**Versión**: 1.0.0  
**Mantenedor**: Cloud Architecture Team
