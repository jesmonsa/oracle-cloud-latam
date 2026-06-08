# 09a - Interconexión de Redes: Remote VCN Peering + Oracle DataGuard

El clímax de la alta disponibilidad y la continuidad del negocio en Oracle Cloud. Esta arquitectura **multi-región** (Ej: Miami y São Paulo) establece un puente privado trans-oceánico mediante *Remote Peering Connections*, y orquesta de manera 100% automatizada la instalación, configuración y sincronización de una Base de Datos en caliente mediante **Oracle Data Guard**.

**Casos de uso clave:**
- **Disaster Recovery (DR)**: Capacidad de recuperación inmediata ante catástrofes de un centro de datos entero.
- **Failover / Switchover** de base de datos intercontinental.
- **Auditoría asilada**: Permite a usuarios de otra zona horaria acceder a los datos de la Standby en modo Read-only a través de la Red Peered.

> ⚠️ **ADVERTENCIA IMPORTANTE: DESPLIEGUE EXTREMADAMENTE LARGO (90-180 Minutos)**
> Para que todo opere en conjunto, Terraform orquestará:
> 1. Crear las redes (VCN, Subnets) en ambas Regiones.
> 2. Establecer la conexión DRG y validar el Remote Peering Connection (RPC).
> 3. Instanciar y configurar desde cero el Oracle DB System en la Región Primaria (Demora ~60 mins).
> 4. Iniciar y esperar el proceso nativo de provisionado Oracle Data Guard hacia la Región Secundaria, transfiriendo los volúmenes a través de la red Remote Peering. (Demora ~60-90 mins).
> **Por favor, sé paciente y NUNCA canceles el `terraform apply`.**

## ☁️ Desplegar con un Clic

> *Nota importante:* Debes tener las dos regiones suscritas antes de intentar ejecutar este stack en OCI Resource Manager.

[![Desplegar en Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/09a-peering-remoto-dataguard.zip)

## 🏗️ Arquitectura

![09a-peering-remoto-dataguard](09a-peering-remoto-dataguard.jpg)

### Componentes desplegados

| Recurso | Tipo OCI | Descripción |
|---|---|---|
| Providers Multi-Región | oci | Autorización a la API OCI en Regiones 1 y 2 |
| Enrutamiento Privado Global | oci_core_drg / remote_peering | Data transita cifrada por la fibra óptica dedicada de Oracle. |
| DB System (Primario) | oci_database_db_system | Nodo Read-Write principal. |
| DB System (Standby) | oci_database_data_guard_association | Nodo Read-only replicado en otra geografía. |
| Componentes Web Frontales | oci_load_balancer / instance | Despliegue seguro con NSG en la región primaria. |
| Bastion Service | oci_bastion_bastion | Túneles seguros creados por separado para Región 1 y 2. |

## 🚀 Despliegue Manual (Terraform CLI)

### 1. Clonar el repositorio
```bash
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/arquitecturas/09a-peering-remoto-dataguard
```

### 2. Configurar variables
OBLIGATORIO: Establecer las variables `db_password`, `ssh_public_key`, `region` y `region2`.
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
