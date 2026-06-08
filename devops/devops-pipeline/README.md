# OCI DevOps Pipeline - Arquitectura de CI/CD Completa

[![Deploy to OCI](https://img.shields.io/badge/Deploy-OCI-F80000?style=for-the-badge)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/download/latest/devops-devops-pipeline.zip)
[![Terraform](https://img.shields.io/badge/Terraform-v1.5+-623CE4?style=for-the-badge&logo=terraform)](https://www.terraform.io/downloads.html)
[![License](https://img.shields.io/badge/License-UPL%201.0-green.svg?style=for-the-badge)](../../LICENSE)

## Descripción

Esta arquitectura proporciona un **pipeline CI/CD completo y empresarial** utilizando OCI DevOps Service. Automatiza el flujo desde la confirmación de código hasta el despliegue en Kubernetes Engine (OKE), incluyendo:

- **Repositorio de Código**: OCI Code Repository (Git nativo)
- **Build Pipeline**: Compilación, testing y empaquetamiento automático
- **Container Registry**: Almacenamiento seguro de imágenes Docker
- **Deployment Pipeline**: Despliegue automático a OKE
- **Notificaciones**: Alertas en cada etapa del pipeline
- **Monitoreo**: Integración con OCI Monitoring y Logging

## Casos de Uso

- Aplicaciones Java/Spring Boot con Maven o Gradle
- Aplicaciones Node.js con npm
- Microservicios en contenedores
- Despliegues multi-ambiente (Dev, Staging, Prod)
- Automatización de testing y quality gates
- CI/CD para equipos de desarrollo ágiles

---

## Topología de Arquitectura

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     OCI DevOps Pipeline Completo                        │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │  Trigger Layer (Webhooks)                                        │   │
│  │  ├─ Git Push Webhook                                             │   │
│  │  ├─ Manual Trigger                                               │   │
│  │  └─ Scheduled Trigger                                            │   │
│  └────────────────────────────────────────────────────────────────▲─┘   │
│                              │                                     │      │
│                              ▼                                     │      │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │  OCI Code Repository                                             │   │
│  │  ├─ Main Branch (Protected)                                      │   │
│  │  ├─ Develop Branch                                               │   │
│  │  └─ Feature Branches                                             │   │
│  └────────────────────────────────────────────────────────────────▲─┘   │
│                              │                                     │      │
│                              ▼                                     │      │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │  Build Stage (Build Pipeline)                                    │   │
│  │  ├─ Checkout Code                                                │   │
│  │  ├─ Install Dependencies                                         │   │
│  │  ├─ Run Unit Tests                                               │   │
│  │  ├─ Code Quality Scan (SonarQube)                               │   │
│  │  ├─ Build Artifact (JAR/WAR)                                    │   │
│  │  ├─ Build Container Image                                        │   │
│  │  └─ Push to Container Registry                                  │   │
│  └────────────────────────────────────────────────────────────────▲─┘   │
│                              │                                     │      │
│                              ▼                                     │      │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │  Registry Storage Layers                                         │   │
│  │  ├─ Container Registry (Docker Images)                          │   │
│  │  │  └─ Image Scanning (Vulnerability Detection)                 │   │
│  │  └─ Artifact Registry (JAR/WAR)                                 │   │
│  │     └─ Version Management                                        │   │
│  └────────────────────────────────────────────────────────────────▲─┘   │
│                              │                                     │      │
│                              ▼                                     │      │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │  Deployment Stage (Deploy Pipeline)                             │   │
│  │  ├─ Pull Image from Container Registry                          │   │
│  │  ├─ Deploy to OKE Cluster                                       │   │
│  │  │  └─ Create Deployment, Service, Ingress                      │   │
│  │  ├─ Run Health Checks                                           │   │
│  │  ├─ Run Smoke Tests                                             │   │
│  │  └─ Update DNS & Load Balancer                                  │   │
│  └────────────────────────────────────────────────────────────────▲─┘   │
│                              │                                     │      │
│                              ▼                                     │      │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │  Post-Deployment                                                │   │
│  │  ├─ Notifications (Slack, Email, Webhook)                       │   │
│  │  ├─ Metrics Collection (OCI Monitoring)                         │   │
│  │  ├─ Log Aggregation (OCI Logging)                               │   │
│  │  └─ Audit Trail                                                 │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                                                                           │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │  Kubernetes Engine (OKE)                                         │   │
│  │  ├─ Compute Nodes (Auto-Scaling)                               │   │
│  │  ├─ Persistent Volumes                                          │   │
│  │  ├─ Load Balancer (LB)                                          │   │
│  │  └─ Monitoring + Logging                                        │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Componentes Principales

### 1. OCI Code Repository
```
- Repositorio Git nativo (no requiere GitHub/GitLab)
- Ramas protegidas y revisión de código
- Webhooks para triggers automáticos
- Auditoría de cambios completa
```

### 2. Build Pipeline
```
- Ejecución de scripts (shell, bash)
- Caché de dependencias
- Publicación de artefactos
- Notificaciones de estado
```

### 3. Container Registry
```
- Almacenamiento privado de imágenes
- Scans de vulnerabilidades (CVE)
- Políticas de retención
- Replicación a múltiples regiones
```

### 4. Deployment Pipeline
```
- Despliegue a OKE (Kubernetes)
- Estrategias Blue-Green y Canary
- Rollback automático
- Health checks post-deploy
```

### 5. OKE Cluster
```
- Nodos de compute escalables
- Networking avanzado (NSG, VCN)
- Load Balancer integrado
- Persistent Storage (Block, File)
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
| `project_name` | string | Sí | Nombre del proyecto | my-app-devops |
| `app_name` | string | Sí | Nombre de la aplicación | my-app |
| `environment` | string | Sí | Ambiente | dev, staging, prod |
| `oke_cluster_name` | string | Sí | Nombre del cluster OKE | my-app-oke-cluster |
| `repository_branch` | string | No | Rama a usar en pipeline | main |
| `container_repository_name` | string | No | Nombre del repositorio container | my-app/backend |
| `build_run_memory` | number | No | Memoria para builds (MB) | 2048 |
| `enable_notifications` | bool | No | Habilitar notificaciones | true |
| `notification_topic_endpoint` | string | No | Endpoint para notificaciones (Slack/Email) | https://hooks.slack.com/... |
| `enable_monitoring` | bool | No | Habilitar monitoreo | true |
| `cost_tracking_enabled` | bool | No | Rastreo de costos | true |
| `tags` | map | No | Tags para recursos | { Environment = "dev", Team = "platform" } |

---

## Outputs Principales

- `devops_project_id`: OCID del proyecto DevOps
- `build_pipeline_id`: OCID del pipeline de build
- `deploy_pipeline_id`: OCID del pipeline de despliegue
- `repository_http_url`: URL HTTP del repositorio Git
- `repository_ssh_url`: URL SSH del repositorio Git
- `container_registry_url`: URL del Container Registry
- `oke_cluster_id`: OCID del cluster OKE
- `oke_kubeconfig`: Configuración de kubectl

---

## Flujo de Implementación

### Paso 1: Desplegar la Infraestructura
```bash
cd devops-pipeline
terraform init
terraform plan
terraform apply
```

### Paso 2: Configurar el Repositorio Git
```bash
# Clonar el repositorio OCI
git clone <repository_http_url>
cd <project_name>

# Copiar código de la aplicación
cp -r /ruta/a/aplicacion/* .

# Crear archivo de configuración del pipeline
cat > build_spec.yaml << 'EOF'
version: 0.1
component: build
timeoutInMinutes: 10
runAs: root
stages:
  - displayName: "Build Stage"
    stepDefinitions:
      - name: "Maven Build"
        timeoutInMinutes: 5
        onFailure: CONTINUE
        runAs: root
        shell: BASH
        command: |
          mvn clean package -DskipTests
EOF

git add .
git commit -m "Initial commit with build configuration"
git push -u origin main
```

### Paso 3: Configurar Pipeline de Build
```bash
# El terraform crea la pipeline automáticamente
# Validar que el pipeline se creó correctamente
terraform output build_pipeline_id
```

### Paso 4: Generar Credenciales de Deploy
```bash
# Obtener kubeconfig del cluster OKE
oci ce cluster create-kubeconfig \
  --cluster-id $(terraform output -raw oke_cluster_id) \
  --file $HOME/.kube/config

# Validar acceso al cluster
kubectl cluster-info
```

### Paso 5: Disparar el Pipeline
```bash
# El pipeline se dispara automáticamente en push a main
# O disparar manualmente
oci devops build-pipeline create-build-run-details \
  --build-pipeline-id $(terraform output -raw build_pipeline_id)
```

---

## Costos Estimados (Mensuales)

| Componente | Uso | Precio USD |
|---|---|---|
| OCI DevOps (Build) | 200 builds/mes | $100-200 |
| Container Registry | 10 GB almacenado | $20-30 |
| OKE (3 nodes E3.Flex) | 730 horas | $150-250 |
| Data Transfer | 50 GB/mes | $10-20 |
| Monitoring/Logging | Estándar | $20-30 |
| **Total Estimado** | | **$300-530** |

---

## Monitoreo y Logs

### Acceder a Logs del Pipeline
```bash
# Ver logs de build
oci devops build-run list \
  --build-pipeline-id $(terraform output -raw build_pipeline_id) \
  --limit 10

# Ver logs de despliegue
oci devops deployment list \
  --deploy-pipeline-id $(terraform output -raw deploy_pipeline_id) \
  --limit 10
```

### Metrícas Clave
- **Build Success Rate**: Porcentaje de builds exitosos
- **Deploy Success Rate**: Porcentaje de despliegues exitosos
- **Pipeline Duration**: Tiempo total del pipeline
- **Container Registry Size**: Tamaño total de imágenes

---

## Troubleshooting

### Error: "Build stage failed"
**Solución**: Verificar el archivo `build_spec.yaml`
```bash
# Ver logs detallados
oci devops build-run-stage-summary list \
  --build-run-id <BUILD_RUN_ID>
```

### Error: "Deployment failed to OKE"
**Solución**: Validar credenciales y permisos
```bash
# Verificar acceso al cluster
kubectl get nodes
kubectl describe deployment -n default
```

### Error: "Container image not found"
**Solución**: Verificar que la imagen se publicó correctamente
```bash
# Listar imágenes
oci artifacts container image list \
  --compartment-id $(terraform output -raw compartment_id)
```

### Error: "DNS/LoadBalancer not resolving"
**Solución**: Esperar a que se asigne la IP pública
```bash
# Verificar service
kubectl get svc -n default
kubectl describe svc <service-name> -n default
```

---

## Mejores Prácticas

### Seguridad
- Usar ramas protegidas y requerir revisión de código
- Implementar scans de vulnerabilidades en imágenes
- Usar OCI Vault para credenciales sensibles
- Auditar todos los cambios y despliegues

### Confiabilidad
- Implementar health checks post-deployment
- Usar estrategias Blue-Green para cambios de tráfico
- Mantener rollback rápido y automático
- Monitorear tasas de éxito de pipelines

### Performance
- Cachear dependencias en build stage
- Usar imágenes base optimizadas
- Paralelizar builds cuando sea posible
- Monitorear tiempo total del pipeline

### Escalabilidad
- Configurar auto-scaling en OKE
- Usar múltiples réplicas de la aplicación
- Implementar load balancing
- Planificar capacidad basada en métricas

---

## Limpieza de Recursos

```bash
# Destruir todos los recursos
terraform destroy

# Confirmar eliminación
# Esperar 5 minutos para completar
```

---

## Documentación Relacionada

- [OCI DevOps Documentation](https://docs.oracle.com/en-us/iaas/devops/using/home.htm)
- [OCI Container Registry](https://docs.oracle.com/en-us/iaas/Content/Registry/Concepts/registryoverview.htm)
- [OCI Kubernetes Engine](https://docs.oracle.com/en-us/iaas/Content/ContEng/home.htm)
- [Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [Best Practices for CI/CD](https://docs.oracle.com/en-us/iaas/devops/using/cicd_best_practices.htm)

---

## Soporte

- Reportar issues en [GitHub Issues](https://github.com/jesmonsa/oracle-cloud-latam/issues)
- Crear discussions en [GitHub Discussions](https://github.com/jesmonsa/oracle-cloud-latam/discussions)

**Versión**: 1.0.0  
**Última actualización**: 2024
