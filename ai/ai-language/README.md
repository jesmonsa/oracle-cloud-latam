# OCI AI Language - Procesamiento de Lenguaje Natural (PNL)

[![OCI](https://img.shields.io/badge/Oracle-Cloud-F80000?style=flat-square)](https://www.oracle.com/cloud/)
[![Terraform](https://img.shields.io/badge/Terraform-1.5+-844FFF?style=flat-square&logo=terraform)](https://www.terraform.io/)
[![Deploy](https://img.shields.io/badge/Deploy-Stack-green?style=flat-square)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/download/latest/ai-language.zip)

## Descripción

Despliegue de **OCI AI Language**, servicio completamente gestionado de procesamiento de lenguaje natural (PNL) sin necesidad de infraestructura. Permite analizar texto con modelos preentrenados para:

- **Análisis de sentimientos** — Detectar opiniones positivas/negativas
- **Clasificación de documentos** — Categorizar textos automáticamente
- **Extracción de entidades** — Identificar personas, lugares, fechas
- **Análisis de sintaxis** — Tokenización, POS tagging, dependency parsing
- **Resumen de documentos** — Crear resúmenes automáticos
- **Extracción de palabras clave** — Identificar conceptos principales
- **Detección de idioma** — Identificar idioma del texto
- **Traducción automática** — Traducir entre idiomas

Ideal para:
- Análisis de feedback de clientes
- Moderación automática de comentarios
- Clasificación de tickets de soporte
- Análisis de redes sociales
- Procesamiento de documentos legales
- Extracción de información de formularios

## Arquitectura

```
┌─────────────────────────────────────────────────────┐
│         OCI AI Language Service                     │
├─────────────────────────────────────────────────────┤
│                                                      │
│  ┌──────────────────────────────────────────────┐   │
│  │   Language API Endpoints                     │   │
│  │  - Sentiment Analysis                        │   │
│  │  - Classification                            │   │
│  │  - Entity Extraction                         │   │
│  │  - Syntax Analysis                           │   │
│  │  - Document Summarization                    │   │
│  │  - Key Phrase Detection                      │   │
│  │  - Language Detection                        │   │
│  │  - Translation                               │   │
│  └──────────────────────────────────────────────┘   │
│                ↑                         ↓          │
│   ┌────────────────────┐       ┌──────────────────┐ │
│   │  Text Input        │       │  Results Cache   │ │
│   │  (Stream/Batch)    │       │  & Storage       │ │
│   └────────────────────┘       └──────────────────┘ │
└─────────────────────────────────────────────────────┘
         ↑                             ↓
    ┌─────────────┐         ┌──────────────────┐
    │   Object    │         │   API Gateway    │
    │   Storage   │         │   (Endpoints)    │
    │ (Textos)    │         │   + Auth         │
    └─────────────┘         └──────────────────┘
         ↑
    ┌─────────────┐
    │  Aplicación │
    │  (Cliente)  │
    └─────────────┘
```

## Componentes

### 1. OCI AI Language Service
- **Características**: Servicio sin servidor, escalable, preentrenado
- **Modelos**: 20+ idiomas soportados
- **Latencia**: ~100-300ms por documento
- **Capacidad**: Procesar textos hasta 128K caracteres
- **Múltiples tareas**: Una sola API para todas las operaciones de PNL

### 2. Object Storage Buckets
- **Propósito**: Almacenar textos de entrada y resultados
- **Estructura**:
  - `input/` — Documentos a procesar
  - `results/` — Resultados de análisis
  - `archive/` — Archivos históricos

### 3. API Gateway
- **Función**: Exponer Language API con autenticación
- **Características**:
  - Rate limiting
  - Request/response transformation
  - Logging y monitoreo
  - CORS habilitado
  - API keys para autenticación

### 4. Batch Processing (Opcional)
- **Función**: Procesar volúmenes grandes de documentos
- **Características**:
  - Job-based processing
  - Scheduled execution
  - Results download

## Variables de Configuración

```hcl
# Identidad
region                           = "us-phoenix-1"
compartment_id                   = "ocid1.compartment.oc1..xxxxx"
environment                      = "prod"
project_name                     = "language-platform"

# Language Service
enable_sentiment_analysis        = true
enable_classification            = true
enable_entity_extraction         = true
enable_syntax_analysis           = true
enable_summarization             = false
enable_key_phrase_extraction     = true
enable_language_detection        = true
enable_translation               = false
supported_languages              = ["en", "es", "pt", "fr"]

# API Gateway
api_gateway_enabled              = true
api_gateway_display_name         = "Language API"
api_key_enabled                  = true
rate_limit_per_minute            = 1000

# Object Storage
input_bucket_name                = "language-input"
results_bucket_name              = "language-results"
bucket_versioning_enabled        = true

# Logging & Monitoring
enable_request_logging           = true
log_retention_days               = 30

# Tags
tags = {
  "Environment"  = "prod"
  "Service"      = "ai-language"
  "Team"         = "ai-team"
}
```

## Outputs

```hcl
language_service_endpoint        = "https://language.xxxxxxx.oci.oraclecloud.com"
api_gateway_url                  = "https://xxxxx.apigateway.oci.oraclecloud.com/language"
input_bucket_uri                 = "oci://language-input@namespace"
results_bucket_uri               = "oci://language-results@namespace"
```

## Despliegue

### 1. Preparar Variables
```bash
cd ai/ai-language
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars
```

### 2. Inicializar Backend
```bash
terraform init \
  -backend-config="bucket=tu-bucket-terraform" \
  -backend-config="key=ai/ai-language/terraform.tfstate"
```

### 3. Desplegar
```bash
terraform plan
terraform apply
```

## Uso Práctico

### Análisis de Sentimiento
```bash
oci language detect-sentiment \
  --text "Este producto es excelente, muy recomendado!" \
  --language-code es
```

### Python SDK - Sentimiento
```python
from oci.language import LanguageClient
from oci.language.models import BatchDetectSentimentDetails, DominantLanguageEstimate

client = LanguageClient(config=config)

sentiment_details = BatchDetectSentimentDetails(
    documents=[{
        "key": "doc1",
        "text": "Este producto es excelente",
        "language_code": "es"
    }]
)

response = client.batch_detect_sentiment(batch_detect_sentiment_details=sentiment_details)

for result in response.results:
    print(f"Sentimiento: {result.sentiment}")
    print(f"Confianza: {result.scores}")
```

### Extracción de Entidades
```python
entity_details = BatchDetectEntitiesDetails(
    documents=[{
        "key": "doc1",
        "text": "Juan García trabaja en Oracle, ubicada en Austin, Texas",
        "language_code": "es"
    }]
)

response = client.batch_detect_entities(batch_detect_entities_details=entity_details)

for result in response.results:
    for entity in result.entities:
        print(f"{entity.text} ({entity.type})")
        # Output:
        # Juan García (PERSON)
        # Oracle (ORGANIZATION)
        # Austin (LOCATION)
        # Texas (LOCATION)
```

### Clasificación de Documentos
```python
classify_details = BatchDetectDocumentCategoriesDetails(
    documents=[{
        "key": "ticket1",
        "text": "Mi computadora no enciende, intente todo pero sigue sin funcionar",
        "language_code": "es"
    }]
)

response = client.batch_detect_document_categories(
    batch_detect_document_categories_details=classify_details
)

for result in response.results:
    for category in result.document_categories:
        print(f"{category.name}: {category.score}%")
        # Output:
        # HARDWARE: 95%
        # TROUBLESHOOTING: 87%
```

### Análisis de Sintaxis
```python
syntax_details = BatchDetectLanguageSyntaxDetails(
    documents=[{
        "key": "doc1",
        "text": "El gato corre rápidamente en el jardín",
        "language_code": "es"
    }]
)

response = client.batch_detect_language_syntax(
    batch_detect_language_syntax_details=syntax_details
)

for result in response.results:
    for token in result.tokens:
        print(f"{token.text} ({token.part_of_speech})")
        # Output:
        # El (DET)
        # gato (NOUN)
        # corre (VERB)
        # rápidamente (ADV)
```

### Extracción de Palabras Clave
```python
keyphrase_details = BatchDetectKeyPhrasesDetails(
    documents=[{
        "key": "article1",
        "text": "Oracle Cloud ofrece servicios de IA, bases de datos y computación en la nube...",
        "language_code": "es"
    }]
)

response = client.batch_detect_key_phrases(
    batch_detect_key_phrases_details=keyphrase_details
)

for result in response.results:
    for keyphrase in result.key_phrases:
        print(f"{keyphrase.text} (relevancia: {keyphrase.score})")
```

## Casos de Uso

| Caso | Descripción | Funcionalidad |
|---|---|---|
| **Análisis de feedback** | Entender opiniones de clientes | Sentiment Analysis |
| **Soporte automático** | Clasificar y priorizar tickets | Document Classification |
| **Moderación de UGC** | Filtrar contenido inapropiado | Sentiment + Custom Rules |
| **Búsqueda mejorada** | Extraer conceptos principales | Key Phrase Extraction |
| **Extracción de datos** | Obtener información de documentos | Entity Extraction |
| **Análisis social** | Monitorear marca en redes | Sentiment + Entity |
| **Traducción** | Soportar múltiples idiomas | Translation |
| **Procesamiento de formularios** | Extraer datos de aplicaciones | Entity + Classification |

## Monitoreo y Troubleshooting

### Ver Métricas
```bash
oci monitoring metrics list \
  --compartment-id $COMPARTMENT_ID \
  --namespace oci_language
```

### Verificar Logs
```bash
oci logging-search search \
  --log-group-id <log-group-id> \
  --search-query "Language API"
```

### Problemas Comunes

| Problema | Causa | Solución |
|---|---|---|
| 400 Bad Request | Idioma no soportado | Usar idioma soportado (en, es, pt, etc.) |
| Baja accuracy | Texto ambiguo | Proporcionar contexto adicional |
| Timeout | Documento muy grande | Dividir en párrafos < 5,000 chars |
| Rate limit | Exceso de llamadas | Implementar batching o queue |

## Políticas IAM Requeridas

```hcl
Allow group <group> to use ai-language-family in compartment <compartment>

Allow group <group> to manage objects in compartment <compartment>

Allow group <group> to manage api-gateway-family in compartment <compartment>
```

## Estimación de Costos

| Operación | Precio |
|---|---|
| Sentiment Analysis | USD 1.00 por 1,000 registros |
| Entity Extraction | USD 1.00 por 1,000 registros |
| Document Classification | USD 2.00 por 1,000 registros |
| Key Phrase Extraction | USD 1.00 por 1,000 registros |
| Language Detection | USD 0.50 por 1,000 registros |
| Translation | USD 15.00 por 1M caracteres |

**Ejemplo costo mensual**:
- 100,000 análisis sentimiento: USD 100
- 50,000 extracciones entidad: USD 50
- 50,000 clasificaciones: USD 100
- **Total aprox**: USD 250/mes

## Documentación Referencias

- [OCI AI Language Docs](https://docs.oracle.com/en-us/iaas/language/using/home.htm)
- [Language API Reference](https://docs.oracle.com/iaas/api/#/en/language/latest/)
- [Language Python SDK](https://docs.oracle.com/en-us/iaas/tools/python-sdk-examples/)
- [Idiomas Soportados](https://docs.oracle.com/en-us/iaas/language/using/supported-languages.htm)

---

**Última actualización**: 2026-04-12 | **Versión**: 1.0.0
