# 05 - Almacenamiento Compartido con OCI FSS

Esta arquitectura agrega un punto de montaje de red (NFS) a la arquitectura segura anterior. Utiliza **OCI File Storage Service (FSS)**, un servicio de archivos en red empresarial, escalable elásticamente (serverless) y altamente duradero.

## ☁️ Desplegar con un Clic

[![Desplegar en Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/05-filesystem-compartido.zip)

## 🏗️ Arquitectura

![05-filesystem-compartido](05-filesystem-compartido.jpg)

### Componentes desplegados

| Recurso | Tipo OCI | Descripción |
|---|---|---|
| FSS | oci_file_storage_file_system | Sistema de archivos NFS con Mount Target en subred privada |
| Bastion Service | oci_bastion_bastion | Acceso administrativo |
| Load Balancer | oci_load_balancer_load_balancer | Enrutamiento de tráfico web |
| Webservers | oci_core_instance | Instancias Web Listas para montar el FSS |

## 🚀 Despliegue Manual (Terraform CLI)

### 1. Clonar el repositorio
```bash
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/arquitecturas/05-filesystem-compartido
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

## 📂 ¿Cómo montar el disco en los servidores?
Después del `terraform apply`, obtendrás el comando exacto en tus outputs. 
1. Conéctate a ambos servidores web usando Bastion Service.
2. Ejecuta:
   ```bash
   sudo mdkir -p /mnt/shared
   sudo mount -t nfs <IP-DEL-MOUNT-TARGET>:/shared /mnt/shared
   ```
3. Cualquier archivo creado en `/mnt/shared` en el Webserver 1 será visible instantáneamente en el Webserver 2.

---
> Basado en el trabajo original de [Martin Linxfeld / FoggyKitchen](https://foggykitchen.com/) bajo licencia UPL-1.0. Transformado por Jesús Monsa.
