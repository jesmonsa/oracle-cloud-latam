# OCI Functions - Contenedor con Docker

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-623CE4?logo=terraform)](https://www.terraform.io/downloads.html)
[![OCI Provider](https://img.shields.io/badge/OCI%20Provider-6.0+-F80000?logo=oracle)](https://registry.terraform.io/providers/oracle/oci/latest)
[![OCIR](https://img.shields.io/badge/OCIR-Container%20Registry-green?logo=oracle)](https://docs.oracle.com/en-us/iaas/Content/Registry/home.htm)

## Descripción

Arquitectura que permite desplegar **OCI Functions basadas en imágenes Docker personalizadas**. Soporta cualquier lenguaje de programación, dependencias complejas, modelos de ML pre-entrenados y librerías binarias.

### Características

✓ Soporte multi-lenguaje (Python, Node.js, Go, Java, C++)
✓ Dependencias arbitrarias (sistema + aplicación)
✓ Pre-carga de modelos de ML (TensorFlow, PyTorch)
✓ Compilación automática en CI/CD
✓ Push automático a OCIR (Oracle Container Image Registry)
✓ Versionado de imágenes
✓ Recursos configurables (CPU/memoria)
✓ Seguridad: imágenes privadas en registry

---

## Topología

```
┌──────────────────────────────────────┐
│       CI/CD Pipeline                 │
│  (GitHub Actions / GitLab CI)        │
└────────────┬─────────────────────────┘
             │
             ▼
        ┌─────────────┐
        │   Dockerfile│
        │   build     │
        └────────┬────┘
                 │
         ┌───────▼───────┐
         │  Docker Image │
         │  (ocir.io)    │
         └───────┬───────┘
                 │
        ┌────────▼────────┐
        │  OCIR Registry  │
        │ (private repo)  │
        └────────┬─────────┘
                 │
        ┌────────▼────────────┐
        │ OCI Functions       │
        │ (Container-based)   │
        │                    │
        │ ┌──────────────┐  │
        │ │ Python 3.11  │  │
        │ │ + ML Models  │  │
        │ │ + Libraries  │  │
        │ └──────────────┘  │
        └────────┬───────────┘
                 │
        ┌────────▼───────┐
        │  API Gateway   │
        │  (Endpoint)    │
        └────────────────┘
```

---

## Componentes

| Componente | Tipo | Descripción | Costo |
|-----------|------|-------------|--------|
| **Functions** | OCI Functions | Container-based | 1M gratis/mes |
| **OCIR** | Container Registry | Almacenamiento de imágenes | USD 0.026/GB/mes |
| **API Gateway** | API Gateway | Endpoint HTTP | USD 3.65/mes |
| **Cloud Build** | CI/CD | Compilación automática | Incluido |

**Costo Total Estimado**: USD 3.85/mes + USD 0.026 por GB almacenado

---

## Casos de Uso

| Caso de Uso | Stack | Imagen Base | Tamaño |
|-------------|-------|-------------|--------|
| **ML Inference** | Python + TensorFlow | python:3.11-slim | 2-3 GB |
| **Image Processing** | Python + OpenCV | python:3.11 | 1.5-2 GB |
| **Data Pipeline** | Python + Pandas + Polars | python:3.11 | 1-1.5 GB |
| **Go Microservice** | Go 1.21 | golang:1.21-alpine | 500 MB |
| **Node.js API** | Node.js 20 + Express | node:20-alpine | 300 MB |
| **Java Service** | Java 21 + Spring | openjdk:21-slim | 400 MB |

---

## Estructura de Dockerfile

### Ejemplo 1: Python con ML Models

```dockerfile
FROM python:3.11-slim

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    libopenblas-dev \
    liblapack-dev \
    && rm -rf /var/lib/apt/lists/*

# Instalar dependencias Python
RUN pip install --no-cache-dir \
    tensorflow==2.13.0 \
    numpy==1.24.3 \
    pandas==2.0.3 \
    scikit-learn==1.3.0

# Copiar función
WORKDIR /function
COPY func.py /function/func.py

# Descargar modelo pre-entrenado (opcional)
RUN python -c "import tensorflow as tf; \
    model = tf.keras.applications.MobileNetV2(weights='imagenet'); \
    model.save('/function/models/mobilenet')"

# Entrypoint
ENV ENTRYPOINT func.handler
CMD ["func.handler"]
```

### Ejemplo 2: Go Microservice

```dockerfile
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY . .

# Compilar
RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags "-w -s" \
    -o func .

# Runtime image
FROM alpine:latest
RUN apk --no-cache add ca-certificates

WORKDIR /
COPY --from=builder /app/func .

ENV ENTRYPOINT func
CMD ["func"]
```

### Ejemplo 3: Python con Dependencias Binarias

```dockerfile
FROM python:3.11

# Instalaciones del sistema
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    postgresql-client \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código
COPY . /function/
WORKDIR /function

# Comando
CMD ["python", "-m", "fdk", "/function/func.py", "handler"]
```

---

## Variables Principales

```hcl
variable "docker_image_url" {
  description = "URL de imagen Docker en OCIR"
  type        = string
  
  validation {
    condition     = can(regex("^.+\\.ocir\\..+/.+:.+$", var.docker_image_url))
    error_message = "Debe ser una URL válida de OCIR"
  }
}

variable "image_digest" {
  description = "SHA256 digest de imagen"
  type        = string
  default     = ""  # Se obtiene automáticamente
}

variable "function_resource_config" {
  description = "Configuración de recursos"
  type        = map(number)
  default = {
    memory_mb = 512
    timeout_s = 120
  }
}
```

---

## Instalación

```bash
cd serverless/functions-container

# 1. Preparar Dockerfile
cp Dockerfile.example Dockerfile
# Editar Dockerfile según necesidades

# 2. Preparar CI/CD (GitHub Actions)
cp .github/workflows/deploy.yml.example .github/workflows/deploy.yml

# 3. Variables de Terraform
cp terraform.tfvars.example terraform.tfvars

# 4. Desplegar
terraform init
terraform plan
terraform apply
```

---

## Uso

### Build y Push Manual

```bash
# Login a OCIR
docker login us-phoenix-1.ocir.io

# Build
docker build -t us-phoenix-1.ocir.io/mytenancy/myfunc:v1.0 .

# Push
docker push us-phoenix-1.ocir.io/mytenancy/myfunc:v1.0

# Obtener digest
docker inspect --format='{{.RepoDigests}}' \
  us-phoenix-1.ocir.io/mytenancy/myfunc:v1.0
```

### Build y Push con Terraform

```bash
# Terraform se encargará del build y push automático
terraform apply

# Verify
docker pull us-phoenix-1.ocir.io/mytenancy/myfunc:latest
```

### Invocar función

```bash
# Obtener endpoint
API=$(terraform output -raw api_endpoint)

# Test
curl -X POST "$API/ml-predict" \
  -H "Content-Type: application/json" \
  -d '{"image_url":"..."}'
```

---

## Estimación de Costos

### Scenario: 100K invocaciones/mes, imagen 500 MB

```
Functions:              USD 0.00
  (100K invocaciones dentro de 1M gratis)

OCIR Storage:           USD 0.013/mes
  (500 MB × USD 0.026/GB × 1 imagen)

API Gateway:            USD 3.65/mes

TOTAL:                  USD 3.66/mes
```

### Scenario: Alto volumen ML (2 GB imagen, 1M invocaciones)

```
Functions:              USD 0.00
  (1M invocaciones = dentro de limite gratis)

OCIR Storage:           USD 0.052/mes
  (2 GB × USD 0.026/GB)

API Gateway:            USD 3.65/mes

TOTAL:                  USD 3.70/mes
```

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Build and Deploy Function

on:
  push:
    branches: [main]
    paths:
      - 'serverless/functions-container/**'

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Login to OCIR
        run: |
          echo "${{ secrets.OCIR_PASSWORD }}" | docker login \
            -u "${{ secrets.OCIR_USERNAME }}" \
            --password-stdin us-phoenix-1.ocir.io
      
      - name: Build Docker Image
        run: |
          docker build \
            -t us-phoenix-1.ocir.io/${{ secrets.OCIR_NAMESPACE }}/myfunc:latest \
            -t us-phoenix-1.ocir.io/${{ secrets.OCIR_NAMESPACE }}/myfunc:${{ github.sha }} \
            .
      
      - name: Push to OCIR
        run: |
          docker push us-phoenix-1.ocir.io/${{ secrets.OCIR_NAMESPACE }}/myfunc:latest
          docker push us-phoenix-1.ocir.io/${{ secrets.OCIR_NAMESPACE }}/myfunc:${{ github.sha }}
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      
      - name: Deploy with Terraform
        working-directory: serverless/functions-container
        run: |
          terraform init
          terraform apply -auto-approve \
            -var="docker_image_url=us-phoenix-1.ocir.io/${{ secrets.OCIR_NAMESPACE }}/myfunc:latest"
        env:
          TF_VAR_tenancy_ocid: ${{ secrets.TENANCY_OCID }}
          TF_VAR_compartment_ocid: ${{ secrets.COMPARTMENT_OCID }}
```

---

## Troubleshooting

### Error: "Image not found"

```bash
# Verificar que imagen existe en OCIR
oci artifacts container image list \
  --compartment-id <compartment-id> \
  --repository-name myfunc

# Verificar permisos de lectura
oci artifacts container repository get \
  --repository-id <repo-id>
```

### Función timeout

```bash
# Aumentar timeout en variables
function_timeout = 300  # en lugar de 120

# Aumentar memoria para más CPU
function_memory = 1024
```

### Error de permissions

```bash
# Crear policy para Functions acceda a OCIR
oci iam policy create \
  --name functions-ocir-access \
  --statements \
  'Allow resource fnfunc to pull from repository */myfunc in compartment serverless'
```

---

## Optimización de Imágenes

### Reducir tamaño

```dockerfile
# Multi-stage build
FROM python:3.11 as builder
RUN pip install -r requirements.txt

FROM python:3.11-slim
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

# Usar alpine
FROM python:3.11-alpine
RUN apk add --no-cache gcc musl-dev
```

### Caché de layers

```dockerfile
# Copiar requirements primero (cambia menos)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código (cambia más frecuentemente)
COPY . /function/
```

---

## Seguridad

✓ Imágenes privadas en OCIR
✓ Scanning de vulnerabilidades integrado
✓ Registry access control via IAM
✓ Encriptación de imágenes
✓ No ejecutar como root en container

```dockerfile
# Crear usuario no-root
RUN useradd -m -u 1000 fnuser
USER fnuser

# No usar root
# USER root  # EVITAR
```

---

## Documentación Relacionada

- [OCI Functions Documentation](https://docs.oracle.com/en-us/iaas/Content/Functions/home.htm)
- [OCIR Documentation](https://docs.oracle.com/en-us/iaas/Content/Registry/home.htm)
- [Function Development Kits (FDK)](https://docs.oracle.com/en-us/iaas/Content/Functions/Tasks/functionsconfiguringcoderespository.htm)
- [Dockerfile Best Practices](https://docs.docker.com/develop/dev-best-practices/dockerfile_best-practices/)

---

## Licencia

UPL 1.0 - Oracle Universal Permissive License
