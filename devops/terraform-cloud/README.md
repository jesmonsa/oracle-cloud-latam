# Terraform Cloud/Enterprise - Gestión de Estado Remoto e IaC Automático

[![Deploy to OCI](https://img.shields.io/badge/Deploy-OCI-F80000?style=for-the-badge)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/download/latest/devops-terraform-cloud.zip)
[![Terraform](https://img.shields.io/badge/Terraform-v1.5+-623CE4?style=for-the-badge&logo=terraform)](https://www.terraform.io/downloads.html)
[![License](https://img.shields.io/badge/License-UPL%201.0-green.svg?style=for-the-badge)](../../LICENSE)

## Descripción

Esta arquitectura implementa **Terraform Cloud/Enterprise** para gestión empresarial de **Infrastructure as Code** en OCI:

- **Estado Remoto**: Almacenamiento centralizado y seguro del estado de Terraform
- **Runs Automáticos**: Ejecución automática en cambios de Git (VCS Integration)
- **Policy as Code**: Sentinel policies para compliance y seguridad
- **Cost Estimation**: Estimación automática de costos en cada plan
- **Team Management**: Control de acceso y roles por equipo
- **Audit Trail**: Registro completo de todas las operaciones
- **OCI Backend**: Integración nativa con Object Storage de OCI

## Casos de Uso

- Gestión centralizada de infraestructura OCI
- Automatización de Terraform en pipelines CI/CD
- Compliance y Policy as Code con Sentinel
- Estimación de costos antes de desplegar
- Gestión multi-equipo con control de acceso
- Auditoría y gobernanza de cambios

---

## Topología de Arquitectura

```
┌─────────────────────────────────────────────────────────────────────────┐
│         Terraform Cloud/Enterprise - Gestión Remota de IaC             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │  Git Repository (Single Source of Truth)                          │  │
│  │  ├─ Terraform Configuration Files (.tf)                           │  │
│  │  ├─ Backend Configuration (backend.tf)                            │  │
│  │  ├─ Variables (variables.tf, terraform.tfvars)                    │  │
│  │  ├─ Policies (Sentinel)                                           │  │
│  │  └─ Webhook Trigger                                               │  │
│  └────────────────────────────────────────────────────────────────▲─┘   │
│                              │                                     │      │
│                              ▼                                     │      │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │  Terraform Cloud/Enterprise                                       │  │
│  │                                                                    │  │
│  │  ┌───────────────────────────────────────────────────────────┐   │  │
│  │  │  VCS Integration                                          │   │  │
│  │  │  ├─ GitHub/GitLab Webhook                                 │   │  │
│  │  │  ├─ Automatic Plan on Push                                │   │  │
│  │  │  ├─ Plan Review & Comment                                 │   │  │
│  │  │  └─ Merge-driven Apply                                    │   │  │
│  │  └───────────────────────────────────────────────────────────┘   │  │
│  │                                                                    │  │
│  │  ┌───────────────────────────────────────────────────────────┐   │  │
│  │  │  Run Pipeline                                             │   │  │
│  │  │  ├─ Terraform Init                                        │   │  │
│  │  │  ├─ Terraform Plan                                        │   │  │
│  │  │  │  ├─ Cost Estimation                                    │   │  │
│  │  │  │  └─ Resource Drift Detection                           │   │  │
│  │  │  ├─ Policy Checks (Sentinel)                              │   │  │
│  │  │  │  ├─ Security Policies                                  │   │  │
│  │  │  │  ├─ Compliance Policies                                │   │  │
│  │  │  │  └─ Cost Policies                                      │   │  │
│  │  │  ├─ Manual Approval (si required)                         │   │  │
│  │  │  └─ Terraform Apply                                       │   │  │
│  │  └───────────────────────────────────────────────────────────┘   │  │
│  │                                                                    │  │
│  │  ┌───────────────────────────────────────────────────────────┐   │  │
│  │  │  State Management                                         │   │  │
│  │  │  ├─ Centralized State Storage                             │   │  │
│  │  │  ├─ State Versioning                                      │   │  │
│  │  │  ├─ State Locking                                         │   │  │
│  │  │  └─ Encryption (TLS + At-Rest)                            │   │  │
│  │  └───────────────────────────────────────────────────────────┘   │  │
│  │                                                                    │  │
│  │  ┌───────────────────────────────────────────────────────────┐   │  │
│  │  │  Team & Access Management                                 │   │  │
│  │  │  ├─ Organizations & Teams                                 │   │  │
│  │  │  ├─ Workspace-level Access                                │   │  │
│  │  │  ├─ SAML SSO (Enterprise)                                 │   │  │
│  │  │  └─ Audit Logging                                         │   │  │
│  │  └───────────────────────────────────────────────────────────┘   │  │
│  │                                                                    │  │
│  │  ┌───────────────────────────────────────────────────────────┐   │  │
│  │  │  API & CLI                                                │   │  │
│  │  │  ├─ RESTful API                                           │   │  │
│  │  │  ├─ Terraform CLI Integration                             │   │  │
│  │  │  ├─ VCS Webhooks                                          │   │  │
│  │  │  └─ Remote Runs via API                                   │   │  │
│  │  └───────────────────────────────────────────────────────────┘   │  │
│  └────────────────────────────────────────────────────────────────────┘  │
│                              │                                            │
│                              ▼                                            │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │  OCI Backend Integration                                           │  │
│  │  ├─ Object Storage (State Storage)                                 │  │
│  │  ├─ State Encryption (KMS)                                         │  │
│  │  ├─ State Versioning & Retention                                   │  │
│  │  └─ Dynamic Credentials (Workload Identity)                        │  │
│  └────────────────────────────────────────────────────────────────▲───┘  │
│                              │                                     │      │
│                              ▼                                     │      │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │  OCI Cloud Infrastructure                                          │  │
│  │  ├─ Compute Instances (OCI Compute)                               │  │
│  │  ├─ Networking (VCN, Subnets, NSG)                                │  │
│  │  ├─ Databases (MySQL, PostgreSQL)                                 │  │
│  │  ├─ Storage (Object Storage, Block Volume)                        │  │
│  │  ├─ Kubernetes (OKE)                                              │  │
│  │  └─ Load Balancers & Networking                                   │  │
│  └────────────────────────────────────────────────────────────────────┘  │
│                                                                           │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │  Observabilidad                                                    │  │
│  │  ├─ Cost Analysis                                                  │  │
│  │  ├─ Resource Drift Detection                                       │  │
│  │  ├─ Audit Logs                                                     │  │
│  │  ├─ Plan Notifications (Slack, Email)                              │  │
│  │  └─ Status Dashboard                                               │  │
│  └────────────────────────────────────────────────────────────────────┘  │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Componentes Principales

### 1. Terraform Cloud/Enterprise
```
- Workspace Management (por proyecto/ambiente)
- VCS Integration (GitHub, GitLab, Bitbucket)
- Automatic Plans & Applies
- Remote State Storage
- Policy as Code (Sentinel)
- Cost Estimation
- Team Management & RBAC
```

### 2. OCI Backend
```
- Object Storage para almacenar state
- State encryption con KMS
- State versioning y retention
- Dynamic Credentials via Workload Identity
- State locking automático
```

### 3. Policy as Code (Sentinel)
```
- Políticas de Seguridad
- Políticas de Compliance
- Políticas de Costo
- Evaluación automática
- Soft fail vs Hard fail policies
```

### 4. Run Pipeline
```
- VCS Change Detection
- Automatic Plan
- Policy Evaluation
- Cost Estimation
- Manual Review & Approval
- Automatic Apply (si configurado)
```

---

## Variables de Configuración

| Variable | Tipo | Requerido | Descripción | Ejemplo |
|---|---|---|---|---|
| `tenancy_ocid` | string | Sí | OCID del tenancy | ocid1.tenancy.oc1..xxxxx |
| `user_ocid` | string | Sí | OCID del usuario | ocid1.user.oc1..xxxxx |
| `fingerprint` | string | Sí | Fingerprint de la clave API | xx:xx:xx:xx |
| `private_key_path` | string | Sí | Ruta a la clave privada | ~/.oci/oci_api_key.pem |
| `region` | string | Sí | Región OCI | us-phoenix-1 |
| `compartment_id` | string | Sí | OCID del compartment | ocid1.compartment.oc1..xxxxx |
| `tfc_organization` | string | Sí | Organización en Terraform Cloud | my-company |
| `tfc_token` | string | Sí | Token de Terraform Cloud | xxxxxxxxxxxxxxxxxxxx |
| `vcs_oauth_token_id` | string | Sí | OAuth token ID para VCS | ot-xxxxxxxx |
| `vcs_repository` | string | Sí | Repositorio VCS | org/repo |
| `workspace_name` | string | Sí | Nombre del workspace | my-app-prod |
| `terraform_version` | string | No | Versión de Terraform | 1.5.0 |
| `enable_cost_estimation` | bool | No | Habilitar estimación de costos | true |
| `enable_sentinel_policies` | bool | No | Habilitar Policy as Code | true |
| `enable_vcs_integration` | bool | No | Habilitar integración VCS | true |
| `require_approval` | bool | No | Requerir aprobación manual | true |
| `enable_auto_apply` | bool | No | Aplicar automáticamente | false |
| `tags` | map | No | Tags para recursos | { Environment = "prod" } |

---

## Outputs Principales

- `tfc_workspace_id`: ID del workspace en Terraform Cloud
- `tfc_workspace_name`: Nombre del workspace
- `oci_state_bucket`: Nombre del bucket Object Storage para state
- `terraform_cloud_url`: URL de acceso a Terraform Cloud
- `workspace_execution_mode`: Modo de ejecución (remote, local)
- `policy_check_enabled`: Si Policy as Code está habilitada

---

## Flujo de Implementación

### Paso 1: Crear Cuenta en Terraform Cloud
```bash
# 1. Ir a https://app.terraform.io
# 2. Crear organización (o usar existente)
# 3. Generar API token: Settings → Tokens → Create API token
```

### Paso 2: Preparar Backend en OCI
```bash
# 1. Crear bucket Object Storage
oci os bucket create \
  --compartment-id $(terraform output -raw compartment_id) \
  --name terraform-state-bucket

# 2. Configurar encriptación KMS
# 3. Habilitar versionamiento
```

### Paso 3: Configurar VCS Integration
```bash
# 1. En Terraform Cloud: Settings → VCS Providers
# 2. Conectar GitHub/GitLab (OAuth)
# 3. Autorizar acceso al repositorio
```

### Paso 4: Crear Workspace
```bash
# Opción 1: Vía Terraform Cloud UI
# 1. New → Workspace
# 2. Seleccionar VCS provider
# 3. Seleccionar repositorio
# 4. Configurar workspace settings

# Opción 2: Vía Terraform
terraform apply
```

### Paso 5: Configurar Variables en Workspace
```bash
# Vía Terraform Cloud UI o API
# 1. Workspace → Variables
# 2. Agregar variables de Terraform
# 3. Agregar Environment variables (credenciales OCI)
```

### Paso 6: Disparar Run
```bash
# El primer push a la rama seleccionada dispara un plan automático
git push origin main

# Ver plan en Terraform Cloud UI
# Revisar cambios y aprobar si es necesario
```

---

## Costos Estimados (Mensuales)

| Componente | Uso | Precio USD |
|---|---|---|
| Terraform Cloud (Free) | Hasta 5 usuarios | $0 |
| Terraform Cloud (Pro) | Equipo completo | $20-100 |
| Terraform Enterprise | Auto-hosted | Consultar |
| OCI Object Storage | 10 GB estado | $5-10 |
| KMS Encryption | Key rotations | $5-10 |
| Data Transfer | API calls, sync | $0-5 |
| **Total Estimado** | | **$5-125** |

---

## Mejores Prácticas

### Structure
```
repo/
├── terraform/
│   ├── prod/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── staging/
│   │   └── ...
│   ├── dev/
│   │   └── ...
│   └── modules/
│       └── ...
├── policies/
│   ├── security.sentinel
│   ├── compliance.sentinel
│   └─└─ cost.sentinel
└── .github/workflows/
    └── terraform.yml
```

### Seguridad
- Usar Workload Identity en lugar de credenciales estáticas
- Almacenar secrets en OCI Vault
- Habilitar State Locking
- Auditar todos los runs
- Requerir aprobación manual en producción

### Confiabilidad
- Usar workspaces por ambiente
- Implementar Sentinel policies
- Monitorear cost estimation
- Mantener terraform versión controlada
- Documentar políticas y estándares

---

## Troubleshooting

### Error: "VCS connection failed"
**Solución**: Regenerar OAuth token en VCS provider
```bash
# Terraform Cloud → Settings → VCS Providers
# Reconectar OAuth
```

### Error: "State lock timeout"
**Solución**: Limpiar lock en Object Storage
```bash
# Ver buckets
oci os bucket list --compartment-id <COMPARTMENT_ID>

# Limpiar locks
oci os object delete \
  --bucket-name terraform-state-bucket \
  --object-name <LOCK_FILE>
```

### Error: "Cost estimation failed"
**Solución**: Validar credenciales de OCI
```bash
# Verificar variables de ambiente en workspace
# Asegurar que las credenciales tengan permisos suficientes
```

---

## Limpieza de Recursos

```bash
# 1. Destroy en Terraform Cloud (vía UI o API)
# 2. Eliminar workspace
# 3. Eliminar bucket Object Storage
# 4. Destruir todos los recursos
terraform destroy
```

---

## Documentación Relacionada

- [Terraform Cloud Documentation](https://www.terraform.io/cloud/docs)
- [Terraform Enterprise](https://www.terraform.io/enterprise)
- [OCI Backend Configuration](https://www.terraform.io/language/settings/backends/s3)
- [Sentinel Policy Language](https://www.hashicorp.com/resources/sentinel-policy-as-code-framework)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices)

---

## Soporte

- Reportar issues en [GitHub Issues](https://github.com/jesmonsa/oracle-cloud-latam/issues)
- Crear discussions en [GitHub Discussions](https://github.com/jesmonsa/oracle-cloud-latam/discussions)

**Versión**: 1.0.0  
**Última actualización**: 2024
