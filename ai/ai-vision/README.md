# OCI AI Vision - Servicio de Análisis Inteligente de Imágenes

[![OCI](https://img.shields.io/badge/Oracle-Cloud-F80000?style=flat-square)](https://www.oracle.com/cloud/)
[![Terraform](https://img.shields.io/badge/Terraform-1.5+-844FFF?style=flat-square&logo=terraform)](https://www.terraform.io/)
[![Deploy](https://img.shields.io/badge/Deploy-Stack-green?style=flat-square)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/download/latest/ai-vision.zip)

## Descripción

Despliegue de **OCI AI Vision**, servicio completamente gestionado de visión por computadora sin necesidad de infraestructura. Permite procesar imágenes con inteligencia artificial preentrenada para:

- **Clasificación de imágenes** — Identificar categorías en fotos
- **Detección de objetos** — Localizar y marcar objetos específicos
- **Análisis de documentos** — OCR, extracción de tablas, análisis de formularios
- **Segmentación de imágenes** — Dividir imágenes en regiones
- **Búsqueda por similitud visual** — Encontrar imágenes similares

Ideal para:
- Automatización de procesos que requieren análisis de imágenes
- Digitalización de documentos
- Moderación de contenido visual
- Análisis de métricas de tiendas
- Reconocimiento de productos en industria

## Arquitectura

```
┌────────────────────────────────────────────────────────┐
│            OCI AI Vision Service                       │
├────────────────────────────────────────────────────────┤
│                                                         │
│  ┌────────────────────────────────────────────┐        │
│  │   Vision API Endpoints                     │        │
│  │  - Classify Image                          │        │
│  │  - Detect Objects                          │        │
│  │  - Analyze Document                        │        │
│  │  - Extract Text (OCR)                      │        │
│  └────────────────────────────────────────────┘        │
│            ↑                                 ↓         │
│   ┌────────────────┐           ┌──────────────────┐   │
│   │  Images Input  │           │  Detection Cache │   │
│   │  (Stream)      │           │  Results Storage │   │
│   └────────────────┘           └──────────────────┘   │
└────────────────────────────────────────────────────────┘
         ↑                              ↓
    ┌─────────────┐         ┌──────────────────┐
    │   Object    │         │   API Gateway    │
    │   Storage   │         │   (Endpoints)    │
    │ (Imágenes)  │         │   + Auth         │
    └─────────────┘         └──────────────────┘
         ↑
    ┌─────────────┐
    │  Aplicación │
    │  (Cliente)  │
    └─────────────┘
```

## Componentes

### 1. OCI AI Vision Service
- **Características**: Servicio sin servidor, escalable, preentrenado
- **Modelos**: Vision, Language, Generative AI integrados
- **Latencia**: ~100-500ms por imagen
- **Capacidad**: Procesar imágenes de cualquier tamaño
- **Formatos**: JPEG, PNG, PDF, TIFF

### 2. Object Storage Bucket
- **Propósito**: Almacenar imágenes de entrada y resultados
- **Estructura**:
  - `input/` — Imágenes a procesar
  - `results/` — Resultados de análisis
  - `cache/` — Cache de resultados (opcional)
- **Versionado**: Habilitado para auditoría

### 3. API Gateway
- **Función**: Exposer Vision API con autenticación
- **Características**:
  - Rate limiting
  - Transformaciones de request/response
  - Logging y monitoreo
  - CORS configurado
  - API keys para clientes

### 4. Functions/Lambda (Opcional)
- **Triggering**: Activarse al subir imágenes
- **Procesamiento**: Llamar Vision API automáticamente
- **Notificaciones**: Alertar resultados

## Variables de Configuración

```hcl
# Identidad
region                       = "us-phoenix-1"
compartment_id               = "ocid1.compartment.oc1..xxxxx"
environment                  = "prod"
project_name                 = "vision-platform"

# Vision Service
vision_model                 = "ALL"  # ALL, IMAGE_CLASSIFICATION, OBJECT_DETECTION, DOCUMENT_ANALYSIS
enable_image_classification  = true
enable_object_detection      = true
enable_document_analysis     = true

# API Gateway
api_gateway_enabled          = true
api_gateway_display_name     = "Vision API"
api_key_enabled              = true
rate_limit_per_minute        = 1000

# Object Storage
input_bucket_name            = "vision-input"
results_bucket_name          = "vision-results"
bucket_versioning_enabled    = true

# Logging & Monitoring
enable_request_logging       = true
enable_metrics               = true
log_retention_days           = 30

# Tags
tags = {
  "Environment"  = "prod"
  "Service"      = "ai-vision"
  "Team"         = "ai-team"
}
```

## Outputs

```hcl
vision_service_endpoint       = "https://vision.xxxxxxx.oci.oraclecloud.com"
api_gateway_url              = "https://xxxxx.apigateway.oci.oraclecloud.com/vision"
api_key_id                   = "ocid1.apikey.oc1.phx..."
input_bucket_uri             = "oci://vision-input@namespace"
results_bucket_uri           = "oci://vision-results@namespace"
```

## Despliegue

### 1. Preparar Variables
```bash
cd ai/ai-vision
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars
```

### 2. Inicializar Backend
```bash
terraform init \
  -backend-config="bucket=tu-bucket-terraform" \
  -backend-config="key=ai/ai-vision/terraform.tfstate"
```

### 3. Desplegar
```bash
terraform plan
terraform apply
```

## Uso Práctico

### Clasificar Imagen
```bash
# Usar OCI CLI
oci vision image-analyze \
  --type IMAGE_CLASSIFICATION \
  --image-source-type OBJECT_STORAGE \
  --source-object-namespace "mynamespace" \
  --source-object-bucket "vision-input" \
  --source-object-name "photo.jpg"
```

### Python SDK
```python
from oci.vision import VisionClient
from oci.vision.models import AnalyzeImageDetails, ImageSource, ObjectStorageImageSource

client = VisionClient(config=config)

image_source = ObjectStorageImageSource(
    namespace="mynamespace",
    bucket_name="vision-input",
    object_name="photo.jpg"
)

details = AnalyzeImageDetails(
    image_source=image_source,
    features=[{
        "feature_type": "IMAGE_CLASSIFICATION"
    }, {
        "feature_type": "OBJECT_DETECTION"
    }]
)

response = client.analyze_image(analyze_image_details=details)
print(response)
```

### Detectar Objetos en Imagen
```python
from oci.vision import VisionClient
from oci.vision.models import AnalyzeImageDetails, ImageSource, ObjectStorageImageSource

client = VisionClient(config=config)

image_source = ObjectStorageImageSource(
    namespace="mynamespace",
    bucket_name="vision-input",
    object_name="street-view.jpg"
)

details = AnalyzeImageDetails(
    image_source=image_source,
    features=[{
        "feature_type": "OBJECT_DETECTION",
        "max_results": 20
    }]
)

response = client.analyze_image(analyze_image_details=details)

# Procesar detecciones
for detection in response.image_objects:
    print(f"{detection.name}: {detection.confidence}%")
    print(f"  Bounding box: {detection.bounding_polygon}")
```

### Análisis de Documentos
```python
details = AnalyzeImageDetails(
    image_source=image_source,
    features=[{
        "feature_type": "DOCUMENT_ANALYSIS"
    }]
)

response = client.analyze_image(analyze_image_details=details)

# Acceder a texto extraído
if response.document_analysis:
    for table in response.document_analysis.detected_tables:
        print(f"Tabla encontrada: {table.rows} filas x {table.columns} columnas")
```

## Casos de Uso

| Caso | Descripción | Modelo |
|---|---|---|
| **Moderación de contenido** | Detectar contenido inapropiado en UGC | IMAGE_CLASSIFICATION |
| **Análisis de tiendas** | Contar productos, verificar displays | OBJECT_DETECTION |
| **Digitalización** | OCR de documentos, facturas, cheques | DOCUMENT_ANALYSIS |
| **Búsqueda visual** | Encontrar productos similares | IMAGE_CLASSIFICATION |
| **Inspección industrial** | Detectar defectos en manufactura | OBJECT_DETECTION |
| **Análisis de reclamos** | Procesar fotos de siniestros | DOCUMENT_ANALYSIS |

## Monitoreo y Troubleshooting

### Ver Métricas de Vision API
```bash
oci monitoring metrics list \
  --compartment-id $COMPARTMENT_ID \
  --namespace oci_vision
```

### Verificar Logs
```bash
oci logging-search search \
  --log-group-id <log-group-id> \
  --search-query "Vision API"
```

### Problemas Comunes

| Problema | Causa | Solución |
|---|---|---|
| 403 Forbidden | Permisos IAM insuficientes | Verificar policy de Vision |
| Timeout | Imagen muy grande | Redimensionar imagen < 25MB |
| Low accuracy | Modelo no optimizado | Usar modelo específico, no ALL |
| Rate limit | Exceso de llamadas | Implementar queue/batching |

## Políticas IAM Requeridas

```hcl
Allow group <group> to use ai-vision-family in compartment <compartment>

# Para acceder a Object Storage
Allow group <group> to manage objects in compartment <compartment>

# Para API Gateway
Allow group <group> to manage api-gateway-family in compartment <compartment>
```

## Estimación de Costos

| Operación | Precio |
|---|---|
| Image Classification | USD 2.00 por 1,000 imágenes |
| Object Detection | USD 3.00 por 1,000 imágenes |
| Document Analysis | USD 2.00 por 1,000 documentos |
| Text Detection (OCR) | USD 3.00 por 1,000 imágenes |

**Ejemplo costo mensual**:
- 100,000 imágenes clasificación: USD 200
- 50,000 detecciones: USD 150
- 10,000 documentos: USD 20
- **Total aprox**: USD 370/mes

## Documentación Referencias

- [OCI AI Vision Docs](https://docs.oracle.com/en-us/iaas/vision/vision/using/home.htm)
- [Vision API Reference](https://docs.oracle.com/iaas/api/#/en/vision/latest/)
- [Vision Python SDK](https://docs.oracle.com/en-us/iaas/tools/python-sdk-examples/2.0.0/vision.html)
- [Terraform OCI Provider - Vision](https://registry.terraform.io/providers/oracle/oci/latest/docs)

---

**Última actualización**: 2026-04-12 | **Versión**: 1.0.0
