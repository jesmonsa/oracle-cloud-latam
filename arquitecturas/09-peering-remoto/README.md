# 09 - Interconexión de Redes: Remote VCN Peering

Esta arquitectura avanza significativamente al demostrar cómo interconectar aplicaciones entre **Regiones Distintas (Cross-Region)**. Utiliza el backbone privado global de Oracle Cloud, el cual no viaja por internet, conectando infraestructuras físicamente distantes (Ej. Miami y São Paulo).

El despliegue crea dos Virtual Cloud Networks (VCNs), les asocia un Gateway de Enrutamiento Dinámico (DRG) en cada región, y establece una **Remote Peering Connection (RPC)** entre ellas. Todo esto se provisiona desde una única plantilla de Terraform unificada aprovechando el concepto de "alias de providers".

## ☁️ Desplegar con un Clic

> *Nota importante:* Para usar el Resource Manager con esta arquitectura multi-región, debes tener ambas regiones suscritas previamente en las configuraciones de Tenancy o tu despliegue fallará.

[![Desplegar en Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/09-peering-remoto.zip)

## 🏗️ Arquitectura

![09-peering-remoto](09-peering-remoto.jpg)

### Componentes desplegados

| Recurso | Tipo OCI | Descripción |
|---|---|---|
| Providers | oci (alias) | Múltiples proveedores para autenticar en distintas Regiones |
| DRG y RPC | oci_core_drg / remote_peering | Gateways enlazados trans-oceánicamente |
| DB System Primario | oci_database_db_system | Base de Datos en la VCN Hub (Región 1) |
| Load Balancer | oci_load_balancer_load_balancer | Balanceador y Webservers en la VCN Hub (Región 1) |
| Aplicación / Backend | oci_core_instance | Computo aislado ejecutándose en la VCN Spoke (Región 2) |

## 🚀 Despliegue Manual (Terraform CLI)

### 1. Clonar el repositorio
```bash
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/arquitecturas/09-peering-remoto
```

### 2. Configurar variables
```bash
cp terraform.tfvars.example terraform.tfvars
```
Asegúrate de definir correctamente `region` (Región 1) y `region2` (Región 2) en tu archivo `terraform.tfvars`.

### 3. Inicializar y aplicar
```bash
terraform init
terraform apply
```

---
> Basado en el trabajo original de [Martin Linxfeld / FoggyKitchen](https://foggykitchen.com/) bajo licencia UPL-1.0. Transformado por Jesús Monsa.
