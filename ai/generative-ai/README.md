# OCI Generative AI - Modelos de Lenguaje Grande (LLM) y RAG

[![OCI](https://img.shields.io/badge/Oracle-Cloud-F80000?style=flat-square)](https://www.oracle.com/cloud/)
[![Terraform](https://img.shields.io/badge/Terraform-1.5+-844FFF?style=flat-square&logo=terraform)](https://www.terraform.io/)
[![Deploy](https://img.shields.io/badge/Deploy-Stack-green?style=flat-square)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/download/latest/ai-generative-ai.zip)

## Descripción

Despliegue de **OCI Generative AI Service**, acceso completamente gestionado a modelos de lenguaje grande (LLM) de última generación. Proporciona endpoints de inferencia con capacidades avanzadas como:

- **Llama 2** (7B, 13B, 70B) — Meta's open-source LLMs
- **Cohere Command** — Modelos optimizados para enterprise
- **Text Embedding** — Embeddings para RAG y búsqueda semántica
- **Fine-tuning** — Personalizar modelos con datos propios
- **RAG Pipeline** — Retrieval-Augmented Generation para información actualizada
- **Streaming** — Respuestas en tiempo real
- **Token counting** — Calcular tokens antes de procesar

Ideal para:
- Chatbots y asistentes virtuales
- Generación de contenido (artículos, email, código)
- Resumen y análisis de documentos
- Búsqueda semántica y RAG
- Análisis y transformación de datos
- Respuestas basadas en documentos propios

## Arquitectura

```
┌──────────────────────────────────────────────────────────┐
│        OCI Generative AI Service                         │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────────────────────────────────────────────┐    │
│  │   LLM Inference Endpoints                        │    │
│  │  - Llama 2 (7B, 13B, 70B)                        │    │
│  │  - Cohere Command (Text, Chat, Embed)           │    │
│  │  - Text Generation                              │    │
│  │  - Chat Completions                             │    │
│  │  - Embeddings                                   │    │
│  │  - Fine-tuning                                  │    │
│  └──────────────────────────────────────────────────┘    │
│             ↑                               ↓            │
│  ┌──────────────────┐             ┌──────────────────┐   │
│  │  Prompts/Text    │             │  Vector DB       │   │
│  │  (Batch/Stream)  │             │  (OCI MySQL HW)  │   │
│  └──────────────────┘             └──────────────────┘   │
└──────────────────────────────────────────────────────────┘
         ↑                                    ↓
    ┌─────────────┐                ┌──────────────────┐
    │   Object    │                │   API Gateway    │
    │   Storage   │                │   (Endpoints)    │
    │ (RAG Docs)  │                │   + Auth         │
    └─────────────┘                └──────────────────┘
         ↑                                    ↑
    ┌─────────────────────────────────────────────┐
    │          Aplicación/Chatbot/UI              │
    └─────────────────────────────────────────────┘
```

## Componentes

### 1. Generative AI Service
- **Modelos disponibles**: Llama 2, Cohere, Granite (próximamente)
- **Capacidades**:
  - Text generation
  - Chat completions
  - Embeddings para RAG
  - Fine-tuning con adapters
  - Streaming responses
  - Token counting
- **Latencia**: 50-500ms dependiendo del modelo
- **Contexto**: Hasta 4K-8K tokens

### 2. Vector Database (RAG)
- **OCI MySQL HeatWave** con Vector Support
- **Alternativas**: Autonomous Data Warehouse, OpenSearch
- **Características**:
  - Almacenar embeddings
  - Búsqueda semántica
  - Indexación HNSW
  - Escalable y gestionado

### 3. Document Storage
- **Object Storage buckets**:
  - `rag-documents/` — Documentos para RAG
  - `rag-embeddings/` — Cache de embeddings
  - `conversations/` — Historial de chats

### 4. API Gateway
- **Exponer endpoints de LLM**
- **Autenticación y rate limiting**
- **Transformación de requests**
- **Logging y monitoring**

### 5. Functions (Opcional)
- **Processamiento asincrónico**
- **Orquestación de RAG pipeline**
- **Webhooks y notificaciones**

## Variables de Configuración

```hcl
# Identidad
region                              = "us-phoenix-1"
compartment_id                      = "ocid1.compartment.oc1..xxxxx"
environment                         = "prod"
project_name                        = "genai-platform"

# Generative AI Service
llm_model                           = "meta.llama-2-70b-chat"
enable_text_generation              = true
enable_chat_completions             = true
enable_embeddings                   = true
enable_fine_tuning                  = false
max_tokens                          = 1000
temperature                         = 0.7

# RAG Configuration
enable_rag                          = true
vector_db_type                      = "mysql-heatwave"  # or "aDW", "opensearch"
embedding_model                     = "cohere.embed-english-v3.0"
similarity_threshold                = 0.7
top_k_results                       = 5

# API Gateway
api_gateway_enabled                 = true
api_gateway_display_name            = "GenAI API"
rate_limit_per_minute               = 100
max_concurrent_requests             = 50

# Document Storage
documents_bucket_name               = "rag-documents"
embeddings_cache_enabled            = true

# Logging & Monitoring
enable_conversation_logging         = true
enable_usage_metrics                = true
log_retention_days                  = 90

# Tags
tags = {
  "Environment"  = "prod"
  "Service"      = "generative-ai"
  "Team"         = "ai-team"
}
```

## Outputs

```hcl
llm_service_endpoint                = "https://generativeai.xxxxxx.oci.oraclecloud.com"
api_gateway_url                     = "https://xxxxx.apigateway.oci.oraclecloud.com/genai"
vector_db_endpoint                  = "mysql-heatwave.xxxxx.oci.oraclecloud.com"
documents_bucket_uri                = "oci://rag-documents@namespace"
embedding_model_id                  = "cohere.embed-english-v3.0"
```

## Despliegue

### 1. Preparar Variables
```bash
cd ai/generative-ai
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars
```

### 2. Inicializar Backend
```bash
terraform init \
  -backend-config="bucket=tu-bucket-terraform" \
  -backend-config="key=ai/generative-ai/terraform.tfstate"
```

### 3. Desplegar
```bash
terraform plan
terraform apply
```

## Uso Práctico

### Text Generation Simple
```bash
oci generative-ai-inference generate-text \
  --model-id meta.llama-2-70b-chat \
  --input-text "¿Cuál es la capital de España?" \
  --max-tokens 100
```

### Python SDK - Chat
```python
from oci.generative_ai_inference import GenerativeAiInferenceClient
from oci.generative_ai_inference.models import ChatDetails, Message

client = GenerativeAiInferenceClient(config=config)

messages = [
    Message(role="USER", content="¿Cómo creo una aplicación web?")
]

chat_details = ChatDetails(
    model_id="meta.llama-2-70b-chat",
    messages=messages,
    max_tokens=1000,
    temperature=0.7
)

response = client.chat(chat_details=chat_details)
print(response.chat_response.content)
```

### Text Generation con Streaming
```python
from oci.generative_ai_inference import GenerativeAiInferenceClient
from oci.generative_ai_inference.models import GenerateTextDetails

client = GenerativeAiInferenceClient(config=config)

text_details = GenerateTextDetails(
    model_id="meta.llama-2-70b-chat",
    input_text="Escribe un poema sobre IA:",
    max_tokens=500,
    stream=True  # Streaming
)

response = client.generate_text(text_details=text_details)

# Procesar tokens en streaming
for chunk in response.data:
    print(chunk.generated_text, end="", flush=True)
```

### RAG Pipeline (Retrieval-Augmented Generation)
```python
# 1. Generar embeddings del documento
embedding_response = client.generate_embeddings(
    model_id="cohere.embed-english-v3.0",
    input="Oracle Cloud es una plataforma..."
)
embedding = embedding_response.data[0].embedding

# 2. Guardar en Vector DB
insert_into_vector_db(embedding, doc_id="doc1")

# 3. Buscar documentos similares
query_embedding = client.generate_embeddings(
    model_id="cohere.embed-english-v3.0",
    input="¿Qué es Oracle Cloud?"
)

similar_docs = search_vector_db(query_embedding, top_k=5)

# 4. Generar respuesta con contexto
context = "\n".join([doc["content"] for doc in similar_docs])
prompt = f"""Responde basándote en el siguiente contexto:

{context}

Pregunta: ¿Qué es Oracle Cloud?"""

response = client.generate_text(
    model_id="meta.llama-2-70b-chat",
    input_text=prompt,
    max_tokens=500
)

print(response.generated_text)
```

### Fine-tuning (Personalización)
```python
# Crear dataset de entrenamiento
training_data = [
    {"input": "¿Cuál es el mejor servicio para ML?", 
     "output": "OCI Data Science es ideal para ML end-to-end"},
    {"input": "¿Cómo usar Vision API?", 
     "output": "Vision API permite analizar imágenes sin código"},
    # ... más ejemplos
]

# Subir a Object Storage
upload_to_object_storage(training_data, "training-data.jsonl")

# Crear fine-tuning job
finetune_response = client.create_fine_tuning_job(
    model_id="meta.llama-2-7b-chat",
    training_data_path="oci://bucket/training-data.jsonl",
    output_model_name="my-custom-llama"
)
```

## Casos de Uso

| Caso | Descripción | Modelo | Approx Cost |
|---|---|---|---|
| **Chatbot** | Asistente inteligente | Llama 2 70B | USD 0.15/M tokens |
| **RAG** | Q&A basado en docs | Cohere Embed | USD 0.10/M tokens |
| **Content Gen** | Generar artículos | Llama 2 7B | USD 0.03/M tokens |
| **Code Gen** | Generar código | Llama 2 70B | USD 0.15/M tokens |
| **Summarization** | Resumir documentos | Llama 2 13B | USD 0.05/M tokens |
| **Analysis** | Analizar datos | Cohere | USD 0.10/M tokens |

## Monitoreo y Troubleshooting

### Ver Métrica de Tokens Usados
```bash
oci monitoring metrics list \
  --compartment-id $COMPARTMENT_ID \
  --namespace oci_generative_ai
```

### Debugging RAG Pipeline
```python
# Verificar calidad de embeddings
similarity = cosine_similarity(query_embedding, doc_embedding)
print(f"Similitud: {similarity}")  # Debe ser > 0.7

# Verificar documentos recuperados
for doc in retrieved_docs:
    print(f"Score: {doc['score']}, Content: {doc['text'][:100]}")
```

### Problemas Comunes

| Problema | Causa | Solución |
|---|---|---|
| Low quality responses | Modelo pequeño insuficiente | Usar Llama 2 70B |
| RAG no mejora respuestas | Embedding similarity bajo | Mejorar docs, ajustar threshold |
| Timeout | Documento grande | Dividir en chunks < 2K tokens |
| High cost | Muchos tokens | Implementar caching, truncar prompts |
| Hallucinations | Modelo genera falsos datos | Usar retrieval, agregar constraints |

## Políticas IAM Requeridas

```hcl
Allow group <group> to use generative-ai-family in compartment <compartment>

Allow group <group> to manage objects in compartment <compartment>

Allow group <group> to manage mysql-db-system in compartment <compartment>

Allow group <group> to manage api-gateway-family in compartment <compartment>
```

## Estimación de Costos

| Modelo | Costo |
|---|---|
| Llama 2 7B | USD 0.03 / M input tokens, USD 0.03 / M output |
| Llama 2 13B | USD 0.05 / M input tokens, USD 0.05 / M output |
| Llama 2 70B | USD 0.15 / M input tokens, USD 0.15 / M output |
| Cohere Command | USD 0.50 / M tokens |
| Cohere Embed | USD 0.10 / M tokens |

**Ejemplo costo mensual**:
- 100M input tokens (Llama 2 70B): USD 1,500
- 50M output tokens: USD 750
- 10M embedding tokens: USD 1,000
- **Total aprox**: USD 3,250/mes

## Documentación Referencias

- [OCI Generative AI Docs](https://docs.oracle.com/en-us/iaas/generative-ai/using/home.htm)
- [Generative AI API](https://docs.oracle.com/iaas/api/#/en/generative-ai-inference/latest/)
- [RAG Best Practices](https://docs.oracle.com/en-us/iaas/generative-ai/using/rag-pipeline.htm)
- [Prompt Engineering Guide](https://docs.oracle.com/en-us/iaas/generative-ai/using/prompt-engineering.htm)
- [LangChain + OCI Integration](https://github.com/langchain-ai/langchain)

---

**Última actualización**: 2026-04-12 | **Versión**: 1.0.0
