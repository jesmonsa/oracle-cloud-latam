# 01 - Webserver Simple

Despliega una VCN básica y un servidor web público con Apache instalado. Ideal para pruebas iniciales o sitios web estáticos simples y entornos de arranque rápido.

## ☁️ Desplegar con un Clic

[![Desplegar en Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/01-webserver-simple.zip)

> Requiere una cuenta activa en Oracle Cloud Infrastructure. 
> [Crear cuenta gratuita (300 USD de créditos)](https://www.oracle.com/cloud/free/)

## 🏗️ Arquitectura

![01-webserver-simple](01-webserver-simple.jpg)

### Componentes desplegados

| Recurso | Tipo OCI | Descripción |
|---|---|---|
| VCN | oci_core_vcn | Red virtual principal con IGW y/o NAT |
| Subnet Pública | oci_core_subnet | Subred accesible desde Internet |
| Webserver | oci_core_instance | Instancia de cómputo con Apache (userdata) |
| NSGs | oci_core_network_security_group | Reglas granulares para SSH y HTTP (opcionalmente SL) |

## 📋 Prerequisitos

- Cuenta OCI activa con permisos de administrador en el compartment
- Par de llaves SSH (pública y privada) para el servidor

## 🚀 Despliegue Manual (Terraform CLI)

### 1. Clonar el repositorio
```bash
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/arquitecturas/01-webserver-simple
```

### 2. Configurar variables
```bash
cp terraform.tfvars.example terraform.tfvars
# Edita terraform.tfvars con tu OCID de compartment y llave pública
```

### 3. Inicializar y aplicar
```bash
terraform init
terraform apply
```

## 🔧 Variables Principales

| Variable | Descripción | Valor por Defecto | Requerida |
|---|---|---|---|
| proyecto | Prefijo para nombres de recursos | miproyecto | ✅ |
| ambiente | Ambiente de despliegue | desarrollo | ✅ |
| compartment_ocid| Compartment para despliegue| | ✅ |
| ssh_public_key | Llave SSH | | ✅ |
| habilitar_nsg | Usa NSG en lugar de SL | true | ✅ |

## 📤 Outputs

| Output | Descripción |
|---|---|
| ip_publica_servidor_web | IP pública del webserver 1 |
| url_acceso | URL rápida al sitio de Apache |
| comando_ssh | Comando rápido para conexión SSH |

## 🔒 Consideraciones de Seguridad

- Se ha migrado nativamente al uso de Network Security Groups (NSG) en lugar de Security Lists, siguiendo el estándar moderno de protección granular.
- Si se activa el baseline de seguridad, se habilitará Cloud Guard sin costo adicional.

## 🌎 Contexto para América Latina

- Utiliza shapes **Flex** (VM.Standard.E4.Flex), el modelo más rentable en OCI con rendimiento altamente predecible para cargas regionales en São Paulo, Querétaro, Santiago, y Bogotá.

## ➡️ Siguiente Arquitectura

[02 - Alta Disponibilidad en Multi-AD](../02-alta-disponibilidad-multi-ad/)

## 📚 Recursos Adicionales

- [OCI Compute flex shapes documentation](https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm#flexible)
- [Best Practices on VCN and subnets](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/overview.htm)

---
> Basado en el trabajo original de [Martin Linxfeld / FoggyKitchen](https://foggykitchen.com/) bajo licencia UPL-1.0. Transformado, traducido al español y mejorado para el mercado latinoamericano por Jesús Monsa, Oracle Cloud Architect en Oracle Colombia.
