# OCI Data Science - Plataforma Integrada de ML

[![OCI](https://img.shields.io/badge/Oracle-Cloud-F80000?style=flat-square)](https://www.oracle.com/cloud/)
[![Terraform](https://img.shields.io/badge/Terraform-1.5+-844FFF?style=flat-square&logo=terraform)](https://www.terraform.io/)
[![Deploy](https://img.shields.io/badge/Deploy-Stack-green?style=flat-square)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/download/latest/ai-data-science.zip)

## Descripción

Despliegue de **OCI Data Science**, la plataforma completamente gestionada de Oracle Cloud para ciencia de datos, machine learning e IA. Incluye:

- **Notebook Sessions** — Entornos Jupyter interactivos preconfigurados con librerías ML
- **Model Catalog** — Repositorio centralizado para versionado y gestión de modelos
- **Jobs** — Ejecución automática de scripts Python/R para entrenamiento y batch processing
- **Feature Store** — Gestión centralizada de features para ML
- **Model Deployment** — Endpoints HTTP para inferencia

Esta arquitectura es ideal para:
- Equipos de Data Science que requieren entorno colaborativo
- Experimentos iterativos sin infraestructura
- Pipelines MLOps escalables
- Prototipado rápido con gestión de versiones

## Arquitectura

```
┌─────────────────────────────────────────────────────────┐
│         OCI Data Science Platform                       │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────┐      ┌──────────────┐                 │
│  │   Notebook   │      │   Notebook   │                 │
│  │   Session 1  │      │   Session 2  │                 │
│  │   (JupyterLab)      │   (JupyterLab)      │
│  └──────────────┘      └──────────────┘      │
│                                              │
│  ┌────────────────────────────────────┐     │
│  │      Model Catalog                 │     │
│  │  (Versionado de modelos)           │     │
│  │  - Metadata                        │     │
│  │  - Artefactos serializado          │     │
│  └────────────────────────────────────┘     │
│                                              │
│  ┌────────────────────────────────────┐     │
│  │      Jobs                          │     │
│  │  (Ejecución scheduled/manual)      │     │
│  │  - Training jobs                   │     │
│  │  - Batch prediction                │     │
│  └────────────────────────────────────┘     │
│                                              │
│  ┌────────────────────────────────────┐     │
│  │      Feature Store                 │     │
│  │  (Feature engineering hub)         │     │
│  └────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────┘
         ↓                              ↓
    ┌─────────────┐         ┌──────────────────┐
    │ Object      │         │   Model          │
    │ Storage     │         │   Deployment     │
    │ (Datos)     │         │   (Endpoints)    │
    └─────────────┘         └──────────────────┘
```

## Componentes

### 1. OCI Data Science Project
- **Descripción**: Contenedor lógico para organizar trabajos, notebooks y modelos
- **Configuración**:
  - Nombre del proyecto
  - Descripción
  - Tags para tracking

### 2. Notebook Sessions
- **Tipo**: Instancias JupyterLab totalmente gestionadas
- **Características**:
  - Ambientes preconfigurados (Python 3.10, R, conda)
  - Librerías preinstaladas (pandas, scikit-learn, TensorFlow, PyTorch)
  - 1-32 OCPU (CPU o GPU)
  - Almacenamiento de 50-200 GB
  - Acceso integrado a Object Storage
- **Casos de uso**: Exploración de datos, experimentación, prototipado

### 3. Model Catalog
- **Propósito**: Gestión centralizada y versionado de modelos ML
- **Metadatos capturados**:
  - Nombre, versión, descripción
  - Métricas de evaluación (accuracy, precision, recall)
  - Hiperparámetros usados
  - Dataset training
  - Custom metadata
- **Soporta**: TensorFlow, PyTorch, scikit-learn, XGBoost, custom frameworks

### 4. Jobs
- **Tipo**: Ejecución sin servidor de scripts Python/R
- **Configuración**:
  - Entrypoint script
  - Argumentos
  - Computación (CPU/GPU)
  - Scheduled (cron) o manual
  - Logging automático a Object Storage
- **Ideal para**: Entrenamiento automático, reentrenamiento periódico, batch inference

### 5. Feature Store (Opcional)
- **Función**: Repositorio centralizado de features computadas
- **Ventajas**:
  - Reutilización de features entre modelos
  - Versionado de features
  - Evita data leakage

## Variables de Configuración

```hcl
# Identidad
region                    = "us-phoenix-1"
compartment_id            = "ocid1.compartment.oc1..xxxxx"
environment               = "prod"
project_name              = "mi-proyecto-ds"

# Data Science
data_science_project_name = "ml-platform"
data_science_description  = "Plataforma de ciencia de datos integrada"

# Notebook Session
notebook_enabled          = true
notebook_shape            = "VM.Standard.E4.Flex"     # CPU
notebook_ocpus            = 4
notebook_memory_in_gbs    = 32
notebook_display_name     = "Notebook Principal"

# GPU Notebook (opcional)
gpu_notebook_enabled      = false
gpu_notebook_shape        = "VM.GPU.A10.1"
gpu_notebook_ocpus        = 16
gpu_notebook_memory_gbs   = 104

# Jobs
job_enabled               = true
job_shape                 = "VM.Standard.E4.Flex"
job_ocpus                 = 4
job_memory_gbs            = 32

# Storage
object_storage_bucket     = "data-science-bucket"
bucket_versioning_enabled = true

# Tags
tags = {
  "Environment"  = "prod"
  "Service"      = "data-science"
  "Team"         = "ml-team"
  "CostCenter"   = "123456"
}
```

## Outputs

La ejecución de Terraform proporciona:

```hcl
data_science_project_id           = "ocid1.datascienceproject.oc1.phx..."
notebook_session_id               = "ocid1.notebooksession.oc1.phx..."
notebook_session_url              = "https://xxx.datascience.oci.oraclecloud.com/..."
model_catalog_namespace           = "data-science-models"
object_storage_namespace          = "mynamespace"
object_storage_bucket_name        = "data-science-bucket"
```

## Despliegue

### 1. Preparar Variables
```bash
cd ai/data-science
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars
```

### 2. Inicializar Backend
```bash
terraform init \
  -backend-config="bucket=tu-bucket-terraform" \
  -backend-config="key=ai/data-science/terraform.tfstate" \
  -backend-config="region=us-phoenix-1" \
  -backend-config="endpoint=https://region.compat.objectstorage.oraclecloud.com"
```

### 3. Validar Configuración
```bash
terraform validate
terraform plan
```

### 4. Desplegar
```bash
terraform apply
```

### 5. Acceder a Notebook
```bash
# El output proporciona la URL directa
terraform output notebook_session_url

# O acceder desde OCI Console
# Data Science > Projects > [proyecto] > Notebook Sessions
```

## Uso Práctico

### Crear una Sesión Notebook
```bash
# Las sesiones se crean automáticamente si notebook_enabled = true
# Para crear adicionales:
oci data-science notebook-session create \
  --project-id <project-id> \
  --notebook-session-configuration-details \
    "shape=VM.Standard.E4.Flex,subnetId=<subnet-id>"
```

### Subir Script de Training a Jobs
```bash
# Preparar script
cat > train.py << 'EOF'
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
import joblib

df = pd.read_csv('/tmp/data.csv')
X = df.drop('target', axis=1)
y = df['target']

model = RandomForestClassifier(n_estimators=100)
model.fit(X, y)

joblib.dump(model, 'model.joblib')
print("Training completado!")
EOF

# Crear job
oci data-science job create \
  --project-id <project-id> \
  --job-configuration-details \
    "jobType=PYTHON_JOB,entryPoint=train.py" \
  --job-infrastructure-configuration-details \
    "jobInfrastructureType=STANDALONE,shape=VM.Standard.E4.Flex"
```

### Registrar Modelo en Catalog
```python
# Desde notebook JupyterLab
from ads.catalog.model import ModelCatalog
import joblib

model = RandomForestClassifier()
model.fit(X_train, y_train)

# Guardar en Model Catalog
catalog_model = ModelCatalog.save(
    estimator=model,
    artifact_dir="./model_artifact",
    framework="scikit-learn",
    description="Random Forest para clasificación",
    training_id="training-001",
    custom_metadata_list=[
        {"accuracy": 0.95},
        {"precision": 0.93}
    ]
)

print(f"Modelo guardado con ID: {catalog_model.id}")
```

## Monitoreo y Troubleshooting

### Verificar Estado de Sesión Notebook
```bash
oci data-science notebook-session get --notebook-session-id <id>
```

### Ver Logs de Jobs
```bash
oci data-science job-run get --job-run-id <run-id>
oci data-science job-run-log list --job-run-id <run-id>
```

### Problemas Comunes

| Problema | Causa | Solución |
|---|---|---|
| Notebook no inicia | Subnet sin NAT | Configurar NAT Gateway o usar Public Subnet |
| Job falla con timeout | Tiempo insuficiente | Aumentar `job_max_wait_duration_in_minutes` |
| Permiso denegado | IAM policy incorrecta | Verificar policy en compartment |
| Storage lleno | Notebook session limitado | Aumentar `notebook_block_storage_size_in_gbs` |

## Políticas IAM Requeridas

```hcl
# Permitir acceso a Data Science
Allow group <group-name> to manage data-science-family in compartment <compartment-name>

# Permitir crear Notebook Sessions
Allow group <group-name> to manage notebook-sessions in compartment <compartment-name>

# Permitir acceso a Object Storage
Allow group <group-name> to manage objects in compartment <compartment-name>

# Permitir crear Jobs
Allow group <group-name> to manage data-science-jobs in compartment <compartment-name>
```

## Estimación de Costos

| Componente | Precio |
|---|---|
| Notebook Session (per hora, CPU) | USD 0.10/OCPU + 0.01/GB RAM |
| Notebook Session (per hora, GPU A10) | USD 0.80/hora |
| Model Catalog Storage | USD 0.023/GB/mes |
| Jobs (per OCPUhora) | USD 0.01/OCPUh |
| Object Storage | USD 0.023/GB/mes (primeros 100 GB gratis) |

**Ejemplo costo mensual** (desarrollo):
- 1 Notebook (4 OCPU, 32 GB) — 730 horas: USD 365 + USD 23 = USD 388
- Storage Model Catalog (10 GB): USD 0.23
- Jobs (100 OCPUh): USD 1
- **Total aprox**: USD 389/mes

## Documentación Referencias

- [OCI Data Science Docs](https://docs.oracle.com/en-us/iaas/data-science/using/home.htm)
- [OCI Data Science Python SDK](https://docs.oracle.com/en-us/iaas/tools/ads-sdk/latest/)
- [Terraform OCI Provider - Data Science](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/datascience_project)
- [OCI ML Best Practices](https://docs.oracle.com/en/learn/oci-ml-best-practices/)

## Soporte

Para soporte técnico:
1. Consulta [OCI Documentation](https://docs.oracle.com/)
2. Abre un issue en [GitHub](https://github.com/jesmonsa/oracle-cloud-latam/issues)
3. Contacta a [Oracle Support](https://support.oracle.com/)

---

**Última actualización**: 2026-04-12 | **Versión**: 1.0.0
