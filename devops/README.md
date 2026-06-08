# DevOps - OCI Terraform Reference Architecture

[![Terraform](https://img.shields.io/badge/Terraform-v1.5+-623CE4?style=for-the-badge&logo=terraform)](https://www.terraform.io/downloads.html)
[![OCI](https://img.shields.io/badge/OCI-v5+-F80000?style=for-the-badge&logo=oracle)](https://registry.terraform.io/providers/oracle/oci/latest/docs)
[![License](https://img.shields.io/badge/License-UPL%201.0-green.svg?style=for-the-badge)](LICENSE)
[![LATAM](https://img.shields.io/badge/LATAM-Ready-purple.svg?style=for-the-badge)](https://www.oracle.com/latin-america/)

## Descripción

Esta sección contiene arquitecturas empresariales de **CI/CD y DevOps** para Oracle Cloud Infrastructure (OCI), utilizando los servicios nativos de OCI:

- **OCI DevOps Service**: Servicio gestionado para pipelines de CI/CD completos
- **OCI Container Registry**: Registro privado de imágenes de contenedores
- **OCI Artifact Registry**: Registro gestionado para artefactos versionados (JAR, NPM, Maven, etc.)
- **Kubernetes Engine (OKE)**: Orquestación de contenedores en OCI
- **Terraform Cloud/Enterprise**: Gestión del estado remoto y runs automáticos

Cada arquitectura proporciona una solución lista para producción (production-ready) con ejemplos de implementación, mejores prácticas de seguridad, monitoreo y automatización completa.

---

## Arquitecturas Disponibles

| # | Arquitectura | Descripción | Componentes | Deploy |
|---|---|---|---|---|
| 1 | **devops-pipeline** | Pipeline CI/CD completo de OCI DevOps: desde repositorio de código hasta despliegue en OKE con construcción automatizada de imágenes | DevOps Service, Container Registry, OKE, Build, Deployment Pipeline | [![Deploy](https://img.shields.io/badge/Deploy-OCI-F80000?style=for-the-badge)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/download/latest/devops-devops-pipeline.zip) |
| 2 | **artifact-registry** | Gestión empresarial de artefactos: Artifact Registry con Container Registry para versionamiento y distribución de componentes | Artifact Registry, Container Registry, Políticas de Acceso, Scans de Seguridad | [![Deploy](https://img.shields.io/badge/Deploy-OCI-F80000?style=for-the-badge)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/download/latest/devops-artifact-registry.zip) |
| 3 | **gitops-argocd** | GitOps declarativo con ArgoCD en OKE integrado con OCI DevOps para sincronización continua del estado deseado | ArgoCD, OKE, OCI DevOps, Repository, ApplicationSet | [![Deploy](https://img.shields.io/badge/Deploy-OCI-F80000?style=for-the-badge)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/download/latest/devops-gitops-argocd.zip) |
| 4 | **terraform-cloud** | Integración con Terraform Cloud/Enterprise para gestión del estado remoto, runs automáticos y políticas de cumplimiento | Terraform Cloud, OCI Backend, Run Triggers, Cost Estimation, Policy as Code | [![Deploy](https://img.shields.io/badge/Deploy-OCI-F80000?style=for-the-badge)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/download/latest/devops-terraform-cloud.zip) |

---

## Estructura de Directorios

```
devops/
├── README.md                                      (Este archivo)
├── devops-pipeline/                              (Pipeline CI/CD completo)
├── artifact-registry/                            (Gestión de artefactos)
├── gitops-argocd/                                (GitOps con ArgoCD)
└── terraform-cloud/                              (Terraform Cloud Integration)
```

---

## Instalación Rápida

```bash
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/devops
cd devops-pipeline  # o artifact-registry, gitops-argocd, terraform-cloud
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

---

## Licencia

UPL 1.0 - Ver [LICENSE](../../LICENSE)

**Versión**: 1.0.0
