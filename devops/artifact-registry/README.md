# OCI Artifact Registry - Gestion de Artefactos Empresarial

See devops/README.md for overview. This module implements OCI Artifact Registry and Container Registry.

## Features
- Artifact Registry (Maven, NPM)
- Container Registry with vulnerability scanning
- IAM policies and access control
- Audit logging
- Replication support

## Quick Start
```bash
cd devops/artifact-registry
cp terraform.tfvars.example terraform.tfvars
terraform init && terraform plan && terraform apply
```

Version: 1.0.0
