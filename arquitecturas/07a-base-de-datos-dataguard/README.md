# 07a - Base de Datos Privada con Data Guard (Alta Disponibilidad DB)

Esta arquitectura no solo despliega un OCI DB System (Database System en Virtual Machine) en una subred privada segregada de los Webservers, sino que adicionalmente configura y establece de forma nativa e invisible **Oracle Data Guard**.

Esto orquesta la creación de una segunda máquina virtual completa idéntica a la primaria (Standby DB System), aplicándole la asociación de DataGuard, y sincronizando en modo asíncrono para asegurar *Alta Disponibilidad (HA)* y *Disaster Recovery (DR)* ante eventos imprevistos.

> ⚠️ **ADVERTENCIA IMPORTANTE DEL DESPLIEGUE EXTREMADAMENTE LARGO:**
> La creación de un DataGuard implica los siguientes pasos en secuencia estricta:
> 1. Aprovisionamiento completo del OCI DB System Primario.
> 2. Petición de creación del DataGuard.
> 3. Aprovisionamiento completo del OCI DB System Secundario (Standby).
> 4. Sincronización inicial y clonación de la Base de Datos a través de la red (RMAN Duplicate).
> **Todo este proceso tardará entre 90 y 180 minutos de forma totalmente automatizada.** Por favor, *no canceles* el `terraform apply`. Todo está sucediendo en el plano de control asíncrono de OCI.

## ☁️ Desplegar con un Clic

[![Desplegar en Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/07a-base-de-datos-dataguard.zip)

## 🏗️ Arquitectura

![07a-base-de-datos-dataguard](07a-base-de-datos-dataguard.jpg)

### Componentes desplegados

| Recurso | Tipo OCI | Descripción |
|---|---|---|
| DB System Primario | oci_database_db_system | Base de Datos origen (Read/Write) |
| DB System Secundario | oci_database_db_system | Base de Datos destino (Read-only / Mount) mediante Oracle DataGuard. |
| Subredes | oci_core_subnet | Subnets independientes para Balanceador, Webservers y Base de Datos |
| Bastion Service | oci_bastion_bastion | Acceso administrativo (Tunnel/SSH) al Web y DB |
| Load Balancer | oci_load_balancer_load_balancer | Enrutamiento de tráfico web |
| Webservers | oci_core_instance | Instancias (Ej: Apache, Nginx, AppServer local) |

## 🚀 Despliegue Manual (Terraform CLI)

### 1. Clonar el repositorio
```bash
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/arquitecturas/07a-base-de-datos-dataguard
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
