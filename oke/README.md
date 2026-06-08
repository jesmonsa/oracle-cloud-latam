# 🐳 Oracle Kubernetes Engine (OKE) — Catálogo de Arquitecturas de Referencia

[![Terraform 1.5+](https://img.shields.io/badge/terraform-%3E%3D%201.5-purple)](https://www.terraform.io) [![OCI Provider 6.0+](https://img.shields.io/badge/OCI%20Provider-%3E%3D%206.0-blue)](https://registry.terraform.io/providers/oracle/oci/latest) [![License](https://img.shields.io/badge/license-UPL--1.0-green)](LICENSE)

## 📌 Descripción

Este catálogo reúne arquitecturas de referencia empresariales para **Oracle Kubernetes Engine (OKE)**, el servicio completamente gestionado de Kubernetes en Oracle Cloud Infrastructure. Cada arquitectura está diseñada siguiendo las mejores prácticas de seguridad, disponibilidad y costo-eficiencia, validadas en entornos de producción latinoamericanos.

Las arquitecturas incluyen configuraciones de red de última generación, políticas de seguridad granulares, escalado automático y observabilidad integrada. Todas están documentadas, versionadas en Git y pueden desplegarse con un solo clic usando Oracle Resource Manager.

---

## 🏛️ Arquitecturas Disponibles

| # | Arquitectura | Descripción | Servicios Clave | Complejidad | Deploy |
|---|---|---|---|---|---|
| **1** | [**cluster-basico**](cluster-basico/) | OKE cluster de referencia con Flannel CNI, topología de 3 subnets y single node pool. Punto de partida ideal. | OKE, VCN, NAT GW, SGW | **Básica** | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/oke-cluster-basico.zip) |
| **2** | [**multi-nodepool**](multi-nodepool/) | Cluster heterogéneo con 2 node pools (E4 x86 + A1 ARM). Costo-reducción con shapes ARM Ampere. | OKE, Flex Shapes, Multi-Arch | **Intermedia** | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/oke-multi-nodepool.zip) |
| **3** | [**ingress-nginx**](ingress-nginx/) | Ingress Controller NGINX con cert-manager y auto-renovación de certificados TLS via Let's Encrypt. | NGINX, cert-manager, TLS | **Intermedia** | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/oke-ingress-nginx.zip) |
| **4** | [**oke-lb-service**](oke-lb-service/) | Service Load Balancer con integración nativa OCI LB, annotations y SSL termination. | OCI LB, K8s Service | **Intermedia** | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/oke-lb-service.zip) |
| **5** | [**persistent-volumes-block**](persistent-volumes-block/) | Block Volume storage con CSI driver, snapshots y disaster recovery cross-AD. | OCI BV, CSI, Snapshots | **Intermedia** | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/oke-pv-block.zip) |
| **6** | [**persistent-volumes-fss**](persistent-volumes-fss/) | File Storage Service (NFS) para PVs compartidos ReadWriteMany con HA. | OCI FSS, NFS, Mount Target | **Intermedia** | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/oke-pv-fss.zip) |
| **7** | [**oke-ocir-registry**](oke-ocir-registry/) | Private container registry con OCIR, ImagePullSecret y namespace isolation. | OCIR, Docker, K8s Secrets | **Intermedia** | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/oke-ocir-registry.zip) |
| **8** | [**virtual-nodes**](virtual-nodes/) | Virtual Nodes para cargas serverless sin gestión de infraestructura (OCI Container Instances). | OKE Enhanced, Virtual Nodes | **Avanzada** | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/oke-virtual-nodes.zip) |
| **9** | [**cluster-autoscaler**](cluster-autoscaler/) | Escalado automático de node pools con métricas CPU/RAM + HPA. | Cluster Autoscaler, HPA | **Avanzada** | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/oke-cluster-autoscaler.zip) |
| **10** | [**observabilidad-oke**](observabilidad-oke/) | Stack completo: Prometheus + Grafana + Loki + AlertManager integrados con OCI Monitoring. | Prometheus, Grafana, Loki | **Avanzada** | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/oke-observabilidad.zip) |

---

## 🔗 Topología Común de Red OKE

La siguiente arquitectura de red es común a todas nuestras referencias OKE. Proporciona aislamiento de tráfico, seguridad granular y soporte para traffic shaping.

```
                               INTERNET
                                  │
                           ┌──────▼──────┐
                           │   IGW       │
                           │   ┌───────┐ │
                           │   │ NAT   │ │
                           │   └─┬─────┘ │
                           └─────┼───────┘
                                 │
                    ┌────────────┼────────────┐
                    │            │            │
          ┌─────────▼──────┐  ┌──▼───────────┐
          │ Subnet Pública │  │  Subnet      │
          │ API Endpoint   │  │  Pública LB  │
          │ /28 (4 IPs)    │  │  /24 (252IP) │
          └────────────────┘  └──────────────┘
                    │            │
                    └────────────┼────────────┐
                                 │
                           ┌─────▼────────┐
                           │ NAT Gateway  │
                           │ SGW          │
                           └─────┬────────┘
                                 │
                    ┌────────────▼──────────┐
                    │ Subnet Privada       │
                    │ Worker Nodes         │
                    │ /24 (252 IPs)        │
                    │                      │
                    │ Node Pool(s):        │
                    │ - Flex Shapes (E4+)  │
                    │ - Standard/Optimized │
                    │ - ARM (A1 Ampere)    │
                    └──────────────────────┘
```

**Detalles:**
- **Subnet API Endpoint (Pública)**: Acceso directo de Internet al API endpoint del cluster. Protegida con NSGs granulares (puertos HTTPS 6443 restringidos).
- **Subnet LB (Pública)**: Para Load Balancers de servicio tipo "LoadBalancer". Permite exponer servicios Kubernetes a Internet.
- **Subnet Worker Nodes (Privada)**: Nodos de cómputo con egreso a Internet a través de NAT Gateway y acceso privado a servicios OCI via Service Gateway.
- **NAT Gateway**: Egreso de tráfico saliente desde nodos privados hacia Internet (sin IP pública).
- **Service Gateway**: Acceso privado a servicios OCI como Object Storage, Autonomous Database sin salir de la VCN.

---

## 💪 Shapes Soportados en OKE

| Shape | Arquitectura | vCPU | Memoria (GB) | Casos de Uso | Costo Mensual* |
|---|---|---|---|---|---|
| **VM.Standard.E4.Flex** | x86-64 (EPYC) | 0.5-12 | 1-65 | Propósito general, Dev/Test | Desde $0.025/hr |
| **VM.Standard.E5.Flex** | x86-64 (EPYC)| 0.5-12 | 1-65 | Cargas balanceadas, Prod | Desde $0.035/hr |
| **VM.Standard.E6.Flex** | x86-64 (EPYC)| 0.5-16 | 1-128 | Workloads de alto rendimiento | Desde $0.050/hr |
| **VM.Standard.A1.Flex** | ARM64 (Ampere) | 0.5-80 | 0.5-480 | Costo-optimizado, Linux | Desde $0.008/hr |
| **VM.Standard.X9.Flex** | x86-64 (Xeon) | 0.5-16 | 1-128 | HPC, Big Data, ML | Desde $0.085/hr |
| **VM.Standard3.Flex** | x86-64 (EPYC)| 0.5-16 | 1-256 | Memory-intensive workloads | Desde $0.042/hr |

*Precios indicativos en región São Paulo (sp-saopaulo-1). El control plane de OKE siempre es **GRATUITO**.

---

## 📋 Prerequisitos Globales

Para desplegar cualquier arquitectura OKE de este catálogo, necesitas:

### Cuenta y Permisos
- ✅ Cuenta activa en Oracle Cloud Infrastructure
- ✅ Usuario con rol **Tenancy Administrator** o permisos específicos para:
  - `oke:` (OKE cluster, node pools, cluster networks)
  - `vcn:` (VCN, subnets, security groups, gateways)
  - `compute:` (Instances para node pools)
  - `identity:` (Dynamic Groups para IMDS v2)

### Herramientas Locales
- ✅ **Terraform 1.5+** ([Descargar](https://www.terraform.io/downloads))
- ✅ **OCI CLI 3.0+** ([Descargar](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cliapiintro.htm))
- ✅ **kubectl 1.28+** ([Descargar](https://kubernetes.io/docs/tasks/tools/))
- ✅ **Git** (para clonar el repositorio)

### Configuración OCI
```bash
oci setup config
# Completa con: tenancy OCID, user OCID, private key path, key fingerprint, region
```

---

## 🚀 Inicio Rápido

### Opción 1: Desplegar con Un Clic (Recomendado)

1. Elige una arquitectura de la tabla anterior y haz clic en el botón **Deploy**
2. Oracle Resource Manager abrirá automáticamente en tu consola OCI
3. Revisa los valores de variables y ajusta según tus necesidades
4. Haz clic en **Create** → **Apply** → **Confirm**
5. Espera 8-15 minutos mientras Terraform despliega los recursos
6. Una vez completado, obtén el kubeconfig en los outputs de la pila

```bash
# Descargar kubeconfig después del despliegue
oci ce cluster create-kubeconfig --cluster-id <cluster_ocid> --file $HOME/.kube/config
```

### Opción 2: Desplegar con Terraform CLI

```bash
# 1. Clonar repositorio
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/oke/cluster-basico

# 2. Inicializar Terraform
terraform init

# 3. Revisar configuración
cp terraform.tfvars.example terraform.tfvars
# Edita terraform.tfvars con tu compartment_ocid y región

# 4. Desplegar
terraform apply

# 5. Obtener kubeconfig
terraform output kubeconfig > ~/.kube/config && chmod 600 ~/.kube/config

# 6. Verificar conexión
kubectl get nodes
```

### Opción 3: Despliegue via OCI CLI

```bash
# Stack ID será retornado en deployment automático
STACK_ID="ocid1.ormstack.oc1.sp..."

# Monitor del despliegue
oci resource-manager stack list-resource-types --stack-id $STACK_ID

# Una vez completado
oci ce cluster create-kubeconfig --cluster-id $CLUSTER_ID
```

---

## 🔐 Seguridad y Compliance

Todas las arquitecturas de este catálogo incluyen:

- ✅ **Network Security Groups (NSGs)** con reglas granulares (no Security Lists anticuadas)
- ✅ **API Endpoint privado o público** según necesidad
- ✅ **Kubelet protegido**: acceso restringido a puerto 10250
- ✅ **RBAC habilitado** por defecto (Kubernetes 1.24+)
- ✅ **Pod Security Standards** (restricción de privilegios)
- ✅ **Egreso mediante NAT Gateway** (no IP pública en workers)
- ✅ **Service Gateway** para acceso privado a OCI services (storage, DB, etc.)
- ✅ **Soporte para Cloud Guard** (detección de amenazas automática)
- ✅ **Logging y Auditoría** integrados con OCI Logging

---

## 💰 Estimación de Costos

### Ejemplo: cluster-basico (Region São Paulo)

| Componente | Qty | Precio Unitario | Subtotal |
|---|---|---|---|
| OKE Control Plane | 1 | **GRATIS** | $0 |
| Nodos E4.Flex (2vCPU, 16GB RAM) | 3 | $0.081/hr | ~$59.40/mes |
| VCN y Gateways | 1 | $0.04/mes | $0.04 |
| **Total Estimado** | | | **~$60/mes** |

*Con Always Free tier activo, nodos E4.Flex pequeños (0.5-2 vCPU) pueden entrar en free tier*.

### Costo de multi-nodepool

| Componente | Qty | Precio Unitario | Subtotal |
|---|---|---|---|
| OKE Control Plane | 1 | **GRATIS** | $0 |
| Node Pool x86 (E4.Flex) | 3 | $0.081/hr | ~$59.40/mes |
| Node Pool ARM (A1.Flex) | 3 | $0.008/hr | ~$5.76/mes |
| VCN y Gateways | 1 | $0.04/mes | $0.04 |
| **Total Estimado** | | | **~$65/mes** |

---

## 🤝 Arquitecturas Relacionadas

Próximamente se integrarán con estas arquitecturas base de OCI Latinoamérica:

- **[Fundamentos de Red - VCN Multi-Región](../arquitecturas-v2/01-fundamentos-webserver/)**
- **[Load Balancer HA](../arquitecturas-v2/03-load-balancer-ha/)**
- **[Base de Datos Managed (ODB/OCDB)](../arquitecturas-v2/06-base-de-datos/)**
- **[Almacenamiento Compartido (FSS)](../arquitecturas-v2/05-almacenamiento-compartido/)**

---

## 📚 Recursos y Enlaces Útiles

### Documentación Oficial
- [Oracle Kubernetes Engine Docs](https://docs.oracle.com/en-us/iaas/Content/ContEng/home.htm)
- [OKE Best Practices](https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengbestpractices.htm)
- [OKE Network Architecture](https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengnetworkconfig.htm)

### Terraform Registry
- [OCI Provider Documentation](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)

### Comunidad y Soporte
- [OKE Public Slack Channel](https://oracledevrel.slack.com/)
- [Oracle Architecture Center - Kubernetes](https://www.oracle.com/cloud/architecture-center/)
- [FoggyKitchen OKE Examples](https://github.com/mlinxfeld/foggykitchen-oke)

---

## 📖 Cómo Contribuir

¿Tienes una arquitectura OKE innovadora? ¡Nos encantaría incluirla! Por favor:

1. Fork este repositorio
2. Crea una rama `feature/nueva-arquitectura`
3. Sigue los lineamientos de la carpeta `_template/`
4. Abre un Pull Request

---

## 📄 Licencia y Atribuciones

Este catálogo está bajo la licencia **UPL-1.0** (Universal Permissive License v1.0).

Basado en el trabajo de [Martin Linxfeld / FoggyKitchen](https://foggykitchen.com), adaptado, traducido y mejorado para el mercado latinoamericano bajo la supervisión arquitectónica de **Jesús Monsa**, Oracle Cloud Architect en Oracle Colombia.

---

**Última actualización:** Abril 2026 | **Versión:** 1.0.0
