# 01 - Fundamentos: Webserver Simple

## Descripción General

Esta es la **arquitectura base fundamental** para aprender a desplegar infraestructura en Oracle Cloud Infrastructure usando Terraform. Crea una Virtual Cloud Network (VCN) completa con una subred pública y un webserver Apache funcional, implementando las mejores prácticas de seguridad desde el inicio.

Ideal para:
- Aprender conceptos de redes en OCI
- Configurar tu primer servidor web en la nube
- Entender buenas prácticas de seguridad (NSG, Security Lists)
- Servir como base para arquitecturas más complejas

### Botón de Despliegue Rápido

[![Deploy to OCI](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-01-fundamentos-webserver.zip)

---

## Arquitectura

```
┌────────────────────────────────────────────────────────────────┐
│                      OCI Region (us-ashburn-1)                  │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │           VCN (Virtual Cloud Network)                     │  │
│  │           CIDR: 10.0.0.0/16                               │  │
│  │                                                           │  │
│  │  ┌─────────────────────────────────────────────────────┐ │  │
│  │  │      Subnet Pública (10.0.1.0/24)                  │ │  │
│  │  │                                                    │ │  │
│  │  │  ┌──────────────────────────────────────────────┐ │ │  │
│  │  │  │   Compute Instance: Webserver Apache         │ │ │  │
│  │  │  │   ┌──────────────────────────────────────┐  │ │ │  │
│  │  │  │   │ Oracle Linux 8                       │  │ │ │  │
│  │  │  │   │ Shape: VM.Standard.E4.Flex           │  │ │ │  │
│  │  │  │   │ OCPUs: 1 | Memoria: 8 GB             │  │ │ │  │
│  │  │  │   │ Apache HTTP Server (:80)             │  │ │ │  │
│  │  │  │   └──────────────────────────────────────┘  │ │ │  │
│  │  │  │                   ▲                         │ │ │  │
│  │  │  │                   │                         │ │ │  │
│  │  │  │   ┌───────────────┴──────────────────┐    │ │ │  │
│  │  │  │   │ Network Security Group (NSG)     │    │ │ │  │
│  │  │  │   │ Reglas:                          │    │ │ │  │
│  │  │  │   │ ✓ HTTP (80)  ← Ingress          │    │ │ │  │
│  │  │  │   │ ✓ HTTPS (443) ← Ingress         │    │ │ │  │
│  │  │  │   │ ✓ SSH (22)   ← Ingress (NSG)    │    │ │ │  │
│  │  │  │   │ ✓ Egress (todo)                 │    │ │ │  │
│  │  │  │   └────────────────────────────────┘    │ │ │  │
│  │  │  │                                         │ │ │  │
│  │  │  └─────────────────────────────────────────┘ │ │  │
│  │  │                                              │ │  │
│  │  └─────────────────────────────────────────────┘ │  │
│  │                      ▲                           │  │
│  │                      │                           │  │
│  │  ┌───────────────────┴───────────────────────┐   │  │
│  │  │  Internet Gateway (IGW)                   │   │  │
│  │  │  Permite tráfico bidireccional al IGW    │   │  │
│  │  └──────────────────────────────────────────┘   │  │
│  │                      ▲                           │  │
│  │                      │                           │  │
│  └──────────────────────┼───────────────────────────┘  │
│                         │                              │
│  ┌──────────────────────┴──────────────────────────┐   │
│  │           INTERNET (0.0.0.0/0)                 │   │
│  │  ← IP Pública: 203.0.113.45 (asignada por OCI) │   │
│  └─────────────────────────────────────────────────┘   │
│                                                        │
└────────────────────────────────────────────────────────────────┘

Flujo de tráfico:
┌─────────────────────────────────────────────────────────────┐
│ Cliente (tu navegador) → IP pública 203.0.113.45:80        │
│                            ↓                               │
│ Internet Gateway → Subnet pública 10.0.1.0/24              │
│                            ↓                               │
│ NSG: Permite puerto 80 (HTTP)                              │
│                            ↓                               │
│ Instancia privada 10.0.1.10 → Apache HTTP Server          │
│                            ↓                               │
│ Respuesta HTTP (default: Hello from Apache)                │
└─────────────────────────────────────────────────────────────┘
```

---

## Recursos Desplegados

| Recurso | Descripción | Tipo OCI | Estado |
|---------|-------------|----------|--------|
| **VCN (Virtual Cloud Network)** | Red virtual con CIDR 10.0.0.0/16 | `oci_core_vcn` | Activo |
| **Subnet Pública** | 10.0.1.0/24 con IP pública habilitada | `oci_core_subnet` | Activo |
| **Internet Gateway (IGW)** | Conecta VCN a Internet | `oci_core_internet_gateway` | Activo |
| **Route Table (Público)** | Enruta tráfico a IGW | `oci_core_route_table` | Activo |
| **Network Security Group** | Firewall granular (recomendado) | `oci_core_network_security_group` | Activo |
| **NSG Reglas** | HTTP(80), HTTPS(443), SSH(22 restringido), Egress | `oci_core_nsg_security_rule` | Activas |
| **Security List** | Fallback legacy si NSG deshabilitado | `oci_core_security_list` | Opcional |
| **Compute Instance** | Webserver con Oracle Linux 8 | `oci_core_instance` | Activo |
| **VNIC (Primary)** | Interfaz de red de la instancia | Asociada a subnet | Activa |
| **IP Pública** | Asignada automáticamente (Always Free) | `oci_core_public_ip` | Activa |

---

## Shapes Compatibles

Esta arquitectura soporta cualquier shape flexible de Compute, pero se recomienda para Always Free Tier:

| Shape | OCPUs | RAM Base | Costo | Always Free | Notas |
|-------|-------|----------|-------|-------------|-------|
| **VM.Standard.E4.Flex** (recomendado) | 1 OCPU | 8 GB | $0/mes | ✅ Sí | AMD EPYC gen 7, excelente relación precio-rendimiento |
| VM.Standard.E5.Flex | 1 OCPU | 8 GB | ~$0.0435/mes | ✅ Sí | AMD EPYC gen 8, más moderno |
| VM.Standard.A1.Flex (ARM) | 4 OCPUs | 24 GB | $0/mes | ✅ Sí | Architecture ARM (no x86), muy económico |
| VM.Standard.X9.Flex | 1 OCPU | 8 GB | ~$0.60/mes | ❌ No | Intel, para workloads de alta performance |

**Recomendación:** Usa `VM.Standard.E4.Flex` para comenzar. Es estable, económico y tiene amplio soporte en la comunidad.

### Configuración de OCPUs y Memoria

La mayoría de shapes flexibles permiten:

```hcl
ocpus_webserver      = 1      # Rango: 1-128
memoria_webserver_gb = 8      # Rango: 1-64 (proporcional)
```

**Relaciones válidas para AMD (E4/E5):**
- 1 OCPU = 1-16 GB RAM
- 2 OCPUs = 2-32 GB RAM
- 4 OCPUs = 4-64 GB RAM

**Para Always Free Tier:** Máximo 4 OCPUs totales en tu tenancy (combinado con demás recursos).

---

## Variables Principales

### Autenticación y Proyecto

| Variable | Descripción | Default | Requerida |
|----------|-------------|---------|----------|
| `tenancy_ocid` | OCID del tenancy OCI | — | ✓ |
| `region` | Región de despliegue | `us-ashburn-1` | ✗ |
| `compartment_ocid` | OCID del compartment | — | ✓ |
| `proyecto` | Prefijo para recursos (máx 15 chars) | `fundamentos` | ✗ |
| `ambiente` | desarrollo / staging / produccion | `desarrollo` | ✗ |
| `propietario` | E-mail del responsable | `admin` | ✗ |

### Red

| Variable | Descripción | Default |
|----------|-------------|--------|
| `vcn_cidr` | CIDR block de la VCN | `10.0.0.0/16` |
| `subnet_publica_cidr` | CIDR de la subnet | `10.0.1.0/24` |

### Cómputo

| Variable | Descripción | Default |
|----------|-------------|--------|
| `shape_webserver` | Shape de instancia | `VM.Standard.E4.Flex` |
| `ocpus_webserver` | Número de OCPUs | `1` |
| `memoria_webserver_gb` | RAM en GB | `8` |
| `imagen_os` | OCID de OS (vacío = latest Oracle Linux 8) | `""` |
| `ssh_public_key` | Clave SSH para acceso | — |

### Seguridad

| Variable | Descripción | Default |
|----------|-------------|--------|
| `ssh_cidr_permitido` | CIDR permitido para SSH | `0.0.0.0/0` |
| `habilitar_nsg` | Usar NSG (recomendado) | `true` |
| `habilitar_baseline_seguridad` | Habilitar Cloud Guard | `false` |

---

## Estimación de Costos

### Always Free Tier - Sin Costo

| Servicio | Asignación | Costo |
|----------|-----------|-------|
| Compute: 2 instancias VM.Standard.A1.Flex (4 OCPUs, 24 GB) | Gratuito | $0 |
| Compute: 1 instancia VM.Standard.E4.Flex (1 OCPU, 8 GB) | Gratuito | $0 |
| VCN + Subnets + IGW | Gratuito | $0 |
| Public IPs (2 estáticas + adicionales) | Gratuito | $0 |
| Network Security Groups | Gratuito | $0 |
| Data transfer entrada | Gratuito | $0 |
| Data transfer salida | 10 GB/mes | $0 |

### Costo Total Mensual: $0.00

Mientras uses:
- Máximo 4 OCPUs de E-series OR 30 OCPUs de A1
- Máximo 2 direcciones IP públicas
- Máximo 10 GB de salida por mes

Si escalas más allá de Always Free:
- E4.Flex: ~$0.0435 por OCPU/mes
- A1.Flex: ~$0.015 por OCPU/mes

---

## Prerequisitos

### 1. Cuenta de OCI

- ✅ Tenancy creada
- ✅ Usuario con API key generada
- ✅ Permisos para crear VCN, subnets, instancias (grupos de usuarios)

### 2. Credenciales OCI

Tener configuradas las variables de autenticación:

```bash
# Opción A: API Key (recomendado para Terraform)
export TF_VAR_tenancy_ocid="ocid1.tenancy.oc1..xxxxx"
export TF_VAR_current_user_ocid="ocid1.user.oc1..xxxxx"
export TF_VAR_fingerprint="a1:b2:c3:d4:e5:f6:g7:h8"
export TF_VAR_private_key_path="~/.oci/oci_api_key.pem"

# Opción B: Instance Principal (si corres en VM de OCI)
# (No requiere variables, usa el rol de la instancia)
```

### 3. Clave SSH

Necesitas tener generada una clave SSH para acceso:

```bash
# Generar si no tienes
ssh-keygen -t ed25519 -f ~/.ssh/oci_key -N ""

# Mostrar clave pública (la que usarás en ssh_public_key)
cat ~/.ssh/oci_key.pub
```

### 4. Software requerido

```bash
# Terraform 1.5 o superior
terraform version

# Verificar acceso a OCI CLI (opcional)
oci os bucket list --compartment-id <tu-compartment-id>
```

---

## Despliegue Rápido (5 minutos)

### Paso 1: Clonar y preparar

```bash
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/arquitecturas-v2/01-fundamentos-webserver

# Copiar template de variables
cp terraform.tfvars.example terraform.tfvars
```

### Paso 2: Configurar variables (terraform.tfvars)

```hcl
# Autenticación
tenancy_ocid       = "ocid1.tenancy.oc1..xxxxxxx"
compartment_ocid   = "ocid1.compartment.oc1..xxxxxxx"
current_user_ocid  = "ocid1.user.oc1..xxxxxxx"
fingerprint        = "a1:b2:c3:d4:e5:f6:g7:h8"
private_key_path   = "/home/usuario/.oci/oci_api_key.pem"
region             = "us-ashburn-1"

# Proyecto
proyecto           = "fundamentos"
ambiente           = "desarrollo"
propietario        = "tu@email.com"

# Cómputo
shape_webserver    = "VM.Standard.E4.Flex"
ocpus_webserver    = 1
memoria_webserver_gb = 8

# Seguridad - CAMBIAR PARA PRODUCCION
ssh_public_key     = "ssh-ed25519 AAAAC3NzaC1lZDI1MTk..."
ssh_cidr_permitido = "0.0.0.0/0"  # ⚠️ Cambiar a tu IP

# Flags
habilitar_nsg      = true
habilitar_baseline_seguridad = false
```

### Paso 3: Inicializar Terraform

```bash
# Option A: Local backend
terraform init

# Option B: Con remote state (después de hacer bootstrap)
terraform init -backend-config=../00-bootstrap-remotestate/backend.hcl
```

### Paso 4: Validar y planificar

```bash
# Validar sintaxis
terraform validate

# Ver qué se va a crear
terraform plan -out=plan.tfplan
```

### Paso 5: Desplegar

```bash
# Aplicar cambios (5-10 segundos)
terraform apply plan.tfplan
```

### Paso 6: Obtener IP y verificar

```bash
# Mostrar IP pública
terraform output ip_publica_servidor_web

# O ver todo
terraform output
```

---

## Verificación del Despliegue

### 1. Verificar instancia en OCI Console

```bash
# Ver instancia creada
oci compute instance list --compartment-id <tu-compartment-id>

# Ver detalles
oci compute instance get --instance-id <instancia-id>
```

### 2. Probar conectividad HTTP

```bash
# Obtener IP
IP=$(terraform output -raw ip_publica_servidor_web)

# Probar webserver
curl http://$IP

# Deberías ver:
# <html><body><h1>Hello from Apache!</h1></body></html>
```

### 3. Acceso SSH

```bash
# Conectar a la instancia
ssh -i ~/.ssh/oci_key opc@$(terraform output -raw ip_publica_servidor_web)

# Una vez conectado:
$ whoami                    # opc
$ sudo systemctl status httpd    # Ver estado de Apache
$ curl http://localhost    # Probar localmente
```

### 4. Verificar seguridad

```bash
# Verificar NSG creado
oci network nsg list --compartment-id <tu-compartment-id>

# Ver reglas del NSG
oci network nsg rules list --nsg-id <nsg-id>

# Verificar VCN
oci network vcn list --compartment-id <tu-compartment-id>
```

### 5. Ver logs de Terraform

```bash
# Habilitar debug si hay problemas
TF_LOG=DEBUG terraform plan

# Log a archivo
TF_LOG=DEBUG TF_LOG_PATH=terraform.log terraform apply
```

---

## Limpieza

Cuando termines de experimentar:

```bash
# Ver recursos que se van a destruir
terraform plan -destroy

# Destruir (⚠️ Elimina todo)
terraform destroy

# Confirmación interactiva
yes | terraform destroy
```

**Tiempo de destrucción:** ~30-40 segundos

---

## Troubleshooting

### Problema 1: "Error 403 Forbidden" en terraform apply

**Síntoma:**
```
Error: 403 Forbidden
```

**Causas:**
- ❌ Usuario no tiene permisos en el compartment
- ❌ Credenciales de API key incorrectas
- ❌ API Key expirada o deshabilitada

**Solución:**
```bash
# Verificar credenciales
echo $TF_VAR_fingerprint
oci identity user get --user-id $TF_VAR_current_user_ocid

# Regenerar API key si es necesario
# (OCI Console → Users → API Keys)
```

### Problema 2: "Error 404 subnet not found"

**Síntoma:**
```
Error: 404 NotFound: The subnet resource does not exist
```

**Causa:**
VCN fue destruida o CIDR no coincide.

**Solución:**
```bash
# Limpiar estado local y reintentar
rm -rf .terraform/
terraform init
terraform plan
```

### Problema 3: SSH "Permission denied (publickey)"

**Síntoma:**
```
Permission denied (publickey).
```

**Causas:**
- ❌ Clave privada incorrecta
- ❌ Clave pública no coincide con la desplegada
- ❌ Usuario incorrecto (debe ser `opc` para Oracle Linux)

**Solución:**
```bash
# Verificar que usas la clave privada correcta
ssh -v -i ~/.ssh/oci_key opc@<ip-publica>

# Ver qué claves tienes
ls -la ~/.ssh/

# Regenerar si es necesario
ssh-keygen -t ed25519 -f ~/.ssh/oci_key_new -N ""
# Actualizar terraform.tfvars con ssh_public_key nueva
```

### Problema 4: "terraform output" falla

**Síntoma:**
```
Error: No outputs in root module
```

**Causa:**
El plan no fue aplicado o falló.

**Solución:**
```bash
# Verificar estado
terraform state list

# Si está vacío, aplicar nuevamente
terraform apply
```

---

## Siguiente Nivel

Una vez domines esta arquitectura base, avanza a:

### [02 - Alta Disponibilidad Multi-AD](../02-alta-disponibilidad-multi-ad/)

Agrega redundancia desplegando webservers en múltiples Availability Domains:
- 2 instancias idénticas (AD1 + AD2)
- Sincronización de configuración
- Testing de failover manual
- ~10 min de despliegue

### [03 - Load Balancer HA](../03-load-balancer-ha/)

Implementa balanceo de carga automático:
- Load Balancer como punto de entrada único
- Health checks automáticos
- Failover sin intervención manual
- ~15 min de despliegue

---

## Módulos Reutilizables

Esta arquitectura usa módulos Terraform genéricos:

- **red/vcn**: Crea VCN con subnets
- **seguridad/nsg**: Define reglas de Network Security Groups
- **computo/webserver**: Provee instancia con Apache
- **seguridad/baselines**: Aplica líneas base de Cloud Guard (opcional)

Puedes reutilizarlos en tus propias arquitecturas.

---

## Referencias

- [OCI VCN Documentation](https://docs.oracle.com/en-us/iaas/Content/Network/home.htm)
- [OCI Compute Instances](https://docs.oracle.com/en-us/iaas/Content/Compute/home.htm)
- [Network Security Groups](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/nsg.htm)
- [Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest)

---

## Soporte

¿Problemas o sugerencias?

- GitHub Issues: https://github.com/jesmonsa/oracle-cloud-latam/issues
- Contribuir: Pull Requests bienvenidos

---

**Última actualización:** Abril 2025  
**Versión:** 2.0  
**Mantenedor:** jesmonsa (Oracle Cloud LATAM Community)
