<p align="center">
  <img src="docs/logo.png" alt="Oracle Cloud LATAM" width="200"/>
</p>

<h1 align="center">Oracle Cloud Infrastructure — Arquitecturas de Referencia</h1>

<p align="center">
  <strong>Infraestructura como Código para Latinoamérica</strong><br>
  Módulos reutilizables, arquitecturas progresivas y templates de producción — todo en español.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Terraform-1.5%2B-623CE4?logo=terraform&logoColor=white" alt="Terraform">
  <img src="https://img.shields.io/badge/OCI_Provider-6.0%2B-F80000?logo=oracle&logoColor=white" alt="OCI Provider">
  <img src="https://img.shields.io/badge/Idioma-Espa%C3%B1ol-green" alt="Español">
  <img src="https://img.shields.io/badge/Licencia-UPL--1.0-blue" alt="Licencia">
  <img src="https://img.shields.io/badge/Shapes-E4%20%7C%20E5%20%7C%20E6%20%7C%20A1%20%7C%20X9-orange" alt="Shapes">
</p>

---

## Estructura del Proyecto

```
.
├── modulos/                        Módulos Terraform reutilizables
│   ├── red/                        VCN, Load Balancer, Bastion, Peering
│   ├── computo/                    Webserver (E4/E5/E6/A1/X9 Flex)
│   ├── seguridad/                  NSG, Vault, Baselines
│   ├── almacenamiento/             FSS, Block Volumes
│   └── base-de-datos/              DBSystem, DataGuard
│
├── arquitecturas-v2/               Arquitecturas progresivas (01 → 17)
│   ├── 01-fundamentos-webserver    Webserver simple con buenas prácticas
│   ├── ...                         Progresión gradual de complejidad
│   └── 17-arquitectura-completa    Integración de todos los servicios
│
├── oke/                            Arquitecturas OKE (10 arquitecturas)
│   ├── cluster-basico/             Cluster OKE con Flannel CNI
│   ├── multi-nodepool/             Node Pools heterogéneos (x86 + ARM)
│   ├── ingress-nginx/              NGINX + cert-manager + TLS
│   ├── oke-lb-service/             Service LB nativo OCI
│   ├── persistent-volumes-block/   Block Volume CSI + Snapshots
│   ├── persistent-volumes-fss/     FSS NFS ReadWriteMany
│   ├── oke-ocir-registry/          Container Registry OCIR
│   ├── virtual-nodes/              Virtual Nodes serverless
│   ├── cluster-autoscaler/         Autoscaling de Node Pools
│   └── observabilidad-oke/         Prometheus + Grafana + Loki
│
├── serverless/                     Serverless (5 arquitecturas)
│   ├── functions-basico/           Functions + API Gateway
│   ├── functions-api-crud/         Functions + ADB REST CRUD
│   ├── event-driven/               Events → Functions → ONS
│   ├── streaming-kafka/            Streaming Kafka + Functions
│   └── functions-container/        Functions Docker custom
│
├── datos/                          Plataforma de Datos (5 arquitecturas)
│   ├── autonomous-db/              Autonomous DB ATP/ADW
│   ├── mysql-heatwave/             MySQL HeatWave Analytics
│   ├── nosql/                      OCI NoSQL Database
│   ├── data-integration/           Data Integration ETL/ELT
│   └── golden-gate/                GoldenGate replicación
│
├── devops/                         CI/CD y DevOps (4 arquitecturas)
│   ├── devops-pipeline/            OCI DevOps Repo → Build → Deploy
│   ├── artifact-registry/          Artifact + Container Registry
│   ├── gitops-argocd/              ArgoCD GitOps en OKE
│   └── terraform-cloud/            Terraform Cloud + OCI
│
├── ai/                             IA / ML (5 arquitecturas)
│   ├── data-science/               Data Science Platform
│   ├── ai-vision/                  AI Vision
│   ├── ai-language/                AI Language NLP
│   ├── generative-ai/              Generative AI + RAG
│   └── gpu-cluster/                GPU A10/A100 + RDMA
│
└── tracks/                         Deep-dives (legacy)
```

---

## Arquitecturas Progresivas v2

Recorrido de cero a arquitectura completa. Cada arquitectura construye sobre la anterior, introduciendo un servicio OCI nuevo. Todas soportan despliegue con un clic via OCI Resource Manager.

### Fundamentos (01–04)

| # | Arquitectura | Servicios | Despliegue |
|---|-------------|-----------|------------|
| 01 | [Fundamentos — Webserver](arquitecturas-v2/01-fundamentos-webserver/) | VCN, Compute, NSG | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-01-fundamentos-webserver.zip) |
| 02 | [Alta Disponibilidad Multi-AD](arquitecturas-v2/02-alta-disponibilidad-multi-ad/) | VCN, Multi-AD, Compute | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-02-alta-disponibilidad-multi-ad.zip) |
| 03 | [Load Balancer HA](arquitecturas-v2/03-load-balancer-ha/) | LB, Health Checks, Multi-AD | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-03-load-balancer-ha.zip) |
| 04 | [Bastion Privado](arquitecturas-v2/04-bastion-privado/) | Bastion Service, Subnets Privadas | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-04-bastion-privado.zip) |

### Almacenamiento y Datos (05–07)

| # | Arquitectura | Servicios | Despliegue |
|---|-------------|-----------|------------|
| 05 | [Almacenamiento Compartido](arquitecturas-v2/05-almacenamiento-compartido/) | FSS, NFS, Mount Targets | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-05-almacenamiento-compartido.zip) |
| 06 | [Base de Datos](arquitecturas-v2/06-base-de-datos/) | DBSystem, VCN, Bastion | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-06-base-de-datos.zip) |
| 07 | [DataGuard HA](arquitecturas-v2/07-dataguard-ha/) | DataGuard, Standby DB, Multi-AD | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-07-dataguard-ha.zip) |

### Conectividad (08–09)

| # | Arquitectura | Servicios | Despliegue |
|---|-------------|-----------|------------|
| 08 | [Peering Local](arquitecturas-v2/08-peering-local/) | LPG, Hub-Spoke, Multi-VCN | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-08-peering-local.zip) |
| 09 | [Peering Remoto](arquitecturas-v2/09-peering-remoto/) | DRG, Cross-Region, RPC | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-09-peering-remoto.zip) |

### Servicios Avanzados (10–14)

| # | Arquitectura | Servicios | Despliegue |
|---|-------------|-----------|------------|
| 10 | [Autoscaling](arquitecturas-v2/10-autoscaling/) | Instance Pool, Auto Scaling, LB | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-10-autoscaling.zip) |
| 11 | [WAF + DNS](arquitecturas-v2/11-waf-dns/) | WAF, DNS Zone, LB | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-11-waf-dns.zip) |
| 12 | [VPN IPSec](arquitecturas-v2/12-vpn-ipsec/) | DRG, CPE, IPSec Tunnels | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-12-vpn-ipsec.zip) |
| 13 | [OKE Kubernetes](arquitecturas-v2/13-oke-kubernetes/) | OKE, Node Pool, Flannel CNI | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-13-oke-kubernetes.zip) |
| 14 | [API Gateway + Functions](arquitecturas-v2/14-api-gateway/) | API Gateway, Functions App | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-14-api-gateway.zip) |

### Observabilidad y Seguridad (15–17)

| # | Arquitectura | Servicios | Despliegue |
|---|-------------|-----------|------------|
| 15 | [Observabilidad](arquitecturas-v2/15-observabilidad/) | Logging, Monitoring, Alarms, Events | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-15-observabilidad.zip) |
| 16 | [Vault + Baselines](arquitecturas-v2/16-vault-baselines/) | Vault KMS, Events, ONS | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-16-vault-baselines.zip) |
| 17 | [Arquitectura Completa](arquitecturas-v2/17-arquitectura-completa/) | VCN, LB, Compute, Vault, Logging, Monitoring, Events, Bastion | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-17-arquitectura-completa.zip) |

---

## Módulos Reutilizables

Todos los módulos están documentados, versionados y diseñados para composición en arquitecturas de cualquier escala.

| Módulo | Descripción | Shapes / Configuración |
|--------|-------------|----------------------|
| `modulos/red/vcn` | VCN, IGW, NAT, SGW, Route Tables | CIDR configurable |
| `modulos/red/load-balancer` | Load Balancer regional con health checks | Flexible (10–8000 Mbps) |
| `modulos/red/bastion-service` | OCI Bastion Service para acceso SSH | TTL configurable |
| `modulos/red/peering-local` | Local Peering Gateway (Hub-Spoke) | Multi-VCN |
| `modulos/red/peering-remoto` | Remote Peering via DRG (Cross-Region) | Multi-Región |
| `modulos/computo/webserver` | Instancias con cloud-init personalizable | **E4, E5, E6, A1 (ARM), X9 Flex** |
| `modulos/seguridad/nsg` | Network Security Groups (Web, SSH, DB, NFS, Egress) | Reglas por servicio |
| `modulos/seguridad/vault` | Vault KMS (próximamente módulo completo) | AES-256 |
| `modulos/seguridad/baselines` | Cloud Guard + Security Baselines | Tenancy-level |
| `modulos/almacenamiento/fss` | File Storage Service (NFS) | Multi-AD |
| `modulos/base-de-datos/dbsystem` | Oracle DB System | Standard / Enterprise |

---

## Shapes de Cómputo Soportados

El módulo `computo/webserver` soporta todas las familias de shapes flexibles y de rendimiento fijo de OCI:

| Familia | Shape | Procesador | Max OCPUs | Max RAM |
|---------|-------|-----------|-----------|---------|
| **E4 Flex** | `VM.Standard.E4.Flex` | AMD EPYC Milan | 64 | 1024 GB |
| **E5 Flex** | `VM.Standard.E5.Flex` | AMD EPYC Genoa | 94 | 1049 GB |
| **E6 Flex** | `VM.Standard.E6.Flex` | AMD EPYC Turin | 128 | 1024 GB |
| **A1 Flex** | `VM.Standard.A1.Flex` | Ampere Altra (ARM) | 80 | 512 GB |
| **Standard3** | `VM.Standard3.Flex` | Intel Ice Lake | 32 | 512 GB |
| **Optimized3** | `VM.Optimized3.Flex` | Intel Ice Lake HF | 18 | 288 GB |
| **X9** | `VM.Standard.x9-15` | Intel Ice Lake X9 | 15 (fijo) | 1 TB (fijo) |
| **X9 BM** | `BM.Standard.x9-36` | Intel Ice Lake X9 BM | 36 (fijo) | 2 TB (fijo) |

---

## Arquitecturas de Referencia OKE

Catálogo de arquitecturas de referencia para Oracle Kubernetes Engine, desde un cluster básico hasta observabilidad completa. Cada arquitectura incluye despliegue con un clic, documentación enterprise y soporte para shapes Flex (E4, E5, E6, A1 ARM, X9).

| Arquitectura | Servicios OCI | Complejidad | Despliegue |
|-------------|--------------|-------------|------------|
| [Cluster Básico](oke/cluster-basico/) | OKE, VCN, NAT, SGW, Flannel CNI | Básica | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/oke-cluster-basico.zip) |
| [Multi Node Pool](oke/multi-nodepool/) | OKE, E4 Flex, A1 ARM, Multi-Arch | Intermedia | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/oke-multi-nodepool.zip) |
| [Ingress NGINX](oke/ingress-nginx/) | NGINX, cert-manager, TLS | Intermedia | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/oke-ingress-nginx.zip) |
| [OKE LB Service](oke/oke-lb-service/) | OCI LB nativo, SSL | Intermedia | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/oke-lb-service.zip) |
| [PV Block](oke/persistent-volumes-block/) | Block Volume CSI, Snapshots | Intermedia | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/oke-pv-block.zip) |
| [PV FSS](oke/persistent-volumes-fss/) | FSS NFS, ReadWriteMany | Intermedia | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/oke-pv-fss.zip) |
| [OCIR Registry](oke/oke-ocir-registry/) | Container Registry, Secrets | Intermedia | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/oke-ocir-registry.zip) |
| [Virtual Nodes](oke/virtual-nodes/) | OKE Serverless, Container Instances | Avanzada | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/oke-virtual-nodes.zip) |
| [Cluster Autoscaler](oke/cluster-autoscaler/) | Autoscaling, HPA, Metrics | Avanzada | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/oke-cluster-autoscaler.zip) |
| [Observabilidad OKE](oke/observabilidad-oke/) | Prometheus, Grafana, Loki | Avanzada | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/oke-observabilidad.zip) |

---

## Serverless

Arquitecturas de referencia para OCI Functions, API Gateway, Events y Streaming.

| Arquitectura | Servicios | Despliegue |
|-------------|-----------|------------|
| [Functions Básico](serverless/functions-basico/) | Functions, API Gateway | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/serverless-functions-basico.zip) |
| [Functions API CRUD](serverless/functions-api-crud/) | Functions, API GW, Autonomous DB | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/serverless-functions-api-crud.zip) |
| [Event-Driven](serverless/event-driven/) | Events Service, Functions, ONS | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/serverless-event-driven.zip) |
| [Streaming Kafka](serverless/streaming-kafka/) | OCI Streaming, Functions | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/serverless-streaming-kafka.zip) |
| [Functions Container](serverless/functions-container/) | Functions, OCIR, Docker | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/serverless-functions-container.zip) |

---

## Plataforma de Datos

Arquitecturas de referencia para bases de datos y servicios de datos en OCI.

| Arquitectura | Servicios | Despliegue |
|-------------|-----------|------------|
| [Autonomous Database](datos/autonomous-db/) | ATP/ADW, Private Endpoint | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/datos-autonomous-db.zip) |
| [MySQL HeatWave](datos/mysql-heatwave/) | MySQL, HeatWave Analytics | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/datos-mysql-heatwave.zip) |
| [NoSQL Database](datos/nosql/) | OCI NoSQL, Key-Value | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/datos-nosql.zip) |
| [Data Integration](datos/data-integration/) | ETL/ELT Pipelines | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/datos-data-integration.zip) |
| [GoldenGate](datos/golden-gate/) | Replicación tiempo real | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/datos-golden-gate.zip) |

---

## DevOps y CI/CD

Arquitecturas de referencia para pipelines de CI/CD y prácticas DevOps en OCI.

| Arquitectura | Servicios | Despliegue |
|-------------|-----------|------------|
| [DevOps Pipeline](devops/devops-pipeline/) | OCI DevOps, Build, Deploy OKE | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/devops-devops-pipeline.zip) |
| [Artifact Registry](devops/artifact-registry/) | Artifact + Container Registry | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/devops-artifact-registry.zip) |
| [GitOps ArgoCD](devops/gitops-argocd/) | ArgoCD, OKE, GitOps | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/devops-gitops-argocd.zip) |
| [Terraform Cloud](devops/terraform-cloud/) | Terraform Cloud/Enterprise | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/devops-terraform-cloud.zip) |

---

## IA y Machine Learning

Arquitecturas de referencia para AI/ML en OCI, inspiradas en repositorios como oracle-ai-accelerator.

| Arquitectura | Servicios | Despliegue |
|-------------|-----------|------------|
| [Data Science](ai/data-science/) | Notebooks, Model Catalog, Jobs | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/ai-data-science.zip) |
| [AI Vision](ai/ai-vision/) | Clasificación, Detección, Document AI | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/ai-ai-vision.zip) |
| [AI Language](ai/ai-language/) | NLP, Sentimiento, Traducción | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/ai-ai-language.zip) |
| [Generative AI](ai/generative-ai/) | LLM Inference, RAG Pipeline | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/ai-generative-ai.zip) |
| [GPU Cluster](ai/gpu-cluster/) | A10/A100, RDMA, ML Training | [![Deploy](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/ai-gpu-cluster.zip) |

---

## Inicio Rápido

### Opción 1: Deploy con un clic (Resource Manager)

Haz clic en el botón **"Deploy to Oracle Cloud"** de cualquier arquitectura. OCI Resource Manager presenta un formulario visual para configurar variables y despliega automáticamente.

### Opción 2: Terraform CLI

```bash
# 1. Clonar el repositorio
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam

# 2. Elegir una arquitectura
cd arquitecturas-v2/01-fundamentos-webserver

# 3. Configurar credenciales
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars con tus credenciales OCI

# 4. Inicializar y desplegar
terraform init -backend-config=../00-bootstrap-remotestate/backend.hcl
terraform plan
terraform apply
```

---

## Regiones Soportadas

| Región | Identificador | Uso |
|--------|--------------|-----|
| Ashburn | `us-ashburn-1` | Principal (default) |
| Phoenix | `us-phoenix-1` | DR / Peering Remoto |
| Sao Paulo | `sa-saopaulo-1` | LATAM Brasil |
| Santiago | `sa-santiago-1` | LATAM Chile |
| Bogota | `sa-bogota-1` | LATAM Colombia |
| Monterrey | `mx-monterrey-1` | LATAM México |
| Queretaro | `mx-queretaro-1` | LATAM México |

---

## Requisitos

- Terraform >= 1.5.0
- OCI Provider >= 6.0.0
- Cuenta OCI con tenancy activo
- Par de claves API configurado en `~/.oci/config`
- (Opcional) OCI CLI instalado para validaciones

---

## Contribuciones

Las contribuciones son bienvenidas. Por favor abre un Issue o Pull Request en GitHub.

## Licencia

Copyright (c) 2024-2026, Oracle Cloud LATAM Architectures.
Distribuido bajo la licencia [Universal Permissive License (UPL), Version 1.0](https://oss.oracle.com/licenses/upl/).
