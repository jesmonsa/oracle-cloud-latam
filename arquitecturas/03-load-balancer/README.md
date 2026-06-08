# 03 - Load Balancer

Despliega un Application Load Balancer (Capa 7) que recibe el tráfico de Internet, terminando las conexiones entrantes y balanceando la carga en modo *Round Robin* hacia dos servidores web. 

**Este es el primer patrón de arquitectura apto para producción del portafolio.**

## ☁️ Desplegar con un Clic

[![Desplegar en Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/03-load-balancer.zip)

## 🏗️ Arquitectura

![03-load-balancer](03-load-balancer.jpg)

### Componentes desplegados

| Recurso | Tipo OCI | Descripción |
|---|---|---|
| Load Balancer | oci_load_balancer_load_balancer | Balanceador de carga flexible con único punto de entrada de IP pública |
| Webservers | oci_core_instance | Instancias Web aisladas en subred privada |
| Bastion Service | oci_bastion_bastion | Acceso seguro serverless (sin costosas VMs) para administración SSH |
| Subnets | oci_core_subnet | Subred pública (LB) y Privada (VMs) en diferentes Fault Domains |
| NAT Gateway | oci_core_nat_gateway | Permite a las instancias privadas acceder a internet para descargar paquetes (vía userdata) |

## 🚀 Despliegue Manual (Terraform CLI)

### 1. Clonar el repositorio
```bash
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/arquitecturas/03-load-balancer
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

## 📋 Consideraciones de Seguridad
Dado que las instancias carecen de IP Pública (están en una subred aislada dictaminada por la regla `prohibit_public_ip_on_vnic=true`), no puedes acceder a ellas directamente por SSH. 

Para eso se despliega **OCI Bastion Service**. Revisa los outputs del despliegue: generarán directamente el comando CLI exacto de OCI para iniciar una sesión de port forwarding local transparente contra las IPs privadas.

---
> Basado en el trabajo original de [Martin Linxfeld / FoggyKitchen](https://foggykitchen.com/) bajo licencia UPL-1.0. Transformado por Jesús Monsa.
