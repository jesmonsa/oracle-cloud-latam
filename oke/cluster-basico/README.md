# 🐳 OKE Cluster Básico — Arquitectura de Referencia

[![Terraform 1.5+](https://img.shields.io/badge/terraform-%3E%3D%201.5-purple)](https://www.terraform.io) [![OCI Provider 6.0+](https://img.shields.io/badge/OCI%20Provider-%3E%3D%206.0-blue)](https://registry.terraform.io/providers/oracle/oci/latest) [![OKE](https://img.shields.io/badge/OKE-Managed%20Kubernetes-orange)](https://www.oracle.com/cloud/kubernetes-engine/) [![Flannel CNI](https://img.shields.io/badge/CNI-Flannel-yellowgreen)](https://github.com/coreos/flannel) [![License](https://img.shields.io/badge/license-UPL--1.0-green)](LICENSE)

## ☁️ Desplegar con un Clic

[![Desplegar en Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/oke-cluster-basico.zip)

> Requiere una cuenta activa en Oracle Cloud Infrastructure. [Crear cuenta gratuita (300 USD de créditos)](https://www.oracle.com/cloud/free/)

---

## 📖 Descripción

Esta arquitectura de referencia despliega un **cluster OKE empresarial completamente funcional** con configuración de red de tres subnets, CNI Flannel, y single node pool con shapes Flex. Es la arquitectura ideal para:

- ✅ **Aprender Kubernetes en OCI** con una topología profesional
- ✅ **Dev/Test environments** que requieren networking aislado
- ✅ **POC y evaluaciones** de cargas Kubernetes
- ✅ **Clusters pequeños** con presupuesto de laboratorio
- ✅ **Punto de entrada** antes de escalar a multi-nodepool o multi-región

**Qué incluye:**
- VCN con 3 subnets (API endpoint pública, Load Balancer pública, Worker nodes privada)
- 3 NSGs (Network Security Groups) con reglas granulares e inmutables
- OKE cluster con Flannel CNI, versión estable de Kubernetes
- Single node pool con Flex shapes (E4, E5 o E6)
- NAT Gateway y Service Gateway para egreso seguro
- Kubeconfig completamente configurado y listo para usar

**Complejidad:** Básica (80% automatizada, 20% conceptual)

---

## 🏗️ Diagrama de Arquitectura

```
┌──────────────────────────────────────────────────────────────────┐
│                          INTERNET                                │
└────────────────────────────┬─────────────────────────────────────┘
                             │ BGP/Routing
                    ┌────────▼────────┐
                    │   IGW           │
                    │ Internet Gateway│
                    └────────┬────────┘
                             │
            ┌────────────────┼─────────────────┐
            │                │                 │
   ┌────────▼─────┐ ┌────────▼─────┐ ┌───────▼──────┐
   │ Subnet API   │ │ Subnet LB    │ │ Subnet NODES │
   │ (Pública)    │ │ (Pública)    │ │ (Privada)    │
   │ /28          │ │ /24          │ │ /24          │
   │              │ │              │ │              │
   │ OKE API      │ │ SVC LB       │ │ OKE Workers  │
   │ Endpoint     │ │ Ingress      │ │ (Pods)       │
   └──────────────┘ └──────────────┘ │              │
                                    │              │
                                    │ Node Pool:   │
                                    │ - E4.Flex    │
                                    │ - E5.Flex    │
                                    │ - E6.Flex    │
                                    └──────────────┘
                                            │
                                    ┌───────▼────────┐
                                    │ NAT Gateway    │
                                    │ Service GW     │
                                    └───────┬────────┘
                                            │
                                    (Egreso a OCI services)
                                    (Object Storage, etc)

          ┌─────────────────────────────────────────┐
          │    Network Security Groups (NSGs)       │
          ├─────────────────────────────────────────┤
          │ NSG-API:                                │
          │  - Ingress 6443/TCP from 0.0.0.0/0     │
          │  - Egress allow all                     │
          │                                         │
          │ NSG-NODES:                              │
          │  - Ingress 10250/TCP (kubelet)         │
          │  - Ingress vxlan ports (peer nodes)    │
          │  - Egress to 0.0.0.0/0(NAT GW)        │
          │                                         │
          │ NSG-LB:                                 │
          │  - Ingress 80,443 from 0.0.0.0/0       │
          │  - Egress to node subnet (targets)     │
          └─────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                 OKE CLUSTER (Control Plane FREE)                 │
├──────────────────────────────────────────────────────────────────┤
│ ✓ API Server (6443)                                              │
│ ✓ Scheduler, Controller Manager                                  │
│ ✓ etcd (encrypted at rest)                                       │
│ ✓ Admission Controllers (Pod Security Policies)                  │
│ ✓ RBAC enabled by default                                        │
│ ✓ Flannel CNI (cross-node pod networking)                        │
│ ✓ Logging & Monitoring integrated                                │
└──────────────────────────────────────────────────────────────────┘
```

---

## 📦 Componentes Desplegados

| Recurso | Servicio OCI | Descripción | Notas |
|---|---|---|---|
| **VCN** | `oci_core_vcn` | Virtual Cloud Network (RFC1918 10.0.0.0/16) | Aislamiento de red, múltiples ADs |
| **Internet Gateway** | `oci_core_internet_gateway` | Acceso bidireccional Internet ↔ VCN | Solo para API y LB públicos |
| **NAT Gateway** | `oci_core_nat_gateway` | Egreso de nodos sin IP pública | Reduce costos, mejora seguridad |
| **Service Gateway** | `oci_core_service_gateway` | Acceso privado a servicios OCI | Object Storage, OCDB, etc. |
| **Subnet API** | `oci_core_subnet` | Pública /28 para OKE API endpoint | 4 IPs disponibles |
| **Subnet LB** | `oci_core_subnet` | Pública /24 para LoadBalancer services | 252 IPs, redundancia ADs |
| **Subnet Nodes** | `oci_core_subnet` | Privada /24 para worker nodes | 252 IPs, escala horizontal |
| **NSG API** | `oci_core_network_security_group` | Reglas granulares puerto 6443 | HTTPS only, TCP no UDP |
| **NSG Nodes** | `oci_core_network_security_group` | Kubelet, vxlan, egreso | Peer-to-peer entre nodos |
| **NSG LB** | `oci_core_network_security_group` | HTTP/HTTPS de Internet | Soporte para Ingress Controllers |
| **Route Table** | `oci_core_route_table` | Tráfico saliente → NAT GW / SGW | Dinámico según destino |
| **OKE Cluster** | `oci_containerengine_cluster` | Control plane Kubernetes | Versión 1.27-1.28, fully managed |
| **Node Pool** | `oci_containerengine_node_pool` | Worker nodes Flex | 3 nodos por defecto, escalable |

---

## ⚙️ Variables de Configuración

| Variable | Descripción | Valor Defecto | Requerida | Tipo |
|---|---|---|---|---|
| `compartment_ocid` | OCID del compartment de despliegue | | ✅ | string |
| `region` | Región OCI (ej: us-phoenix-1) | `us-ashburn-1` | ✅ | string |
| `availability_domain` | AD para nodos (ej: AD 1, 2, o 3) | `AD-1` | | string |
| `proyecto` | Prefijo para nombres de recursos | `mio` | ✅ | string |
| `ambiente` | Env tag (desarrollo, staging, produccion) | `desarrollo` | | string |
| **VCN Config** | | | | |
| `vcn_cidr` | CIDR block VCN | `10.0.0.0/16` | | string |
| `subnet_api_cidr` | CIDR subnet API endpoint | `10.0.1.0/28` | | string |
| `subnet_lb_cidr` | CIDR subnet Load Balancer | `10.0.2.0/24` | | string |
| `subnet_nodes_cidr` | CIDR subnet worker nodes | `10.0.3.0/24` | | string |
| **OKE Config** | | | | |
| `oke_kubernetes_version` | Versión de K8s | `v1.28.2` | | string |
| `oke_cluster_name` | Nombre del cluster | `${proyecto}-oke-${ambiente}` | | string |
| `kubernetes_api_endpoint_public` | API endpoint público | `true` | | bool |
| `oke_cni_type` | Flannel o FLANNEL_NATIVE | `FLANNEL` | | string |
| **Node Pool Config** | | | | |
| `node_pool_name` | Nombre del node pool | `${proyecto}-nodepool` | | string |
| `node_pool_size` | Cantidad de nodos | `3` | | number |
| `node_shape` | Flex shape (E4, E5, E6) | `VM.Standard.E4.Flex` | | string |
| `node_ocpus` | vCPU por nodo Flex | `2` | | number |
| `node_memory_gb` | Memoria RAM por nodo Flex | `16` | | number |
| `image_id` | Image OCID (auto-selecciona latest) | | | string |
| **Etiquetas** | | | | |
| `tags_common` | Etiquetas aplicadas a todos los recursos | `{Name = proyecto}` | | map(string) |
| `lifecycle_state` | Habilitar ciclo de vida de recursos | `AVAILABLE` | | string |

---

## 📤 Outputs

Después del despliegue, Terraform muestra:

| Output | Descripción | Ejemplo |
|---|---|---|
| `cluster_id` | OCID del cluster OKE | `ocid1.cluster.oc1.phx...` |
| `cluster_name` | Nombre del cluster | `mio-oke-desarrollo` |
| `kubernetes_api_endpoint` | URL de acceso al API | `https://10.0.1.x:6443` |
| `node_pool_id` | OCID del node pool | `ocid1.nodepool.oc1.phx...` |
| `kubeconfig` | Archivo kubeconfig YAML | `(contenido completo)` |
| `vcn_id` | OCID de la VCN | `ocid1.vcn.oc1.phx...` |
| `subnet_api_id` | ID subnet API endpoint | `ocid1.subnet.oc1.phx...` |
| `subnet_lb_id` | ID subnet Load Balancer | `ocid1.subnet.oc1.phx...` |
| `subnet_nodes_id` | ID subnet worker nodes | `ocid1.subnet.oc1.phx...` |
| `kubectl_config_command` | Comando para descargar kubeconfig | `oci ce cluster create-kubeconfig...` |

---

## 💰 Costo Estimado

### Precios en Región São Paulo (sp-saopaulo-1)

**Configuración por defecto (3 nodos E4.Flex, 2vCPU / 16GB RAM)**

| Componente | Cantidad | Precio Unitario | Subtotal Mensual |
|---|---|---|---|
| **OKE Control Plane** | 1 cluster | **GRATIS** | **$0.00** |
| **Worker Nodes (E4.Flex 2vCPU/16GB)** | 3 | $0.081/hora | $59.40 |
| **Data Transfer (Egreso)** | ~100 GB/mes | $0.04/GB | $4.00 |
| **NAT Gateway** | 1 | $0.045/hora | $32.76 |
| **VCN, Subnets, NSGs** | 1 | Gratis | $0.00 |
| **Service Gateway** | 1 | Gratis | $0.00 |
| **DNS, Load Balancer (solo tráfico)** | On-demand | $0.0035/millón req | ~$1.00 |
| | | **TOTAL MENSUAL** | **~$97.16** |

### Optimizaciones de Costo

1. **Always Free Tier**: Nodos con configuración mínima (0.5 vCPU, 1 GB RAM) pueden ser gratuitos
   - Actualiza `node_ocpus = 0.5` y `node_memory_gb = 1`
   - Costo reducido a ~$5-10/mes

2. **ARM Ampere (A1)**: 80% más económico que x86
   - Requiere imágenes de SO Linux ARM
   - Costo reducido a ~$15/mes

3. **Spot Instances**: Preemptible compute (no aplicable a OKE workers)

4. **Reserved Capacity**: Compromisos de 1 año = 30% descuento
   - Requiere volúmenes mínimos garantizados

---

## 🚀 Despliegue

### Opción 1: Oracle Resource Manager (Un clic, Recomendado)

1. Haz clic en el botón **Deploy** arriba ⬆️
2. Inicia sesión en Oracle Cloud Console
3. Resource Manager abrirá automáticamente
4. **Revisa** las variables (compartment, región, shape)
5. Haz clic en **Create** para crear la pila
6. Luego **Apply** para desplegar
7. **Confirma** en el diálogo de confirmación
8. Espera 8-15 minutos hasta "Job succeeded"

#### Post-Despliegue con Resource Manager:
```bash
# 1. Ve a la consola OCI → Resource Manager → Stacks
# 2. Selecciona tu stack → Outputs
# 3. Copia el valor de "kubeconfig"
# 4. Guarda en archivo
mkdir -p ~/.kube
echo '<PEGA_KUBECONFIG_AQUI>' > ~/.kube/config
chmod 600 ~/.kube/config

# 5. Verifica la conexión
kubectl cluster-info
kubectl get nodes
kubectl get ns
```

---

### Opción 2: Terraform CLI (Máximo control)

#### Paso 1: Clonar y preparar

```bash
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/oke/cluster-basico

# Copiar template de variables
cp terraform.tfvars.example terraform.tfvars

# Editar con tus valores
nano terraform.tfvars
# Completa:
# - compartment_ocid (copia de tu tenancy)
# - region (tu región preferida)
# - proyecto (nombre único)
```

#### Paso 2: Inicializar Terraform

```bash
terraform init
```

#### Paso 3: Revisar plan

```bash
terraform plan -out=tfplan
# Verifica que vaya a crear: 1 VCN, 3 subnets, 1 cluster, 1 node pool, etc.
```

#### Paso 4: Aplicar cambios

```bash
terraform apply tfplan
# Toma 8-15 minutos. Monitorea la consola OCI.
```

#### Paso 5: Obtener kubeconfig

```bash
# Opción A: Desde outputs
terraform output -raw kubeconfig > ~/.kube/config
chmod 600 ~/.kube/config

# Opción B: Via OCI CLI
CLUSTER_OCID=$(terraform output -raw cluster_id)
oci ce cluster create-kubeconfig --cluster-id $CLUSTER_OCID --file ~/.kube/config
```

#### Paso 6: Verificar acceso

```bash
kubectl cluster-info
kubectl get nodes
kubectl get deployment -A
```

---

### Opción 3: OCI CLI (Para Automation)

```bash
# Crear stack
STACK_ID=$(oci resource-manager stack create \
  --compartment-id ocid1.compartment.oc1... \
  --display-name "oke-cluster-basico" \
  --zip-file-url https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/oke-cluster-basico.zip \
  --query 'data.id' --raw-output)

# Monitor
oci resource-manager job create \
  --stack-id $STACK_ID \
  --operation APPLY \
  --wait
```

---

## 🔧 Tareas Post-Despliegue

Una vez que el cluster está operativo:

### 1. Instalar Ingress Controller (NGINX)
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

# Esperar a que obtenga IP pública
kubectl get svc -n ingress-nginx
```

### 2. Instalar Cert-Manager (TLS)
```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml
```

### 3. Desplegar Aplicación Test
```bash
# Crear namespace
kubectl create namespace demo

# Deploy simple
kubectl apply -n demo -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-world
spec:
  replicas: 3
  selector:
    matchLabels:
      app: hello
  template:
    metadata:
      labels:
        app: hello
    spec:
      containers:
      - name: app
        image: oraclelinux:9-slim
        command: ["/bin/sh", "-c"]
        args: ["echo 'Hello from OKE!' && sleep 3600"]
EOF

# Verificar
kubectl get pods -n demo
```

### 4. Configurar Monitoring
```bash
# OKE incluye integración con OCI Monitoring por defecto
# Acceder en: OCI Console → Observability & Management → Monitoring → Metrics

# Opcional: Prometheus/Grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

---

## 🧹 Limpieza y Destrucción

### Con Terraform CLI

```bash
# Revisar qué se va a destruir
terraform plan -destroy

# Destruir recursos
terraform destroy

# Confirma "yes" cuando se solicite
```

### Con Oracle Resource Manager

1. Consola OCI → Resource Manager → Stacks
2. Selecciona tu stack
3. Botón **Destroy** (arriba a la derecha)
4. Confirma en el diálogo

**Nota:** La destrucción toma 3-5 minutos. Se eliminarán:
- ✅ OKE cluster (todos los pods se pierden)
- ✅ VCN y subnets
- ✅ NAT y Service Gateways
- ✅ Network Security Groups
- ✅ Node pool (instancias compute)

Los datos en Object Storage o Autonomous Database (si existían) se preservan.

---

## 🔐 Consideraciones de Seguridad

Esta arquitectura implementa:

- ✅ **NSGs Granulares**: No Security Lists heredadas (deprecated)
- ✅ **Kubelet privado**: Acceso al puerto 10250 solo desde nodes
- ✅ **RBAC habilitado**: Por defecto, roles estándar de K8s
- ✅ **Pod Security Standards**: Restricción de permisos privilegiados
- ✅ **API endpoint público**: Controlable via variable `kubernetes_api_endpoint_public`
- ✅ **Egreso sin IP pública**: Workers detrás de NAT Gateway
- ✅ **Service Gateway**: Acceso privado a Object Storage sin Internet
- ✅ **Encryption at rest**: Etcd cifrado automáticamente
- ✅ **Cloud Guard**: Detección de amenazas (opcional, habilitado por default)
- ✅ **Audit logging**: Todos los API calls se registran en OCI Logging

### Hardening Recomendado (Post-Deploy)

```bash
# 1. Habilitar Network Policies (aislamiento de pods)
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF

# 2. Usar RBAC estricto (no usar default service account)
kubectl create serviceaccount app-user
kubectl create role app-role --verb=get,list --resource=pods
kubectl create rolebinding app-binding --role=app-role --serviceaccount=default:app-user

# 3. Pod Security Policy (K8s 1.25+)
# Deprecated a favor de Pod Security Standards
```

---

## 📊 Monitoreo y Observabilidad

### Integración Nativa OCI Monitoring

```bash
# Los nodos reportan métricas de CPU, memoria, disk automáticamente
# Acceder en: OCI Console → Observability → Metrics

# Métricas disponibles:
# - oci_computeinstances_cpu_utilization
# - oci_computeinstances_memory_utilization
# - oci_containerengine_cluster_state
```

### Kubernetes Metrics Server

```bash
# Verificar que está instalado
kubectl get deployment metrics-server -n kube-system

# Ver uso de recursos
kubectl top nodes
kubectl top pods -A
```

### Logs

```bash
# Ver logs del node pool
kubectl logs -n kube-system -l component=kubelet --tail=100

# OCI Logging (si está habilitado)
# Console → Logging → Log Groups → OKE cluster logs
```

---

## 🔗 Arquitecturas Relacionadas

Una vez domines esta arquitectura básica, considera escalar a:

| Arquitectura | Descripción | Cuándo Usar |
|---|---|---|
| **[multi-nodepool](../multi-nodepool/)** | Clusters con 2+ node pools heterogéneos (x86 + ARM) | Cargas de trabajo diversas, optimización de costos |
| **[oke-lb-service](../../)** (próxima) | Service LoadBalancer nativo con OCI LB | Exponer apps HTTP/HTTPS a Internet |
| **[ingress-nginx](../../)** (próxima) | Ingress Controller + Cert-Manager | Enrutamiento L7, SSL/TLS, dominios múltiples |
| **[persistent-volumes](../../)** (próxima) | Block Volumes y FSS como storage persistente | Bases de datos, almacenamiento compartido |
| **[observabilidad-oke](../../)** (próxima) | Prometheus, Grafana, Loki completo | Monitoreo y logging avanzado |

---

## ❓ Preguntas Frecuentes (FAQ)

**P: ¿Cuánto cuesta el control plane de OKE?**
R: GRATIS. Solo pagas por los worker nodes (compute instances). El control plane está completamente gestionado por Oracle.

**P: ¿Puedo usar Always Free tier?**
R: Sí, pero solo con shapes muy pequeñas (0.5 vCPU, 1-2 GB RAM). No es práctico para producción. Actualiza las variables `node_ocpus` y `node_memory_gb`.

**P: ¿Cómo escalo el número de nodos?**
R: Con Terraform: `node_pool_size = 5`. O manualmente en OCI Console → Kubernetes Clusters → Node Pools → Edit.

**P: ¿Puedo cambiar el shape después de crear el cluster?**
R: Los nodos existentes mantienen su shape. Para cambiar, debes recrear el node pool o agregar un nuevo pool.

**P: ¿Soporta múltiples node pools (heterogéneos)?**
R: Sí, pero eso es una arquitectura más avanzada. Ver [multi-nodepool](../multi-nodepool/).

**P: ¿Cómo hago backup de la configuración del cluster?**
R: El kubeconfig se guarda en los outputs. Backupea también tus manifiestos YAML en Git:
```bash
kubectl get all -A -o yaml > cluster-backup.yaml
```

**P: ¿Puedo hacer multi-región?**
R: Sí, pero requiere replicación manual. Terraform permite crear stacks en múltiples regiones con el mismo código.

---

## 📚 Recursos Adicionales

### Documentación Oficial
- [Oracle Kubernetes Engine Official Docs](https://docs.oracle.com/en-us/iaas/Content/ContEng/home.htm)
- [OCI Terraform Provider - OKE Resources](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_cluster)
- [Kubernetes Official Documentation](https://kubernetes.io/docs/)

### Guías Relacionadas
- [OKE Best Practices](https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengbestpractices.htm)
- [Network Architecture for OKE](https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengnetworkconfig.htm)
- [OKE Security Best Practices](https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengvulnerabilities.htm)

### Herramientas Complementarias
- [kubectx - Switch contexts quickly](https://github.com/ahmetb/kubectx)
- [Lens - Kubernetes IDE](https://k8slens.dev/)
- [K9s - Terminal UI para K8s](https://k9scli.io/)

### Comunidad
- [Oracle Cloud Slack - OKE Channel](https://oracledevrel.slack.com/messages/C01DDL93W0N)
- [FoggyKitchen OKE Repo](https://github.com/mlinxfeld/foggykitchen-oke)
- [Oracle Architecture Center](https://www.oracle.com/cloud/architecture-center/)

---

## 📄 Licencia y Atribuciones

Esta arquitectura está bajo licencia **UPL-1.0** (Universal Permissive License).

Basado en el excelente trabajo de [Martin Linxfeld / FoggyKitchen](https://foggykitchen.com). Traducido, mejorado y adaptado para el mercado latinoamericano por **Jesús Monsa**, Oracle Cloud Architect.

---

**Última actualización:** Abril 2026 | **Versión:** 1.0.0 | **Estado:** Production Ready
