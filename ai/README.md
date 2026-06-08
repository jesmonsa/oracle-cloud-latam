# Sección AI/ML - Arquitectura de Referencia OCI Terraform

[![OCI](https://img.shields.io/badge/Oracle-Cloud-F80000?style=flat-square)](https://www.oracle.com/cloud/)
[![Terraform](https://img.shields.io/badge/Terraform-1.5+-844FFF?style=flat-square&logo=terraform)](https://www.terraform.io/)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Active%20Development-blue?style=flat-square)](https://github.com/jesmonsa/oracle-cloud-latam)

## Descripción

Catálogo empresarial de arquitecturas de **IA/ML en Oracle Cloud Infrastructure (OCI)**, inspirado en repositorios como [`jganggini/oracle-ai-accelerator`](https://github.com/jganggini/oracle-ai-accelerator). Proporciona plantillas Terraform listas para producción para desplegar soluciones de inteligencia artificial, ciencia de datos, visión por computadora, procesamiento de lenguaje natural y modelos generativos.

Esta sección se enfoca en:

- **OCI Data Science** — Plataforma integrada para notebooks, capacitación y despliegue de modelos
- **OCI AI Services** — Servicios gestionados de visión e idioma sin infraestructura
- **OCI Generative AI** — Acceso a modelos LLM de última generación (Llama 2, Cohere, etc.)
- **Instancias GPU** — Clusters de GPU (A10, A100, V100) para entrenamiento de ML a escala
- **Arquitectura MLOps** — Pipelines de end-to-end para ciencia de datos

## Arquitecturas Disponibles

| Arquitectura | Descripción | Componentes | Deploy |
|---|---|---|---|
| **data-science** | Plataforma OCI Data Science: Sesiones Notebook + Catálogo de Modelos + Jobs | DSC, Notebook, Model Catalog, Jobs | [![Deploy](https://img.shields.io/badge/Deploy-Terraform-blue?style=flat)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/download/latest/ai-data-science.zip) |
| **ai-vision** | OCI AI Vision: Clasificación de imágenes, detección de objetos, análisis de documentos | Vision Service, Object Storage, API Gateway | [![Deploy](https://img.shields.io/badge/Deploy-Terraform-blue?style=flat)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/download/latest/ai-vision.zip) |
| **ai-language** | OCI AI Language: PNL, análisis de sentimientos, extracción de frases clave, traducción | Language Service, Object Storage, API Gateway | [![Deploy](https://img.shields.io/badge/Deploy-Terraform-blue?style=flat)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/download/latest/ai-language.zip) |
| **generative-ai** | OCI Generative AI: Endpoints LLM de inferencia + RAG pipeline completo | Generative AI Service, Vector DB, LangChain | [![Deploy](https://img.shields.io/badge/Deploy-Terraform-blue?style=flat)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/download/latest/ai-generative-ai.zip) |
| **gpu-cluster** | Cluster GPU para ML training: Instancias A10/A100 + RDMA networking + almacenamiento compartido | Compute Instances, RDMA, FSS | [![Deploy](https://img.shields.io/badge/Deploy-Terraform-blue?style=flat)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/download/latest/ai-gpu-cluster.zip) |

## Formas GPU Soportadas

OCI ofrece varias formas GPU optimizadas para machine learning:

| Forma | Acelerador | GPU | vCPU | RAM | Ideal para |
|---|---|---|---|---|---|
| **VM.GPU.A10.1** | NVIDIA A10 Tensor | 1x A10 | 16 | 104 GB | Inferencia, entrenamiento ligero, visión |
| **VM.GPU.A10.2** | NVIDIA A10 Tensor | 2x A10 | 32 | 208 GB | Entrenamiento ML, parallelismo |
| **VM.GPU.A100.1** | NVIDIA A100 SXM4 | 1x A100 | 16 | 256 GB | Entrenamiento profundo, LLM |
| **VM.GPU.A100.2** | NVIDIA A100 SXM4 | 2x A100 | 32 | 512 GB | Entrenamiento a escala, big data ML |
| **VM.GPU.V100.1** | NVIDIA Tesla V100 | 1x V100 | 16 | 256 GB | Visión, GPU computing legacy |
| **BM.GPU.A100** | NVIDIA A100 | 8x A100 | 192 | 1.4 TB | Entrenamiento distribuido, clusters |

## Casos de Uso

### 1. Data Science & Model Development
Utiliza **OCI Data Science** para desarrollo colaborativo, experimentación rápida y gestión de modelos en un entorno completamente gestionado.

### 2. Computer Vision
Procesa imágenes sin código con **OCI AI Vision** para:
- Clasificación de imágenes
- Detección de objetos
- Análisis de documentos (OCR, tablas)
- Segmentación semántica

### 3. Procesamiento de Lenguaje Natural
Analiza texto con **OCI AI Language**:
- Análisis de sentimientos
- Extracción de entidades
- Análisis de clave/valor
- Traducción automática
- Clasificación de documentos

### 4. Generative AI & LLM
Accede a modelos de lenguaje grandes con **OCI Generative AI**:
- Llama 2 (7B, 13B, 70B)
- Cohere Command (Text, Chat, Embed)
- Fine-tuning con tus datos
- RAG (Retrieval-Augmented Generation)

### 5. High-Performance ML Training
Entrena modelos a escala con clusters de GPU **A100/A10** y almacenamiento compartido de bajo latency.

## Estructura de Directorios

```
ai/
├── README.md                      # Este archivo
├── data-science/                  # Plataforma OCI Data Science
│   ├── README.md
│   ├── main.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   └── schema.yaml
├── ai-vision/                     # OCI AI Vision Service
│   ├── README.md
│   ├── main.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   └── schema.yaml
├── ai-language/                   # OCI AI Language Service
│   ├── README.md
│   ├── main.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   └── schema.yaml
├── generative-ai/                 # OCI Generative AI Service + RAG
│   ├── README.md
│   ├── main.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   └── schema.yaml
└── gpu-cluster/                   # GPU Cluster para ML Training
    ├── README.md
    ├── main.tf
    ├── provider.tf
    ├── variables.tf
    ├── outputs.tf
    ├── terraform.tfvars.example
    └── schema.yaml
```

## Inicio Rápido

### Requisitos Previos
- [Terraform](https://www.terraform.io/downloads.html) >= 1.5
- Cuenta de [Oracle Cloud](https://www.oracle.com/cloud/free/)
- API key de OCI configurada (`~/.oci/config`)
- Tenancy OCID, User OCID y Fingerprint de API

### Desplegar una Arquitectura

```bash
cd ai/{arquitectura}
terraform init
terraform plan
terraform apply
```

### Ejemplo: Data Science
```bash
cd ai/data-science
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars con tus valores
terraform init -backend-config="bucket=tu-bucket" \
               -backend-config="key=ai/data-science/terraform.tfstate"
terraform apply
```

## Configuración del Backend

Todas las arquitecturas usan **S3-compatible Object Storage** como backend remoto:

```hcl
terraform {
  backend "s3" {
    bucket         = "tu-bucket-terraform"
    key            = "ai/{arquitectura}/terraform.tfstate"
    region         = "us-phoenix-1"
    endpoint       = "https://region.compat.objectstorage.oraclecloud.com"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
```

Para configurar el backend, ejecuta:
```bash
terraform init -migrate-state
```

## Variables Comunes

| Variable | Descripción | Ejemplo |
|---|---|---|
| `region` | Región de OCI | `us-phoenix-1` |
| `compartment_id` | OCID del compartment | `ocid1.compartment.oc1..xxxxx` |
| `environment` | Etiqueta de ambiente | `prod`, `dev`, `staging` |
| `project_name` | Nombre del proyecto | `mi-proyecto-ai` |
| `tags` | Tags para tracking de costos | `{"team": "ai", "cost-center": "123"}` |

## Estimación de Costos

### OCI Data Science
- **Notebook Sessions**: USD 0.10/hora (on-demand)
- **Model Catalog Storage**: USD 0.023/GB/mes
- **Jobs**: USD 0.01/OCPUh

### OCI AI Services
- **Vision**: USD 2.00 por 1,000 imágenes
- **Language**: USD 1.00 por 1,000 registros
- **Generative AI**: Varía por modelo (Llama 2: USD 0.15/M tokens, Cohere: USD 0.50/M tokens)

### GPU Instances
- **VM.GPU.A10.1**: USD 0.80/hora
- **VM.GPU.A100.1**: USD 2.50/hora
- **BM.GPU.A100** (8x): USD 20.00/hora

**Calculadora**: https://www.oracle.com/cloud/price-list/

## Documentación y Referencias

### OCI AI Services
- [OCI Data Science](https://docs.oracle.com/en-us/iaas/data-science/using/home.htm)
- [OCI AI Vision](https://docs.oracle.com/en-us/iaas/vision/vision/using/home.htm)
- [OCI AI Language](https://docs.oracle.com/en-us/iaas/language/using/home.htm)
- [OCI Generative AI](https://docs.oracle.com/en-us/iaas/generative-ai/using/home.htm)

### Terraform Providers
- [OCI Provider Documentation](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [OCI Terraform Examples](https://github.com/oracle-terraform-modules)

### Recursos Adicionales
- [Oracle AI Accelerator](https://github.com/jganggini/oracle-ai-accelerator)
- [OCI MLOps Best Practices](https://docs.oracle.com/en/learn/oci-ml-best-practices/)
- [Oracle Learning Paths - AI/ML](https://docs.oracle.com/en/learn/index.html)

## Soporte y Contribuciones

Para reportar problemas, solicitar features o contribuir:
1. Abre un **issue** en [GitHub](https://github.com/jesmonsa/oracle-cloud-latam/issues)
2. Crea un **pull request** con tus mejoras
3. Consulta la documentación de OCI en el [Support Center](https://support.oracle.com/)

## Licencia

Este proyecto está bajo licencia **MIT**. Ver [LICENSE](../../LICENSE) para detalles.

## Autores y Agradecimientos

- Inspirado en [`jganggini/oracle-ai-accelerator`](https://github.com/jganggini/oracle-ai-accelerator)
- Mantenido por la comunidad de Oracle Cloud en LATAM
- Agradecimientos a Oracle por proporcionar excelente documentación y servicios

---

**Última actualización**: 2026-04-12 | **Versión**: 1.0.0
