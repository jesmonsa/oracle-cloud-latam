# 13 - OKE (Oracle Kubernetes Engine): Cluster Kubernetes Gestionado

[![Deploy to OCI](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-13-oke-kubernetes.zip)

## Descripción

Arquitectura empresarial que despliega un **cluster Kubernetes totalmente gestionado** mediante Oracle Kubernetes Engine (OKE) en Oracle Cloud Infrastructure. Esta solución automatiza la gestión del control plane de Kubernetes, permitiendo a los equipos enfocarse en despliegue y escalado de aplicaciones containerizadas.

Incluye:
- **3 subnets especializadas:** API Endpoint (público /28), Load Balancer Services (público /24), Node Pool (privado /24)
- **Flannel CNI** para networking overlay entre pods con máxima compatibilidad
- **Kubernetes v1.31.1** (LTS) — versión producción-ready
- **Node Pool escalable** con E4.Flex por defecto (cambiable a E5, X9, A1)
- **RBAC, Network Policies, y Secrets** gestionados nativamente
- **Integración automática** con OCI Load Balancer para servicios tipo LoadBalancer

Ideal para empresas que buscan correr microservicios, CI/CD, machine learning y aplicaciones cloud-native en OCI sin administrar la complejidad del control plane.

---

## Diagrama de Arquitectura

```
┌──────────────────────────────────────────────────────────────────┐
│                      OCI Region (us-ashburn-1)                   │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │               VCN Kubernetes (10.0.0.0/16)                │  │
│  │                                                            │  │
│  ├─────────────────────────────────────────────────────────┐ │  │
│  │   Subnet API Endpoint (Public, 10.0.0.0/28)             │ │  │
│  │   ┌──────────────────────────────────────────┐           │ │  │
│  │   │  Kubernetes API Server (Public)          │           │ │  │
│  │   │  Endpoint: 10.0.0.X:6443                 │<--Internet │ │  │
│  │   │  (Acceso desde CLI/Dashboard)            │           │ │  │
│  │   └──────────────────────────────────────────┘           │ │  │
│  └─────────────────────────────────────────────────────────┘ │  │
│                         │                                      │  │
│  ┌─────────────────────┼──────────────────────────────────┐  │  │
│  │                     │ Service                          │  │  │
│  │   Subnet LB Services (Public, 10.0.1.0/24)             │  │  │
│  │   ┌──────────────────────────────────────────┐          │  │  │
│  │   │  Load Balancer (OCI LB)                  │          │  │  │
│  │   │  Service type: LoadBalancer              │<-Internet │  │  │
│  │   │  Expone apps en 80/443                   │          │  │  │
│  │   └────────────┬─────────────────────────────┘          │  │  │
│  └────────────────┼──────────────────────────────────────┘  │  │
│                   │ NodePort                                  │  │
│  ┌────────────────▼──────────────────────────────────────┐  │  │
│  │  Subnet Node Pool (Private, 10.0.10.0/24)             │  │  │
│  │                                                        │  │  │
│  │  ┌─────────────────┐   ┌──────────────────┐          │  │  │
│  │  │ Worker Node 1   │   │ Worker Node N    │          │  │  │
│  │  │ 10.0.10.X       │   │ 10.0.10.Y        │          │  │  │
│  │  │                 │   │                  │          │  │  │
│  │  │  ┌──────────┐   │   │  ┌──────────┐    │          │  │  │
│  │  │  │  Pod 1   │   │   │  │  Pod M   │    │          │  │  │
│  │  │  └──────────┘   │   │  └──────────┘    │          │  │  │
│  │  │  ┌──────────┐   │   │  ┌──────────┐    │          │  │  │
│  │  │  │  Pod 2   │   │   │  │  Pod N   │    │          │  │  │
│  │  │  └──────────┘   │   │  └──────────┘    │          │  │  │
│  │  │  kubelet, cri-o │   │  kubelet, cri-o │          │  │  │
│  │  └─────────────────┘   └──────────────────┘          │  │  │
│  │                                                        │  │  │
│  │  Flannel CNI Overlay:                                │  │  │
│  │    Pods CIDR: 10.244.0.0/16                         │  │  │
│  │    Services CIDR: 10.96.0.0/16                      │  │  │
│  └────────────────────────────────────────────────────────┘  │  │
│                                                                │  │
│  ┌────────────────────────────────────────────────────────┐  │  │
│  │ Management & Observability                             │  │  │
│  │  - OCI Monitoring (Prometheus compatible)              │  │  │
│  │  - Container Registry (OCIR)                           │  │  │
│  │  - Service Mesh (Istio optional)                       │  │  │
│  │  - Logging (OCI Logging / Fluentd)                     │  │  │
│  └────────────────────────────────────────────────────────┘  │  │
└──────────────────────────────────────────────────────────────────┘
```

---

## Recursos Desplegados

| Recurso | Descripción | Tipo OCI |
|---------|-------------|----------|
| **VCN** | Red virtual con CIDR 10.0.0.0/16 configurable | `oci_core_vcn` |
| **Subnets (x3)** | API Endpoint (/28), LB (/24), Nodes (/24) | `oci_core_subnet` |
| **Internet Gateway** | Acceso a internet para subnets públicas | `oci_core_internet_gateway` |
| **NAT Gateway** | Salida a internet desde Node Pool privado | `oci_core_nat_gateway` |
| **Service Gateway** | Acceso a servicios OCI (OCR, OCI Logging, etc.) | `oci_core_service_gateway` |
| **Route Tables (x2)** | Pública (IGW) y Privada (NAT + SGW) | `oci_core_route_table` |
| **Security Lists** | Firewall para API, LB, y Node Pool | `oci_core_security_list` |
| **OKE Cluster** | Control plane gestionado de Kubernetes | `oci_containerengine_cluster` |
| **Node Pool** | Grupo de worker nodes autoscalable | `oci_containerengine_node_pool` |
| **Compute Instances (Workers)** | VMs con kubelet y cri-o | `oci_core_instance` |
| **Flannel CNI** | Plugin de red para pod-to-pod communication | Controlador DaemonSet |
| **OCI Load Balancer (Opcional)** | Para servicios type: LoadBalancer | `oci_lb_load_balancer` |

---

## Topología de Red Kubernetes

```
┌─────────────────────────────────────────────────────────────┐
│ OCI VCN (10.0.0.0/16)                                       │
│                                                             │
│  API Subnet: 10.0.0.0/28                                   │
│    └─ K8s API: 10.0.0.X:6443 (público)                     │
│                                                             │
│  LB Subnet: 10.0.1.0/24                                    │
│    └─ OCI LB IP: 10.0.1.X (público)                        │
│    └─ Service NodePort range: 30000-32767                  │
│                                                             │
│  Node Subnet: 10.0.10.0/24 (privado)                       │
│    ├─ Worker 1: 10.0.10.X                                  │
│    ├─ Worker 2: 10.0.10.Y                                  │
│    └─ Worker N: 10.0.10.Z                                  │
│                                                             │
│  Pods CIDR: 10.244.0.0/16 (overlay Flannel)               │
│    └─ Pod IPs asignadas por Flannel                        │
│                                                             │
│  Services CIDR: 10.96.0.0/16 (virtual, solo intra-cluster) │
│    └─ Service IPs (ClusterIP, LoadBalancer, etc.)         │
└─────────────────────────────────────────────────────────────┘

NOTAS:
- API Endpoint es PUBLICO pero requiere cert/key válidos
- Node Pool es PRIVADO — acceso solo via Bastion o kubectl
- Flannel proporciona conectividad pod-a-pod usando túneles VXLAN
- Services CIDR es solo para kube-proxy (iptables/ipvs)
```

---

## Shapes Compatibles

| Shape | OCPU | RAM | Costo/mes | Always Free | Caso de Uso |
|-------|------|-----|----------|------------|-------------|
| **VM.Standard.E4.Flex** | 1 | 8 GB | Gratis | Si | Desarrollo, Lab, Startups |
| **VM.Standard.E5.Flex** | 1 | 8 GB | $0.07 | Si (primeros 2 OCPU) | Producción pequeña/media |
| **VM.Standard.A1.Flex** | 1 (ARM) | 8 GB | Gratis | Si | ARM workloads, cost-optimized |
| **VM.Standard.X9.Flex** | 1 | 8 GB | $0.85+ | No | High-performance computing |

**Recomendación por Caso:**
- **Lab/Desarrollo:** E4.Flex (Always Free, suficiente para 5-10 pods pequeños)
- **Producción pequeña (< 50 pods):** E5.Flex con 2-4 OCPU
- **Producción mediana:** Múltiples E5.Flex o X9.Flex con 8+ OCPU
- **Workloads ARM:** A1.Flex (4+ OCPU para mejor rendimiento)

---

## Variables Principales

| Variable | Descripción | Default | Rango/Validación |
|----------|-------------|---------|------------------|
| `proyecto` | Nombre del cluster y prefijo de recursos | `oke` | 3-12 caracteres, minúsculas |
| `ambiente` | Ambiente de despliegue | `desarrollo` | desarrollo, staging, produccion |
| `region` | Región OCI | `us-ashburn-1` | us-ashburn-1, us-phoenix-1, sa-santiago-1, etc. |
| `vcn_cidr` | CIDR de la VCN | `10.0.0.0/16` | Cualquier /16 privado |
| `subnet_api_cidr` | CIDR API Endpoint | `10.0.0.0/28` | /28 dentro de vcn_cidr |
| `subnet_lb_cidr` | CIDR LB Services | `10.0.1.0/24` | /24 dentro de vcn_cidr |
| `subnet_nodepool_cidr` | CIDR Node Pool (privado) | `10.0.10.0/24` | /24 dentro de vcn_cidr |
| `pods_cidr` | CIDR overlay para pods (Flannel) | `10.244.0.0/16` | Debe diferir de VCN CIDR |
| `services_cidr` | CIDR para servicios Kubernetes | `10.96.0.0/16` | Rango virtual (solo intra-cluster) |
| `k8s_version` | Versión de Kubernetes | `v1.31.1` | v1.27.x, v1.28.x, v1.29.x, v1.30.x, v1.31.x |
| `node_pool_size` | Número inicial de worker nodes | `1` | 1-100 (escalable con autoscaler) |
| `node_shape` | Shape de worker nodes | `VM.Standard.E4.Flex` | E4.Flex, E5.Flex, A1.Flex, X9.Flex |
| `node_ocpus` | OCPUs por nodo (solo Flex) | `1` | 1-4 para E4, 1-8 para E5, 1-80 para X9 |
| `node_memoria_gb` | RAM por nodo en GB (solo Flex) | `8` | 8-64 según shape |
| `ssh_public_key` | Llave SSH para worker nodes (debug) | **(REQUERIDO)** | Formato OpenSSH |
| `propietario` | Email del propietario (tag) | `admin` | Válido para auditoría |
| `compartment_ocid` | Compartment OCI destino | **(REQUERIDO)** | OCID válido |

---

## Estimación de Costos

### Desglose por Componente (Region us-ashburn-1, 730 horas/mes)

| Componente | Cantidad | Precio Unit./mes | Subtotal/mes | Notas |
|---|---|---|---|---|
| **Cluster Control Plane** | 1 | $0 | $0 | Gestionado (gratis en OCI) |
| **Worker Nodes (E4.Flex 1 OCPU)** | 1-3 | $0 | $0 | Always Free Tier |
| **Worker Nodes (E5.Flex 2 OCPU)** | 1 | $0.07/OCPU | $10.22 | Si escalas a 2 OCPU |
| **Worker Nodes (X9.Flex 4 OCPU)** | 1 | $0.28/OCPU | $81.76 | High-performance |
| **OCI Load Balancer (10 Mbps)** | 1 | $0 | $0 | Always Free (si usas) |
| **Persistent Volumes (Block Storage)** | Por GB | $0.0260/GB | Varía | Si despliegas DBs |
| **Image Registry (OCIR)** | Gratis | $0 | $0 | Storage: $0.0255/GB |
| **NAT Gateway** | 1 | $0.045/GB | Varía | Solo si sales a internet |

**Costo Total Estimado:**
- **Lab/Desarrollo (1x E4.Flex):** $0 USD/mes (100% Always Free)
- **Producción (3x E4.Flex + LB):** $0 USD/mes (100% Always Free)
- **Escalado (2x E5.Flex 4 OCPU):** ~$60 USD/mes + almacenamiento

### Cómo Optimizar Costos

1. **Always Free Tier:** Mantener <= 4 OCPU total en E4 o A1
2. **Autoscaling:** Desabilitar si no necesitas escalar dinámicamente
3. **Image Pruning:** Limpiar contenedores sin usar en OCIR
4. **Reserved Capacity:** Comprar capacidad reservada para producción (40% descuento)

---

## Prerequisitos

### Software Requerido

- **Terraform:** >= 1.5.0
  ```bash
  terraform --version
  ```
- **OCI CLI:** >= 3.40.0
  ```bash
  oci --version
  ```
- **kubectl:** >= 1.30.0 (compatible con K8s 1.31)
  ```bash
  kubectl version --client
  ```
- **SSH Key Pair:**
  ```bash
  ssh-keygen -t rsa -b 4096 -f ~/.ssh/oke_id_rsa -C "oke@empresa"
  cat ~/.ssh/oke_id_rsa.pub  # Para variable ssh_public_key
  ```

### Credenciales OCI

1. **API Keys:** Generar en OCI Console → User → API Keys
2. **Variables de entorno:**
   ```bash
   export TF_VAR_tenancy_ocid="ocid1.tenancy.oc1..."
   export TF_VAR_compartment_ocid="ocid1.compartment.oc1..."
   export TF_VAR_current_user_ocid="ocid1.user.oc1..."
   export TF_VAR_fingerprint="aa:bb:cc:dd:..."
   export TF_VAR_private_key_path="~/.oci/api_key.pem"
   export TF_VAR_ssh_public_key="ssh-rsa AAAA..."
   ```

### Cuota de Recursos

Verificar en OCI Console → Governance → Limits:
- Compute: >= 4 OCPU (mínimo 1 nodo E4.Flex)
- VCNs: >= 1 VCN disponible
- Load Balancers: >= 1 LB (si usas servicios type: LoadBalancer)

```bash
# Verificar cuotas desde CLI
oci limits list-definitions --region us-ashburn-1 \
  --query "data[?name=='compute'].{name:name,limit:value}" \
  --output table
```

### Configuración Inicial

```bash
# 1. Clonar repositorio
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/arquitecturas-v2/13-oke-kubernetes

# 2. Crear terraform.tfvars
cp terraform.tfvars.example terraform.tfvars

# 3. Editar con tus valores (especialmente ssh_public_key)
nano terraform.tfvars

# 4. Validar credenciales
oci iam user get --user-id $TF_VAR_current_user_ocid
```

---

## Despliegue Rápido

### Opción A: Terraform Directo

```bash
# 1. Inicializar Terraform
terraform init

# 2. Validar configuración
terraform validate

# 3. Planificar cambios (revisar antes de aplicar)
terraform plan -out=plan.tfplan

# 4. Aplicar (crear cluster)
terraform apply plan.tfplan

# Tiempo estimado: 8-15 minutos
#   - VCN + Subnets: ~1 min
#   - Control Plane: ~5-7 min
#   - Worker Nodes: ~3-5 min
#   - Flannel CNI: ~1-2 min (auto-instalado)
```

### Opción B: Oracle Resource Manager

1. **Descargar ZIP:**
   ```bash
   curl -L https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-13-oke-kubernetes.zip -o oke.zip
   ```

2. **OCI Console → Resource Manager → Stacks → Create Stack**
3. **Upload ZIP** y configurar variables en UI
4. **Plan → Apply**

---

## Configuración de kubectl

### 1. Obtener Kubeconfig

Después de despliegue exitoso:

```bash
# Obtener cluster OCID
CLUSTER_ID=$(terraform output -raw oke_cluster_id)

# Descargar kubeconfig
oci ce cluster create-kubeconfig \
  --cluster-id $CLUSTER_ID \
  --file ~/.kube/config \
  --region us-ashburn-1

# Validar permisos
chmod 600 ~/.kube/config

# Verificar conexión
kubectl cluster-info
```

### 2. Validar Acceso al API

```bash
# Listar nodos
kubectl get nodes

# Ver versión
kubectl version
```

---

## Verificación Post-Despliegue

### 1. Estado del Cluster

```bash
# Obtener información de outputs
terraform output

# Ver IP del API endpoint
terraform output -raw kubernetes_api_endpoint
```

### 2. Validar Componentes Kubernetes

```bash
# Ver nodos (esperar 2-3 min para "Ready")
kubectl get nodes -o wide

# Ver pods del sistema
kubectl get pods -A

# Ver servicios
kubectl get svc -A
```

### 3. Validar Flannel CNI

```bash
# Ver pods de Flannel (en kube-system namespace)
kubectl get ds -n kube-system -l app=flannel

# Validar conectividad pod-a-pod
kubectl run ping-test-1 --image=busybox -- sleep 3600
kubectl run ping-test-2 --image=busybox -- sleep 3600

# Obtener IPs de pods
POD1_IP=$(kubectl get pod ping-test-1 -o jsonpath='{.status.podIP}')
POD2_IP=$(kubectl get pod ping-test-2 -o jsonpath='{.status.podIP}')

# Hacer ping
kubectl exec ping-test-1 -- ping -c 3 $POD2_IP
# Esperado: 3 replies, 0% packet loss
```

### 4. Validar Servicios y Load Balancer

```bash
# Crear servicio de prueba (LoadBalancer type)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: test-lb
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: nginx
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 8080
EOF

# Esperar a que se asigne IP pública al LB (2-5 min)
kubectl get svc test-lb -w

# Probar desde internet
curl http://<EXTERNAL-IP>

# Limpiar
kubectl delete service test-lb
kubectl delete deployment nginx
```

### 5. Ver Métricas de Cluster

```bash
# Uso de recursos en nodos
kubectl top nodes

# Uso de pods
kubectl top pods -A
```

---

## Kubectl Commands Frecuentes

```bash
# Información del cluster
kubectl cluster-info
kubectl version --short

# Nodos
kubectl get nodes
kubectl describe node <node-name>
kubectl top nodes

# Pods
kubectl get pods                    # Namespace default
kubectl get pods -A                 # Todos los namespaces
kubectl get pods -n kube-system     # Namespace específico
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl exec -it <pod-name> -- /bin/bash

# Servicios
kubectl get svc
kubectl describe svc <service-name>
kubectl port-forward svc/<service-name> 8080:80

# Deployments
kubectl get deployments
kubectl scale deployment <name> --replicas=3
kubectl set image deployment/<name> <container>=<image>:<tag>

# Namespaces
kubectl get namespaces
kubectl create namespace <name>

# Secrets & ConfigMaps
kubectl get secrets -A
kubectl get configmaps -A
kubectl create secret generic <name> --from-literal=key=value

# Eventos
kubectl get events -A --sort-by='.lastTimestamp'

# Context y config
kubectl config get-contexts
kubectl config use-context <context-name>
```

---

## Limpieza

### Destruir Cluster

```bash
# 1. Revisar qué se va a eliminar
terraform plan -destroy

# 2. Destruir
terraform destroy -auto-approve

# Tiempo estimado: 5-10 minutos
```

### Limpieza Manual (si Terraform falla)

En OCI Console:
1. Containers & Artifacts → Kubernetes Clusters → Delete
2. Compute → Instances → Seleccionar nodos → Terminate
3. Networking → Load Balancers → Delete
4. Networking → VCN → Delete Subnets → Delete VCN

---

## Troubleshooting

### Problema 1: Nodos Quedan en Status "NotReady"

**Síntomas:**
```bash
$ kubectl get nodes
NAME                          STATUS   ROLES   AGE
oke-dev-development-node-1    NotReady  none    5m
```

**Causas:**
- Nodo aún iniciando (esperar 3-5 min)
- Problemas de conectividad de red
- Insuficiente espacio en disco

**Solución:**
```bash
# 1. Esperar a que se estabilice
kubectl get nodes -w

# 2. Validar logs del nodo
kubectl describe node <node-name>

# 3. Ver eventos
kubectl get events -A --sort-by='.lastTimestamp' | tail -20
```

### Problema 2: Pods No Se Despliegan (ImagePullBackOff)

**Síntomas:**
```bash
$ kubectl get pods
NAME                   READY   STATUS             RESTARTS   AGE
nginx-7f9c5d9b4-xyz    0/1     ImagePullBackOff   0          2m
```

**Solución:**
```bash
# 1. Validar imagen
kubectl describe pod <pod-name>

# 2. Probar con imagen pública
kubectl run test --image=nginx:latest

# 3. Si usas OCIR (Oracle Container Registry):
kubectl create secret docker-registry ocir-secret \
  --docker-server=<region>.ocir.io \
  --docker-username=<username> \
  --docker-password=<token> \
  --docker-email=<email>
```

### Problema 3: Servicio LoadBalancer Pendiente de IP

**Síntomas:**
```bash
$ kubectl get svc
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)
test-lb      LoadBalancer   10.96.1.50      <pending>     80:30123/TCP
```

**Solución:**
```bash
# 1. Esperar (OCI tarda 3-5 min en crear LB)
kubectl get svc test-lb -w

# 2. Si sigue pendiente tras 10 min:
kubectl describe svc test-lb

# 3. Ver logs del load-balancer-controller
kubectl logs -n kube-system -l app=oci-load-balancer-controller
```

### Problema 4: Flannel Pods Están CrashLoopBackOff

**Solución:**
```bash
# 1. Ver logs de Flannel
kubectl logs -n kube-system -l app=flannel -c kube-flannel --tail=50

# 2. Validar CIDR no overlap
# pods_cidr debe diferir de vcn_cidr y services_cidr

# 3. Validar kernel (en nodo):
# modprobe vxlan
# lsmod | grep vxlan
```

### Problema 5: Terraform Apply Toma Más de 15 min o Timeout

**Solución:**
```bash
# 1. Aumentar timeout
terraform apply -parallelism=1

# 2. Validar cuotas en OCI Console
oci limits list-definitions --query "data[?name=='compute'].value"

# 3. Retomar desde donde se pausó
terraform apply -auto-approve
```

---

## Siguiente Nivel

[**14 - API Gateway:** Desplegar API Gateway con políticas de rate-limit, autenticación OAuth2, y integración con funciones serverless](../14-api-gateway/)

En esta arquitectura avanzada:
- Exponer microservicios OKE a través de API Gateway público
- Implementar autenticación JWT/OAuth2
- Rate limiting y throttling por cliente
- Integración con Oracle Functions (serverless)

---

## Referencias y Documentación

### Documentación Oficial OCI

- [OKE Documentation](https://docs.oracle.com/en-us/iaas/Content/ContEng/home.htm)
- [Kubernetes Networking](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengcreatingclusterusingoke.htm)
- [OCI CLI Commands for OKE](https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/ce.html)
- [Flannel Networking](https://github.com/flannel-io/flannel)

### Documentación Kubernetes

- [Kubernetes Official Docs](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Kubernetes API Reference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/)

### Herramientas Útiles

- [Helm](https://helm.sh/) — Package manager para Kubernetes
- [Kustomize](https://kustomize.io/) — Template engine para manifests
- [Lens](https://k8slens.dev/) — IDE para Kubernetes
- [k9s](https://k9scli.io/) — Terminal UI para Kubernetes
- [kubectx/kubens](https://github.com/ahmetb/kubectx) — Cambiar contextos/namespaces fácilmente

---

## Ejemplos de Deployments

### Desplegar Nginx

```bash
kubectl create deployment nginx --image=nginx:latest
kubectl expose deployment nginx --port=80 --type=LoadBalancer
kubectl get svc nginx -w  # Esperar IP pública
curl http://<EXTERNAL-IP>
```

### Desplegar con Helm

```bash
# Instalar Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Agregar repositorio
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Desplegar MySQL
helm install mysql bitnami/mysql \
  --set auth.rootPassword=root123 \
  --set auth.database=mydb

# Ver releases
helm list
helm status mysql

# Desinstalar
helm uninstall mysql
```

---

## Contribuciones y Soporte

Encontraste un bug? Mejoras? Abre un issue:
**https://github.com/jesmonsa/oracle-cloud-latam/issues**

Para soporte empresarial, contacta a la comunidad LATAM de OCI.

---

## Licencia

Código proporcionado bajo licencia **GPL-3.0**. Úsalo libremente en tu infraestructura.

**Creado por:** Comunidad LATAM Oracle Cloud
**Mantenedor:** [@jesmonsa](https://github.com/jesmonsa)
**Última actualización:** 2026-04-12
