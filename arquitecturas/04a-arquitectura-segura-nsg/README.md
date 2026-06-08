# 04a - Arquitectura Segura con Bastion Service y NSGs

Esta arquitectura representa el patrón de seguridad por excelencia en Oracle Cloud Infrastructure. Aisla completamente los servidores de cómputo en **subredes privadas** (sin IPs públicas), dirigiendo el tráfico web de clientes únicamente a través del **Load Balancer**. 

La administración por SSH se realiza estrictamente a través del **OCI Bastion Service**, un servicio gestionado (PaaS) que elimina la necesidad de mantener, parchear y pagar por las tradicionales "Bastion VMs/Jumpboxes".

## ☁️ Desplegar con un Clic

[![Desplegar en Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/04a-arquitectura-segura-nsg.zip)

## 🏗️ Arquitectura

![04a-arquitectura-segura-nsg](04a-arquitectura-segura-nsg.jpg)

### Componentes desplegados

| Recurso | Tipo OCI | Descripción |
|---|---|---|
| Bastion Service | oci_bastion_bastion | Controla acceso administrativo por SSH generando sesiones limitadas en tiempo |
| Load Balancer | oci_load_balancer_load_balancer | Recibe peticiones HTTP, se ubica en la Subred Pública |
| Webservers | oci_core_instance | Se ubican en la Subred Privada, no exponiendo SSH directamente a Internet |

## 🚀 Despliegue Manual (Terraform CLI)

### 1. Clonar el repositorio
```bash
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/arquitecturas/04a-arquitectura-segura-nsg
```

### 2. Configurar variables
```bash
cp terraform.tfvars.example terraform.tfvars
```

### 3. Inicializar y aplicar
```bash
terraform init
terraform apply
```

## 🔐 ¿Cómo usar el Bastion Service para conectarme por SSH?
Una vez ejecutado el apply, Terraform imprimirá los outputs con el comando de CLI necesario. El flujo es:

1. Ejecuta el comando output (ej: `oci bastion session create-managed-ssh ...`)
2. Este comando devolverá un JSON con un ID de sesión. 
3. Ejecuta `oci bastion session get --session-id <ID> --output table`
4. En el campo `ssh-metadata`, verás el comando SSH final que debes ejecutar en tu terminal local. Contendrá el comando ProxyCommand automático.

---
> Basado en el trabajo original de [Martin Linxfeld / FoggyKitchen](https://foggykitchen.com/) bajo licencia UPL-1.0. Transformado por Jesús Monsa.
