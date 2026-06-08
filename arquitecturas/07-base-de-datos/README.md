# 07 - Base de Datos Privada (DB System VM)

En esta arquitectura separamos la lógica de frontend o backend en una capa, introduciendo por primera vez un **OCI DB System (Database System en Virtual Machine)** como capa de base de datos relacional sólida.

El DB System estará alojado en su propia subred privada, lo que crea un aislamiento nativo de capa de red entre los Webservers (Frontend) y los datos confidenciales (Backend/DB). El acceso total solo ocurre a través de Bastion y Network Security Groups estrictos.

> ⚠️ **ADVERTENCIA IMPORTANTE DEL DESPLIEGUE:**
> El aprovisionamiento de un OCI DB System implica crear la máquina virtual, la infra de grid logic (Oracle Grid Infrastructure), e inicializar la base de datos subyacente (CDB y PDB). Este proceso **tardará entre 45 y 90 minutos de forma automatizada**. Por favor, sé paciente cuando inicies el despliegue; Terraform esperará hasta que la BD esté completamente operativa.

## ☁️ Desplegar con un Clic

[![Desplegar en Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/07-base-de-datos.zip)

## 🏗️ Arquitectura

![07-base-de-datos](07-base-de-datos.jpg)

### Componentes desplegados

| Recurso | Tipo OCI | Descripción |
|---|---|---|
| DB System | oci_database_db_system | Sistema Manejador de Base de Datos relacional Oracle (CDB+PDB), en VM. |
| Subredes | oci_core_subnet | Subnets independientes para Balanceador, Webservers y Base de Datos |
| Bastion Service | oci_bastion_bastion | Acceso administrativo (Tunnel/SSH) al Web y DB |
| Load Balancer | oci_load_balancer_load_balancer | Enrutamiento de tráfico web |
| Webservers | oci_core_instance | Instancias (Ej: Apache, Nginx, AppServer local) |

## 🚀 Despliegue Manual (Terraform CLI)

### 1. Clonar el repositorio
```bash
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/arquitecturas/07-base-de-datos
```

### 2. Configurar variables
Se requiere obligatoriamente tu `db_password` y `ssh_public_key`.
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
