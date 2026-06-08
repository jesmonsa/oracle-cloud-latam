# Arquitectura OKE: NGINX Ingress Controller con cert-manager

## Descripción General

Esta arquitectura de referencia implementa un **Ingress Controller NGINX de grado empresarial** en Oracle Kubernetes Engine (OKE) con gestión automática de certificados TLS mediante **cert-manager** y **Let's Encrypt**. 

La solución proporciona:
- Enrutamiento de tráfico HTTP/HTTPS inteligente basado en hosts y rutas
- Terminación automática de TLS con renovación de certificados
- Integración nativa con Oracle Cloud Load Balancer
- Alta disponibilidad y escalabilidad automática
- Monitoreo y logging empresarial

## Casos de Uso

### Empresas y Aplicaciones Ideales
- **Plataformas SaaS multi-tenant**: Enrutamiento dinámico a diferentes aplicaciones
- **Microservicios**: Exposición de múltiples servicios Kubernetes en un único Load Balancer
- **APIs REST**: Control de tráfico, autenticación y autorización en la puerta de entrada
- **Aplicaciones Web Legacy**: Migración de infraestructura tradicional a Kubernetes
- **Implementaciones Híbridas**: Combinación de On-Premise y Cloud

### Ventajas Técnicas
- **Gestión de Certificados Automática**: Emisión y renovación sin intervención manual
- **Escalabilidad Horizontal**: NGINX se escala automáticamente con la demanda
- **Integración OCI Nativa**: Aprovecha Load Balancer, VCN y seguridad de OCI
- **Zero Downtime**: Actualización de certificados sin interruenir servicios
- **Cost Efficient**: Solo pagas por recursos usados con Load Balancer flexible

## Componentes Arquitectónicos

### 1. Infraestructura de Red (VCN)

```
┌─────────────────────────────────────────────────────┐
│         Virtual Cloud Network (10.0.0.0/16)         │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌────────────────┐  ┌───────────────┐              │
│  │   Internet GW  │  │   NAT Gateway │              │
│  └────────────────┘  └───────────────┘              │
│           │                   │                     │
│  ┌─────────────────────────────────────────────┐  │
│  │  Subnet Load Balancer (10.0.3.0/24)         │  │
│  │  - OCI Load Balancer                        │  │
│  │  - Public IP (si no es privado)             │  │
│  └─────────────────────────────────────────────┘  │
│           │                                        │
│  ┌─────────────────────────────────────────────┐  │
│  │  Subnet Kubernetes (10.0.1.0/24)            │  │
│  │  - Cluster Control Plane                    │  │
│  │  - API Server                               │  │
│  └─────────────────────────────────────────────┘  │
│           │                                        │
│  ┌─────────────────────────────────────────────┐  │
│  │  Subnet Nodos de Trabajo (10.0.2.0/24)      │  │
│  │  - Node Pool (3+ nodos)                     │  │
│  │  - NGINX Ingress Controller Pod             │  │
│  │  - cert-manager Pods                        │  │
│  └─────────────────────────────────────────────┘  │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Componentes de Red:**
- **Internet Gateway**: Acceso público a Internet
- **NAT Gateway**: Tráfico saliente de nodos sin IP pública
- **Network Security Groups (NSG)**: Firewall a nivel de subred
  - Puertos 80/443 abiertos para tráfico HTTP/HTTPS
  - Puertos internos para comunicación Kubernetes (6443, 10250)
  - Puerto 8404 para métricas de NGINX

### 2. Clúster Kubernetes (OKE)

**Características:**
- **Control Plane Gestionado**: Oracle maneja la disponibilidad y parches
- **Versión Kubernetes**: 1.29 (actualizable)
- **API Server**: Endpoint público/privado configurable
- **Componentes de Seguridad**:
  - Network Policy habilitada
  - Pod Security Policy para restricciones
  - RBAC integrado

**Node Pool:**
- **Cantidad de Nodos**: 3 (configurable)
- **Forma de VM**: VM.Standard.E4.Flex
- **Recursos por Nodo**: 2 OCPUs, 8 GB RAM (escalable)
- **Sistema Operativo**: Oracle Linux 8
- **Auto-scaling**: Habilitado con límites configurables

### 3. NGINX Ingress Controller

**Despliegue:**
```yaml
# Instalación mediante Helm
- Chart: kubernetes/ingress-nginx
- Versión: 4.8.0
- Namespace: ingress-nginx
- Réplicas: 3 (en nodos diferentes)
- Service Type: LoadBalancer
```

**Funcionalidades:**
- **Reescritura de URL**: Modificación dinámica de rutas
- **Autenticación**: Integración con OAuth2, OIDC
- **Rate Limiting**: Control de tráfico y protección DDoS
- **CORS**: Configuración de Cross-Origin Resource Sharing
- **Compresión**: gzip automático para reducir ancho de banda
- **Proxy Inverso**: Enrutamiento inteligente a backends

**Reglas de Ingress Soportadas:**
```yaml
# Simple host-based routing
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 8080

# Path-based routing
  - host: www.example.com
    http:
      paths:
      - path: /api
        backend:
          service:
            name: backend-api
            port: 8080
      - path: /admin
        backend:
          service:
            name: admin-panel
            port: 3000
```

### 4. Cert-Manager para Gestión de Certificados

**Despliegue:**
```yaml
- Chart: cert-manager/cert-manager
- Versión: v1.13.0
- Namespace: cert-manager
- Componentes:
  - controller: Reconciliación de recursos Certificate
  - webhook: Validación de manifests
  - ca-injector: Inyección de CA en webhooks
```

**ClusterIssuers:**

1. **Let's Encrypt Production** (para producción):
   - URL: https://acme-v02.api.letsencrypt.org/directory
   - Certificados válidos y reconocidos globalmente
   - Rate limiting: 50 certificados por dominio por semana

2. **Let's Encrypt Staging** (para testing):
   - URL: https://acme-staging-v02.api.letsencrypt.org/directory
   - Certificados de prueba sin límites de rate
   - Recomendado durante desarrollo

**Flujo de Renovación Automática:**
```
┌─────────────────────────────────────────────┐
│ Certificate Resource Creado                 │
└────────────────┬────────────────────────────┘
                 │
    ┌────────────▼────────────┐
    │ cert-manager Controller │
    └────────────┬────────────┘
                 │
    ┌────────────▼──────────────────┐
    │ Contacta Let's Encrypt ACME    │
    │ (HTTP-01 Challenge)           │
    └────────────┬──────────────────┘
                 │
    ┌────────────▼────────────┐
    │ Valida Posesión Dominio │
    └────────────┬────────────┘
                 │
    ┌────────────▼────────────────────┐
    │ Emite Certificado (90 días)     │
    └────────────┬────────────────────┘
                 │
    ┌────────────▼─────────────────────────┐
    │ Almacena en Secret (TLS)             │
    │ Monitorea fecha de expiración        │
    │ Renueva automáticamente a los 30 d. │
    └───────────────────────────────────────┘
```

### 5. Load Balancer de OCI

**Características:**
- **Tipo**: Flexible (con ancho de banda configurable)
- **Listeners**: HTTP (80) y HTTPS (443)
- **Health Checks**: TCP en puerto 8080 del NGINX
- **Backend Set**: Nodos del pool con algoritmo round-robin
- **Sesiones Sticky**: Mantiene conexiones al mismo backend
- **SSL/TLS**: Terminación en el Load Balancer

**Anotaciones de Kubernetes:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-ingress
  namespace: ingress-nginx
  annotations:
    oci-load-balancer.oraclecloud.com/load-balancer-type: "lb"
    oci-load-balancer.oraclecloud.com/shape: "flexible"
    oci-load-balancer.oraclecloud.com/shape-flex-min: "10"
    oci-load-balancer.oraclecloud.com/shape-flex-max: "100"
spec:
  type: LoadBalancer
  selector:
    app: ingress-nginx
  ports:
  - name: http
    port: 80
    targetPort: 80
  - name: https
    port: 443
    targetPort: 443
```

### 6. Monitoreo y Observabilidad

**Métricas (OCI Monitoring):**
- Tráfico HTTP/HTTPS
- Errores 4xx y 5xx
- Latencia de respuesta
- Conexiones activas
- Uso de CPU y memoria

**Logging (OCI Logging):**
- Access logs de NGINX
- Error logs de aplicaciones
- Eventos de cert-manager
- Logs de Kubernetes API server

**Dashboards Recomendados:**
1. **Traffic Analysis**: Volumen, latencia, errores
2. **Certificate Health**: Fechas de expiración, renovaciones
3. **Node Health**: CPU, memoria, disco de nodos
4. **Error Tracking**: 5xx errors y causas raíz

## Flujo de Tráfico

```
Cliente (Internet)
        │
        ▼
┌──────────────────────────────┐
│  OCI Load Balancer           │
│  (IP Pública: X.X.X.X)       │
│  Puertos: 80, 443            │
└──────────────────────────────┘
        │
        ▼
┌──────────────────────────────┐
│  NGINX Ingress Controller    │
│  (Service Type: LoadBalancer)│
│  Pods: 3 (ReplicaSet)        │
└──────────────────────────────┘
        │
        ├─────────┬──────────┬─────────┐
        │          │          │         │
        ▼          ▼          ▼         ▼
    api-service  web-service admin    static
    :8080        :3000       :5000     :8081
```

**Ejemplo de Enrutamiento:**
- `api.example.com/*` → `api-service:8080`
- `www.example.com/*` → `web-service:3000`
- `admin.example.com/*` → `admin-panel:5000`

## Guía de Instalación

### Requisitos Previos

1. **Acceso a Oracle Cloud**: Tenencia activa y credenciales API
2. **Terraform**: Versión >= 1.5.0
3. **kubectl**: Versión >= 1.26
4. **Helm**: Versión >= 3.12
5. **OCI CLI**: Configurado y autenticado
6. **Dominio**: Registrado y accesible (para Let's Encrypt)

### Paso 1: Preparar Credenciales

```bash
# Generar par de claves API en OCI Console
# Guardar en ~/.oci/oci_api_key.pem

# Obtener valores necesarios de OCI Console:
# - tenancy_ocid
# - current_user_ocid
# - fingerprint
# - compartment_id
```

### Paso 2: Configurar Variables

```bash
# Copiar archivo de ejemplo
cp terraform.tfvars.example terraform.tfvars

# Editar con tus valores
vi terraform.tfvars
```

### Paso 3: Inicializar y Validar

```bash
# Inicializar Terraform
terraform init -backend-config="bucket=my-terraform-state" \
               -backend-config="key=oke/ingress-nginx/terraform.tfstate"

# Validar configuración
terraform validate

# Ver plan
terraform plan -out=tfplan
```

### Paso 4: Aplicar Configuración

```bash
# Crear infraestructura (toma ~20 minutos)
terraform apply tfplan

# Obtener kubeconfig
oci ce cluster create-kubeconfig \
  --cluster-id $(terraform output -raw cluster_id) \
  --file ~/.kube/oke-config \
  --region $(terraform output -raw region)

# Configurar kubectl
export KUBECONFIG=~/.kube/oke-config
kubectl get nodes
```

### Paso 5: Verificar Instalación

```bash
# Verificar NGINX Ingress Controller
kubectl -n ingress-nginx get pods
kubectl -n ingress-nginx get svc

# Verificar cert-manager
kubectl -n cert-manager get pods
kubectl -n cert-manager get clusterissuers

# Obtener IP del Load Balancer
kubectl -n ingress-nginx get svc nginx-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

## Configuración Post-Despliegue

### 1. Apuntar Dominio a Load Balancer

```bash
# Obtener IP del Load Balancer
LB_IP=$(kubectl -n ingress-nginx get svc nginx-ingress \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Crear registro DNS A (ejemplo para AWS Route53, Google Cloud DNS, etc.)
# A record: api.example.com → $LB_IP
# A record: www.example.com → $LB_IP
# A record: *.example.com → $LB_IP (wildcard)
```

### 2. Crear Primera Aplicación con Certificado

```yaml
# Crear namespace
apiVersion: v1
kind: Namespace
metadata:
  name: my-app
---

# Crear servicio
apiVersion: v1
kind: Service
metadata:
  name: app-service
  namespace: my-app
spec:
  selector:
    app: my-app
  ports:
  - port: 80
    targetPort: 8080
---

# Crear Ingress con certificado automático
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  namespace: my-app
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - api.example.com
    secretName: api-example-tls
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-service
            port:
              number: 80
---

# Crear Certificate (alternativa a anotación)
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: api-cert
  namespace: my-app
spec:
  secretName: api-example-tls
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
  - api.example.com
```

### 3. Verificar Certificado Generado

```bash
# Esperar a que cert-manager genere el certificado (2-3 minutos)
kubectl -n my-app describe certificate api-cert

# Ver el secret con el certificado
kubectl -n my-app get secret api-example-tls -o yaml

# Verificar certificado (después de ~3 minutos)
echo | openssl s_client -servername api.example.com \
  -connect $(kubectl -n ingress-nginx get svc nginx-ingress \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):443
```

## Mantenimiento y Operaciones

### Actualizar NGINX Ingress Controller

```bash
# Ver versión actual
helm list -n ingress-nginx

# Actualizar chart
helm repo update
helm upgrade nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --version 4.9.0 \
  -f values.yaml

# Verificar
kubectl -n ingress-nginx rollout status deployment/nginx-ingress-controller
```

### Actualizar cert-manager

```bash
# Actualizar
helm upgrade cert-manager cert-manager/cert-manager \
  --namespace cert-manager \
  --version v1.14.0

# Verificar
kubectl -n cert-manager rollout status deployment/cert-manager
```

### Monitorear Certificados Próximos a Expirar

```bash
# Script de monitoreo
#!/bin/bash
for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}'); do
  kubectl get certificate -n $ns -o wide 2>/dev/null | grep -v "^NAME" | while read -r line; do
    echo "Namespace: $ns | $line"
  done
done

# Ver certificados expirados
kubectl get certificate --all-namespaces \
  -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\t"}{.status.renewalTime}{"\n"}{end}'
```

### Escalar NGINX Ingress Controller

```bash
# Aumentar réplicas
kubectl -n ingress-nginx scale deployment nginx-ingress-controller \
  --replicas=5

# Verificar escalado
kubectl -n ingress-nginx get pods -l app.kubernetes.io/name=ingress-nginx
```

### Actualizar Configuración del Load Balancer

```bash
# Cambiar ancho de banda (Flexible)
kubectl -n ingress-nginx patch service nginx-ingress \
  -p '{"metadata":{"annotations":{"oci-load-balancer.oraclecloud.com/shape-flex-max":"200"}}}'

# Cambiar forma (100Mbps a 400Mbps)
kubectl -n ingress-nginx patch service nginx-ingress \
  -p '{"metadata":{"annotations":{"oci-load-balancer.oraclecloud.com/shape":"400Mbps"}}}'
```

## Troubleshooting

### NGINX Ingress no recibe tráfico

```bash
# 1. Verificar servicio
kubectl -n ingress-nginx get svc

# 2. Verificar pod
kubectl -n ingress-nginx logs -l app=ingress-nginx --tail=100

# 3. Verificar configuración de ingress
kubectl describe ingress app-ingress -n my-app

# 4. Verificar conectividad al Load Balancer
curl -v http://<LB_IP>
```

### Certificado no se genera

```bash
# 1. Verificar ClusterIssuer
kubectl describe clusterissuer letsencrypt-prod

# 2. Ver logs de cert-manager
kubectl -n cert-manager logs -l app=cert-manager --tail=50

# 3. Verificar Certificate
kubectl describe certificate api-cert -n my-app

# 4. Ver intentos de ACME
kubectl -n my-app get certificaterequest
```

### Tráfico lento o errores 503

```bash
# 1. Verificar salud de backends
kubectl -n ingress-nginx get endpoints

# 2. Ver métricas de NGINX
kubectl -n ingress-nginx port-forward svc/nginx-ingress 8080:8080
# Abrir http://localhost:8080/stats en navegador (si está habilitado)

# 3. Verificar recursos del pod
kubectl -n ingress-nginx top pods

# 4. Escalar si es necesario
kubectl -n ingress-nginx scale deployment nginx-ingress-controller --replicas=5
```

## Optimizaciones para Producción

### 1. Pod Disruption Budget

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: nginx-ingress-pdb
  namespace: ingress-nginx
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: ingress-nginx
```

### 2. Horizontal Pod Autoscaler

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-ingress-hpa
  namespace: ingress-nginx
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-ingress-controller
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

### 3. Network Policy

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: nginx-egress
  namespace: ingress-nginx
spec:
  podSelector:
    matchLabels:
      app: ingress-nginx
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector: {}
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: TCP
      port: 443  # Para Let's Encrypt ACME
```

## Costos Estimados (Mensual en OCI - Santiago)

| Componente | Cantidad | Costo Unit. | Subtotal |
|-----------|----------|------------|----------|
| OKE Cluster | 1 | $0 | $0 |
| Nodos (E4.Flex) | 3 x (2 OCPU, 8GB RAM) | $15/OCPU + $2/GB | ~$180 |
| Load Balancer (Flexible) | 1 | $0.0035/hora | ~$25 |
| Storage (PV si aplica) | 100GB | $0.02/GB | $2 |
| **Total Estimado** | | | **~$207** |

*Precios indicativos. Consultar Oracle Cloud Pricing Calculator para valores exactos.*

## Recursos Adicionales

- [OKE Documentation](https://docs.oracle.com/en-us/iaas/Content/ContEng/home.htm)
- [NGINX Ingress Controller Helm Chart](https://kubernetes.github.io/ingress-nginx/)
- [cert-manager Official Docs](https://cert-manager.io/)
- [Let's Encrypt Rate Limiting](https://letsencrypt.org/docs/rate-limits/)
- [OCI Load Balancer Annotations](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengcreatingloadbalancer.htm)

## Soporte y Contribuciones

Para reportar issues o contribuir mejoras:
- Repository: `jesmonsa/oracle-cloud-latam`
- Issues: [GitHub Issues](https://github.com/jesmonsa/oracle-cloud-latam/issues)
- Discussiones: [GitHub Discussions](https://github.com/jesmonsa/oracle-cloud-latam/discussions)

---

**Última actualización**: 2026-04-12  
**Versión**: 1.0.0  
**Mantenedor**: Cloud Architecture Team
