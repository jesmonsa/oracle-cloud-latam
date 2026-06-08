# 08 - Interconexión de Redes: Local VCN Peering

Esta arquitectura demuestra cómo conectar componentes que residen en Redes Virtuales Distintas (VCNs) pero dentro de la misma Región. Usamos un enlace privado directo llamado **Local Peering Gateway**, que enruta el tráfico entre ambas redes usando sus direcciones IP Privadas, sin exponer nunca el tráfico a internet público.

## ☁️ Desplegar con un Clic

[![Desplegar en Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/08-peering-local.zip)

## 🏗️ Arquitectura

![08-peering-local](08-peering-local.jpg)

### Componentes desplegados

| Recurso | Tipo OCI | Descripción |
|---|---|---|
| Redes y Peering | oci_core_local_peering_gateway | Hub VCN (10.0.X.X) y Spoke VCN (10.1.X.X) ruteándose mutuamente. |
| DB System Primario | oci_database_db_system | Base de Datos en la VCN Hub |
| Load Balancer | oci_load_balancer_load_balancer | Balanceador y Webservers en la VCN Hub |
| Aplicación / Backend | oci_core_instance | Computo aislado ejecutándose en la VCN Spoke, consumiendo la DB que está en la Hub VCN |

## 🚀 Despliegue Manual (Terraform CLI)

### 1. Clonar el repositorio
```bash
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/arquitecturas/08-peering-local
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

---
> Basado en el trabajo original de [Martin Linxfeld / FoggyKitchen](https://foggykitchen.com/) bajo licencia UPL-1.0. Transformado por Jesús Monsa.
