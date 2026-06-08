# 06 - Almacenamiento Local Aislado (Block Volumes)

Esta arquitectura parte del patrón seguro e incorpora discos Block Volume adyuntos a cada instancia usando iSCSI. A diferencia de FSS (que se comparte en red local NFS), el Block Volume es un montaje de bloque SAN directo, mucho más veloz y aislado (estado independiente por nodo).

## ☁️ Desplegar con un Clic

[![Desplegar en Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/06-block-volumes.zip)

## 🏗️ Arquitectura

![06-block-volumes](06-block-volumes.jpg)

### Componentes desplegados

| Recurso | Tipo OCI | Descripción |
|---|---|---|
| Block Volumes | oci_core_volume | Discos SAN independientes (no compartidos) creados junto a cada nodo |
| Volume Attachments | oci_core_volume_attachment | Conexión iSCSI entre el nodo y el disco |
| Bastion Service | oci_bastion_bastion | Acceso administrativo |
| Load Balancer | oci_load_balancer_load_balancer | Enrutamiento de tráfico web |
| Webservers | oci_core_instance | Instancias |

## 🚀 Despliegue Manual (Terraform CLI)

### 1. Clonar el repositorio
```bash
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/arquitecturas/06-block-volumes
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

## 📂 ¿Cómo montar los discos iSCSI en los servidores?
Terraform automatiza la creación del disco y su conexión (`attachment`) a la Virtual Machine. Sin embargo, por diseño propio del sistema operativo huésped, requiere montar explícitamente el dispositivo.

Existen 2 maneras, una manual (ver documentación de OCI Console copiando los comandos iSCSI) o utilizar el script `configurar_disco.sh` proporcionado dentro del módulo de Block Volume de este repositorio (la opción más fácil).

---
> Basado en el trabajo original de [Martin Linxfeld / FoggyKitchen](https://foggykitchen.com/) bajo licencia UPL-1.0. Transformado por Jesús Monsa.
