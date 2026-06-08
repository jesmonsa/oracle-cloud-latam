# 02 - Alta Disponibilidad Multi-AD

Despliega una VCN básica y dos servidores web públicos en Availability Domains distintos (si la región los soporta, si la región tiene un solo AD como São Paulo o Santiago, el código de terraform hace fallback seguro ubicándolos en Fault Domains diferentes del mismo AD).

## ☁️ Desplegar con un Clic

[![Desplegar en Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/02-alta-disponibilidad-multi-ad.zip)

## 🏗️ Arquitectura

![02-alta-disponibilidad-multi-ad](02-alta-disponibilidad-multi-ad.jpg)

### Componentes desplegados

| Recurso | Tipo OCI | Descripción |
|---|---|---|
| VCN | oci_core_vcn | Red virtual principal |
| Subnets | oci_core_subnet | Dos subredes públicas (una en cada AD) |
| Webservers | oci_core_instance | Dos instancias de cómputo con Apache (userdata) |

## 🚀 Despliegue Manual (Terraform CLI)

### 1. Clonar el repositorio
```bash
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/arquitecturas/02-alta-disponibilidad-multi-ad
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

## 📋 Consideraciones 
Esta arquitectura demuestra el concepto de Availability Domains en OCI. Dado que en las regiones de una sola AD, la mejor práctica es distribuir las VMs en múltiples **Fault Domains**, el código incorpora esa lógica de forma condicional para que nunca falle tu despliegue sin importar la región de LATAM elegida.

---
> Basado en el trabajo original de [Martin Linxfeld / FoggyKitchen](https://foggykitchen.com/) bajo licencia UPL-1.0. Transformado por Jesús Monsa.
