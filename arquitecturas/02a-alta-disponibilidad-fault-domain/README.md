# 02a - Alta Disponibilidad Fault-Domain

Despliega una VCN básica y dos webservers públicos obligados a vivir en diferentes Fault Domains dentro del mismo Availability Domain.

## ☁️ Desplegar con un Clic

[![Desplegar en Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/02a-alta-disponibilidad-fault-domain.zip)

## 🏗️ Arquitectura

![02a-alta-disponibilidad-fault-domain](02a-alta-disponibilidad-fault-domain.jpg)

### Componentes desplegados

| Recurso | Tipo OCI | Descripción |
|---|---|---|
| VCN | oci_core_vcn | Red virtual principal |
| Subnet | oci_core_subnet | Una subred pública |
| Webservers | oci_core_instance | Dos instancias (cada una forzada en un `fault_domain` distinto: `FAULT-DOMAIN-1` y `FAULT-DOMAIN-2`) |

## 🚀 Despliegue Manual (Terraform CLI)

### 1. Clonar el repositorio
```bash
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/arquitecturas/02a-alta-disponibilidad-fault-domain
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
Este es el patrón nativo recomendado para alta disponibilidad en regiones con un solo Availability Domain (São Paulo, Santiago, Querétaro, etc.), garantizando aislamientos a nivel de chasis físico/energía en el data center.

---
> Basado en el trabajo original de [Martin Linxfeld / FoggyKitchen](https://foggykitchen.com/) bajo licencia UPL-1.0. Transformado por Jesús Monsa.
