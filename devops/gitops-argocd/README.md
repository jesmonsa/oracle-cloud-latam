# GitOps con ArgoCD - Sincronización Continua en OKE

[![Deploy to OCI](https://img.shields.io/badge/Deploy-OCI-F80000?style=for-the-badge)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/download/latest/devops-gitops-argocd.zip)
[![Terraform](https://img.shields.io/badge/Terraform-v1.5+-623CE4?style=for-the-badge&logo=terraform)](https://www.terraform.io/downloads.html)
[![License](https://img.shields.io/badge/License-UPL%201.0-green.svg?style=for-the-badge)](../../LICENSE)

## Descripción

Esta arquitectura implementa **GitOps declarativo** en Kubernetes usando **ArgoCD**, integrado con **OCI DevOps** para automatización completa:

- **ArgoCD**: Controlador GitOps que sincroniza manifiestos Git con el cluster Kubernetes
- **OCI DevOps**: Pipelines que disparan cambios en los repositorios Git
- **OKE**: Cluster Kubernetes gestionado en OCI
- **Helm**: Gestión de charts para aplicaciones
- **ApplicationSet**: Gestión multi-ambiente con plantillas dinámicas
- **Notifications**: Alertas en Slack/Email de cambios

## Casos de Uso

- Despliegues declarativos sin scripting manual
- GitOps multi-ambiente (dev, staging, prod)
- Sincronización automática del estado deseado
- Reconciliación continua (auto-healing)
- Auditoría completa via Git
- Integración con OCI DevOps para CI/CD

---

## Topología de Arquitectura

```
┌─────────────────────────────────────────────────────────────────────────┐
│                   GitOps Architecture con ArgoCD                        │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │  Git Repositories (Single Source of Truth)                        │  │
│  │  ├─ Application Manifests Repository                              │  │
│  │  │  ├─ dev/                                                       │  │
│  │  │  ├─ staging/                                                   │  │
│  │  │  └─ prod/                                                      │  │
│  │  ├─ Helm Charts Repository                                        │  │
│  │  ├─ ArgoCD Configuration Repository                               │  │
│  │  └─ OCI DevOps Pipeline Definitions                               │  │
│  └────────────────────────────────────────────────────────────────▲─┘   │
│                              │                                     │      │
│                              ▼                                     │      │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │  OCI DevOps Service (Trigger Pipeline)                            │  │
│  │  ├─ Code Repository                                               │  │
│  │  ├─ Build Pipeline (Tests, Image Build)                          │  │
│  │  ├─ Deploy Pipeline (Update Git)                                 │  │
│  │  └─ Notification Topic                                            │  │
│  └────────────────────────────────────────────────────────────────▲─┘   │
│                              │                                     │      │
│                              ▼                                     │      │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │  ArgoCD on OKE (Sync Controller)                                  │  │
│  │  ├─ Application Controllers                                       │  │
│  │  ├─ Repository Monitoring                                         │  │
│  │  ├─ Sync Engine                                                   │  │
│  │  ├─ Health Assessment                                             │  │
│  │  └─ Notifications                                                 │  │
│  └────────────────────────────────────────────────────────────────▲─┘   │
│                              │                                     │      │
│           ┌──────────────────┼──────────────────┐                  │      │
│           ▼                  ▼                  ▼                   │      │
│  ┌─────────────────┐ ┌─────────────────┐ ┌──────────────────┐    │      │
│  │  Dev Namespace  │ │ Staging Namespace│ │ Prod Namespace  │    │      │
│  │                 │ │                   │ │                  │    │      │
│  │ ┌────────────┐  │ │ ┌────────────┐   │ │ ┌──────────────┐│    │      │
│  │ │ Deployment │  │ │ │ Deployment │   │ │ │ Deployment   ││    │      │
│  │ │ Pod        │  │ │ │ Pod        │   │ │ │ Pod          ││    │      │
│  │ │ Service    │  │ │ │ Service    │   │ │ │ Service      ││    │      │
│  │ │ ConfigMap  │  │ │ │ ConfigMap  │   │ │ │ ConfigMap    ││    │      │
│  │ └────────────┘  │ │ └────────────┘   │ │ └──────────────┘│    │      │
│  └─────────────────┘ └─────────────────┘ └──────────────────┘    │      │
│                                                                     │      │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │  ArgoCD Web UI & API                                              │  │
│  │  ├─ Dashboard (Applications, Health)                              │  │
│  │  ├─ Diff Viewer (Git vs Live State)                              │  │
│  │  ├─ Logs & Events                                                 │  │
│  │  └─ API para automatización                                       │  │
│  └────────────────────────────────────────────────────────────────────┘  │
│                                                                           │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │  Observabilidad y Notificaciones                                  │  │
│  │  ├─ OCI Monitoring (Métricas de ArgoCD)                          │  │
│  │  ├─ OCI Logging (Logs de sincronización)                         │  │
│  │  ├─ Slack/Email Notifications                                     │  │
│  │  └─ Audit Trail                                                   │  │
│  └────────────────────────────────────────────────────────────────────┘  │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Componentes Principales

### 1. ArgoCD
```
- Controlador GitOps declarativo
- Sincronización automática (auto-sync)
- Detección de cambios en Git
- Health assessment de aplicaciones
- Rollback a versiones anteriores
- API para integración externa
```

### 2. OCI DevOps Integration
```
- Pipeline triggers en cambios de código
- Actualización automática de manifiestos
- Notificaciones a ArgoCD
- Auditoría de despliegues
- Multi-environment support
```

### 3. Application Management
```
- Declaración de aplicaciones en Git
- Helm charts para reutilización
- ApplicationSet para multi-ambiente
- Sync policies personalizadas
- Pre-sync y post-sync hooks
```

### 4. Kubernetes Resources
```
- Deployments con auto-scaling
- Services para acceso
- ConfigMaps para configuración
- Secrets para credenciales
- Persistent Volumes
- Ingress para routing
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
| `oke_cluster_id` | string | Sí | OCID del cluster OKE existente | ocid1.cluster.oc1..xxxxx |
| `oke_cluster_name` | string | Sí | Nombre del cluster OKE | my-app-cluster |
| `argocd_namespace` | string | No | Namespace de ArgoCD | argocd |
| `argocd_version` | string | No | Versión de ArgoCD | v2.10.0 |
| `enable_ingress` | bool | No | Crear Ingress para ArgoCD | true |
| `repository_url` | string | Sí | URL del repositorio Git | https://github.com/org/repo |
| `repository_branch` | string | No | Rama a sincronizar | main |
| `enable_notifications` | bool | No | Habilitar notificaciones | true |
| `notification_slack_webhook` | string | No | Webhook de Slack | https://hooks.slack.com/... |
| `enable_monitoring` | bool | No | Integrar OCI Monitoring | true |
| `tags` | map | No | Tags para recursos | { Environment = "prod" } |

---

## Outputs Principales

- `argocd_namespace`: Namespace donde se instaló ArgoCD
- `argocd_admin_password`: Contraseña inicial del admin
- `argocd_server_url`: URL del servidor ArgoCD
- `argocd_ingress_ip`: IP pública de Ingress (si está habilitado)
- `kubeconfig_path`: Ruta al kubeconfig del cluster
- `oke_cluster_id`: OCID del cluster OKE

---

## Flujo de Implementación

### Paso 1: Desplegar la Infraestructura
```bash
cd gitops-argocd
terraform init
terraform plan
terraform apply
```

### Paso 2: Acceder a ArgoCD
```bash
# Obtener credenciales
ARGOCD_PASSWORD=$(terraform output -raw argocd_admin_password)
ARGOCD_URL=$(terraform output -raw argocd_server_url)

# Acceder vía port-forward (si no hay Ingress)
kubectl port-forward -n argocd svc/argocd-server 8080:443

# Navegar a https://localhost:8080
```

### Paso 3: Configurar Repositorio Git
```bash
# Agregar repositorio a ArgoCD
argocd repo add https://github.com/org/repo \
  --username <username> \
  --password <token>
```

### Paso 4: Crear Aplicación
```bash
# Vía CLI
argocd app create my-app \
  --repo https://github.com/org/repo \
  --path k8s/prod \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default

# O vía Git (GitOps)
cat > application.yaml << 'EOF'
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
spec:
  project: default
  source:
    repoURL: https://github.com/org/repo
    targetRevision: main
    path: k8s/prod
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF
```

### Paso 5: Sincronizar Cambios
```bash
# Sincronizar automáticamente (auto-sync habilitado)
# O manual
argocd app sync my-app
```

---

## Costos Estimados (Mensuales)

| Componente | Uso | Precio USD |
|---|---|---|
| OKE Cluster (3 nodes) | 730 horas | $150-250 |
| ArgoCD Server | Incluido en nodos OKE | $0 |
| Load Balancer | Traffic | $10-30 |
| Data Transfer | 50 GB/mes | $5-10 |
| Monitoring/Logging | OCI | $20-30 |
| **Total Estimado** | | **$185-320** |

---

## Mejores Prácticas GitOps

### Structure
```
repo/
├── k8s/
│   ├── base/
│   │   ├── kustomization.yaml
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   ├── dev/
│   │   └── kustomization.yaml (overlay)
│   ├── staging/
│   │   └── kustomization.yaml (overlay)
│   └── prod/
│       └── kustomization.yaml (overlay)
├── helm/
│   ├── my-app/
│   │   ├── values.yaml
│   │   ├── values-dev.yaml
│   │   ├── values-staging.yaml
│   │   └── values-prod.yaml
└── argocd/
    ├── applications.yaml
    └── applicationset.yaml
```

### Seguridad
- Usar GitHub Enterprise o repositorios privados
- Implementar RBAC en ArgoCD
- Secretos en OCI Vault, no en Git
- Firmar commits y tags

### Confiabilidad
- Implementar auto-sync con prune
- Configurar health checks
- Usar sync waves para orden
- Notificaciones de cambios

---

## Troubleshooting

### Error: "Application out of sync"
**Solución**: Ejecutar sync manual o verificar Git
```bash
argocd app sync my-app
git push origin main
```

### Error: "ArgoCD server unreachable"
**Solución**: Verificar servicio y networking
```bash
kubectl get svc -n argocd
kubectl logs -n argocd svc/argocd-server
```

### Error: "Repository authentication failed"
**Solución**: Regenerar credenciales Git
```bash
argocd repo remove https://github.com/org/repo
argocd repo add https://github.com/org/repo --username <user> --password <token>
```

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

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [OCI OKE Documentation](https://docs.oracle.com/en-us/iaas/Content/ContEng/home.htm)
- [GitOps Best Practices](https://www.weave.works/blog/gitops-operations-by-pull-request)
- [Helm Charts](https://helm.sh/docs/)

---

## Soporte

- Reportar issues en [GitHub Issues](https://github.com/jesmonsa/oracle-cloud-latam/issues)
- Crear discussions en [GitHub Discussions](https://github.com/jesmonsa/oracle-cloud-latam/discussions)

**Versión**: 1.0.0  
**Última actualización**: 2024
