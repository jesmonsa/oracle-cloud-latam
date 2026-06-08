# 06 - Base de Datos (Oracle DB System)

## Descripción General

Arquitectura empresarial completa que integra una **Oracle Database System** gestionada en subnet privada dedicada. Esta es la arquitectura más compleja de la serie, combinando todos los componentes anteriores:

- **Tier Web**: Load Balancer público + webservers privados (arquitectura 04)
- **Tier Storage**: File Storage Service NFS compartido (arquitectura 05)
- **Tier Database**: Oracle DB System con backup automático y alta disponibilidad

Esta arquitectura es la base de producción para aplicaciones empresariales que requieren:
- Base de datos Oracle gestionada con SLA de disponibilidad
- Backup automático y point-in-time recovery
- Integración segura entre aplicaciones y persistencia de datos
- Cumplimiento de normativas de auditoría y compliance (HIPAA, PCI-DSS, SOC2)

### Características Principales

- **Oracle DB System 19c/21c**: Edición ENTERPRISE configurada en subnet privada
- **Alta Disponibilidad**: 2 nodos en ADs diferentes (Data Guard optional)
- **Almacenamiento Automatizado**: Volúmenes ASM gestionados por OCI
- **Backup Automático**: Retención 30 días, RMAN integrado
- **Monitoreo**: Alertas automáticas via OCI Monitoring
- **Conectividad Segura**: Puerto 1521 solo accesible desde webservers (NSG)
- **Herencia de seguridad**: Mantiene bastion, NAT, webservers privados, NFS de arquitecturas previas

---

## Diagrama de Arquitectura

```
                            Internet
                               │
                    ┌──────────┴──────────┐
                    ▼                     ▼
        ┌─────────────────────┐  ┌──────────────────────┐
        │  Load Balancer      │  │  Bastion Service     │
        │  (Público)          │  │  SSH tunnels,        │
        │  HTTP: 80/443       │  │  Port-forward 1521   │
        │  10.0.10.0/24       │  │                      │
        └──────────┬──────────┘  └──────────┬───────────┘
                   │                        │
        ───────────┼───── VCN 10.0.0.0/16 ──┼─────────────
                   │     (Privada)          │
        ┌──────────┼──────────────────────┬─┼──────────┐
        │          │                      │ │          │
    ┌───┴──┐   ┌───┴──┐           ┌──────┴─┴──────┐  │
    │ WS1  │   │ WS2  │           │ Bastion       │  │
    │ AD1  │   │ AD2  │           │ Target        │  │
    │10.0.1│   │10.0.2│           │               │  │
    └───┬──┘   └───┬──┘           └──┬────────────┘  │
        │          │                 │               │
        │  ┌─────────────────┐       │               │
        ├─→│ FSS Mount       │       │               │
        │  │ Target (AD1)    │       │               │
        │  │ /shared         │       │               │
        │  └────────┬────────┘       │               │
        │           │                │               │
        └───┬───────┼────────────────┼───────────────┘
            │       │                │
            ▼       ▼                │
        ┌─────────────────┐          │
        │ NFS FileSystem  │          │
        │ 10GB default    │          │
        └──────┬──────────┘          │
               │                     │
        ┌──────┴──────┬──────────────┘
        ▼             ▼
    NAT GW        Service GW
    (outbound)    (OCI services)
               │
               ▼
    ┌─────────────────────────────────┐
    │  Oracle DB System (Subnet AD1)  │
    │  10.0.3.0/24 (dedicada)         │
    │                                 │
    │  Primary Node (AD1)             │
    │  - VM.Standard.E4.Flex (2 OCPU) │
    │  - 16 GB RAM                    │
    │  - 256 GB Almacenamiento        │
    │                                 │
    │  Standby Node (AD2) [opcional]  │
    │  - Replicación Data Guard       │
    │  - failover automático          │
    │                                 │
    │  Database Instance APPDB        │
    │  SID: APPDB, Port: 1521         │
    │  Version: 19c Enterprise        │
    └──────────────┬──────────────────┘
                   │
            ┌──────┘
            │ SQL*Net 1521
            │ (NSG restrictiva)
        ┌───┴──────┐
        │  WS1/WS2 │ (lee/escribe datos)
        └──────────┘
```

---

## Evolución desde Arquitectura 05

| Aspecto | 05 - Almacenamiento Compartido | 06 - Base de Datos |
|--------|--------------------------------|-------------------|
| **Persistencia de Datos** | NFS (sistema de archivos) | + Oracle DB System (base de datos relacional) |
| **Tier Database** | No existe | Subnet privada 10.0.3.0/24 dedicada |
| **NSG Database** | No requerido | Sí (TCP 1521, restringido a WS subnet) |
| **Conectividad BD** | N/A | SQL*Net 1521 desde webservers |
| **Backup Automático** | Manual (via snapshot) | Automático RMAN (30 días retención) |
| **Alta Disponibilidad** | Datos compartidos (NFS redundancia) | Data Guard con failover automático (opcional) |
| **Edición Oracle** | N/A | ENTERPRISE_EDITION con licencia incluida |
| **Compliance Data** | Almacenamiento compartido | Base de datos con auditoría SQL |
| **RTO/RPO** | Horas (NFS backup) | Minutos (Data Guard) |

---

## Recursos Creados

| Recurso | Descripción | Tipo OCI |
|---------|-------------|----------|
| **VCN** | Red virtual 10.0.0.0/16 | Networking |
| **Subnets (4)** | LB pública, 2 WS privadas (AD1, AD2), 1 DB privada (AD1) | Networking |
| **Internet Gateway** | Acceso público LB | Networking |
| **NAT Gateway** | Outbound para WS1, WS2 | Networking |
| **Service Gateway** | Acceso OCI services (backup, monitoring) | Networking |
| **Load Balancer Flexible** | LB público 10 Mbps | Networking |
| **VM.Standard.E4.Flex** | 2 webservers, 1 OCPU, 8GB | Compute |
| **Bastion Service** | SSH tunneling + port-forward | Security |
| **File Storage Service** | NFS compartido 10GB | Storage |
| **Mount Target NFS** | IP privada en AD1 | Storage |
| **Oracle DB System** | Database 19c ENTERPRISE, 2 OCPU, 256GB storage | Database |
| **DB Primary Node** | Nodo principal en AD1 | Database |
| **DB Standby Node** | (Opcional) Replicación Data Guard AD2 | Database |
| **Network Security Groups (5)** | NSG LB, NSG WS, NSG Bastion, NSG NFS, NSG DB | Security |

---

## Tablas de Configuración

### Shapes Compatibles (Database)

| Shape | vCPUs | Memoria | Almacenamiento | Caso de Uso | Costo |
|-------|-------|---------|------------------|------------|-------|
| **E4.Flex** | 1-4 | 8-64 GB | HDD de arranque | Desarrollo, testing | ~$10-40/mes |
| **E5.Flex** | 1-4 | 8-64 GB | HDD optimizado | Producción pequeña | ~$20-60/mes |
| **M6.Flex** | 1-32 | 8-512 GB | NVMe (más rápido) | Producción mediana-grande | ~$50-200/mes |
| **X9.Flex** | 2-64 | 32-1024 GB | NVMe ultra-rápido | OLTP crítico, caché | ~$200-500/mes |

**Recomendación para desarrollo**: E4.Flex 2 OCPU, 16GB (costo ~$25/mes)
**Recomendación para producción**: E5.Flex o M6.Flex 4 OCPU, 64GB (costo ~$80-150/mes)

### Ediciones Oracle Disponibles

| Edición | Características | Costo Unitario | Caso de Uso |
|---------|-----------------|-----------------|------------|
| **STANDARD_EDITION_2** | SQL, PL/SQL, particionamiento básico | Incluido en OCI | OLTP pequeño-mediano |
| **ENTERPRISE_EDITION** | Todas las opciones, RAC, Data Guard | ~$995/mes (2 OCPU) | OLTP crítico, HA requerido |
| **ENTERPRISE_EDITION_EXTREME_PERFORMANCE** | + Compression, AWR, performance tuning | ~$2,495/mes | Aplicaciones muy exigentes |

**Recomendación**: ENTERPRISE_EDITION para producción (HA + backups). STANDARD_EDITION para desarrollo.

### Variables Principales

| Variable | Descripción | Valor por Defecto | Tipo |
|----------|-------------|-------------------|------|
| `compartment_ocid` | OCID compartment | (requerido) | String |
| `region` | Región OCI | (requerido) | String |
| `vcn_cidr` | CIDR VCN | `10.0.0.0/16` | String |
| `db_subnet_cidr` | CIDR subnet database | `10.0.3.0/24` | String |
| `db_admin_password` | Password SYS (sensitive) | (requerido) | String(sensitive) |
| `db_name` | Nombre base datos (SID) | `APPDB` | String |
| `db_version` | Versión Oracle | `19.0.0.0.0` | String |
| `shape_db` | Shape DB system | `VM.Standard.E4.Flex` | String |
| `database_edition` | Edición Oracle | `ENTERPRISE_EDITION` | String |
| `license_model` | Modelo licencia | `LICENSE_INCLUDED` | String |
| `nfs_ruta_exportacion` | Ruta FSS | `/shared` | String |
| `nfs_punto_montaje` | Punto montaje WS | `/mnt/shared` | String |
| `bastion_ttl_segundos` | TTL sesiones Bastion | `3600` | Number |

---

## Estimación de Costos

### Modelo Producción Pequeña (E4 2 OCPU)

```
Recurso                               | Cantidad | Unitario   | Total/Mes
───────────────────────────────────────────────────────────────────
Networking (VCN, subnets, GWs)       | -        | Gratuito   | $0
Load Balancer Flexible               | 1        | Gratuito*  | $0
VM.Standard.E4.Flex (WS) 1 OCPU/8GB  | 2        | Gratuito*  | $0
Bastion Service                      | 1        | Gratuito   | $0
File Storage Service (0-10 GB)       | 1        | Gratuito   | $0
─────────────────────────────────────────────────────────────────
Subtotal sin DB                      | -        | -          | $0
─────────────────────────────────────────────────────────────────
Oracle DB System E4.Flex 2 OCPU      | 1        | ~$25/mes   | $25
  └ Almacenamiento DB (256 GB)       | -        | Incluido   | Incluido
  └ Backup automático RMAN           | -        | Incluido   | Incluido
─────────────────────────────────────────────────────────────────
TOTAL ESTIMADO                       | -        | -          | $25-30 USD/mes
```

**Notas de Costo:**

- **DB System**: Costo mínimo ~$20/mes (E4 base) + OCPUs adicionales ($2.50/OCPU-mes)
- **Almacenamiento DB**: Incluido en precio shape (256 GB)
- **Backup**: Incluido en DB System (retención 30 días)
- **Dataless**: Si WS y FSS <10 GB: costo ≈ costo DB puro
- **Data Guard (HA)**: +50% costo (second standby node en AD2)
- **Comparativa vs EC2 + RDS**: ~$80-120/mes si fuera AWS

### Estimación con Data Guard (Alta Disponibilidad)

```
Oracle DB System - Primary Node    | 2 OCPU | ~$25/mes
Oracle DB System - Standby Node    | 2 OCPU | ~$25/mes
───────────────────────────────────────────────────────
TOTAL CON DATA GUARD               | 4 OCPU | ~$50/mes
```

---

## Requisitos Previos

### Acceso y Permisos OCI

- [ ] Cuenta OCI activa con permisos en compartment
- [ ] Usuario con: `MANAGE_DATABASE_FAMILY`, `MANAGE_DB_SYSTEMS`, `MANAGE_VCN`, `MANAGE_BASTION`, `MANAGE_FILE_SYSTEMS`
- [ ] Región soporta Oracle DB System (verificar disponibilidad)

### Herramientas Locales

- [ ] **Terraform** 1.0+
- [ ] **OCI CLI** 2.0+
- [ ] **SSH Keys**: ~/.ssh/oci_webserver (privada, pública)
- [ ] **sqlplus** (opcional, para conectar DB): `oracle-instantclient-tools`
  ```bash
  # macOS
  brew install oracle-instantclient-tools
  
  # Debian/Ubuntu
  sudo apt-get install oracle-instantclient-sqlplus
  ```

### Validar Disponibilidad OCI DB System

```bash
# Listar shapes disponibles para DB en tu región
oci db system shape list --compartment-id $COMPARTMENT_OCID
# Debe listar VM.Standard.E4.Flex, E5.Flex, etc.

# Verificar versiones Oracle disponibles
oci db version list --compartment-id $COMPARTMENT_OCID
# Debe listar 19c, 21c, etc.

# Verificar disponibilidad FSS en región (para arquitectura completa)
oci fs availability-domain list --compartment-id $COMPARTMENT_OCID
```

### Generar Password Seguro (DB Admin)

```bash
# Generar password aleatorio (16+ caracteres, especiales)
openssl rand -base64 16 > /tmp/db_password.txt
cat /tmp/db_password.txt

# Guardar en archivo seguro
chmod 600 /tmp/db_password.txt
```

---

## Despliegue Rápido

### 1. Clonar Repositorio

```bash
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/arquitecturas-v2/06-base-de-datos
```

### 2. Configurar Variables (CRÍTICO: Password Seguro)

```bash
cp terraform.tfvars.example terraform.tfvars

# Generar password aleatorio
DB_PASSWORD=$(openssl rand -base64 16)

cat > terraform.tfvars << EOF
compartment_ocid            = "ocid1.compartment.oc1..aaaaaaaa..."
region                      = "eu-madrid-1"
vcn_cidr                    = "10.0.0.0/16"
db_subnet_cidr              = "10.0.3.0/24"
db_admin_password           = "$DB_PASSWORD"
db_name                     = "APPDB"
db_version                  = "19.0.0.0.0"
shape_db                    = "VM.Standard.E4.Flex"
database_edition            = "ENTERPRISE_EDITION"
license_model               = "LICENSE_INCLUDED"
nfs_ruta_exportacion        = "/shared"
nfs_punto_montaje           = "/mnt/shared"
bastion_ttl_segundos        = 3600
EOF

echo "Database password: $DB_PASSWORD"
# GUARDAR EN LUGAR SEGURO - se necesita para conectar a DB
```

### 3. Inicializar Terraform

```bash
terraform init
terraform validate
terraform plan -out=tfplan

# Revisar plan (especialmente DB System)
terraform show tfplan | grep -E "oci_database_db_system|oracle"
```

### 4. Desplegar (TIEMPO: 15-25 minutos)

```bash
# ADVERTENCIA: Despliegue largo, BE PATIENT
terraform apply tfplan

echo "Esperando creación de DB System... (15-25 minutos)"
# Puedes revisar progreso en OCI Console: Database → DB Systems

# Capturar outputs
terraform output -json > outputs.json
```

### 5. Capturar Credenciales y IDs

```bash
LB_IP=$(terraform output -raw load_balancer_ip)
DB_OCID=$(terraform output -raw db_system_id)
DB_NODE_IP=$(terraform output -raw db_node_private_ip)
BASTION_ID=$(terraform output -raw bastion_id)
WS1_ID=$(terraform output -raw -json instance_ids | jq -r '.[0]')

# Guardar en archivo
cat > /tmp/credentials.sh << EOF
export LB_IP=$LB_IP
export DB_OCID=$DB_OCID
export DB_NODE_IP=$DB_NODE_IP
export BASTION_ID=$BASTION_ID
export WS1_ID=$WS1_ID
export DB_PASSWORD="$DB_PASSWORD"
EOF
source /tmp/credentials.sh
```

---

## Verificación post-despliegue

### Verificar DB System Creado

```bash
# Obtener estado
oci db system get --db-system-id $DB_OCID \
  --query 'data.{lifecycle_state: "lifecycle-state", version: "version", shape: "shape"}' \
  --output table

# Esperado: lifecycle-state = AVAILABLE, shape = VM.Standard.E4.Flex

# Listar nodos DB
oci db node list --db-system-id $DB_OCID \
  --query 'data[*].{node_id: id, hostname: hostname, state: "lifecycle-state"}' \
  --output table
```

### Probar Conectividad HTTP (Web + NFS)

```bash
# Verificar LB
curl -i http://$LB_IP/
# Esperado: HTTP 200 OK

# Verificar NFS compartido (si existe contenido)
curl -i http://$LB_IP/shared/
# Esperado: HTTP 200 (si hay archivos en NFS)
```

### Probar Acceso SSH a Webserver via Bastion

```bash
# Crear sesión SSH
SESSION=$(oci bastion session create-managed-ssh \
  --bastion-id $BASTION_ID \
  --target-resource-id $WS1_ID \
  --target-os-username opc \
  --ssh-public-key-file ~/.ssh/oci_webserver.pub \
  --session-ttl-in-seconds 7200 \
  --wait-for-state ACTIVE \
  --query 'data.id' \
  --raw-output)

# Obtener comando SSH
oci bastion session get --session-id $SESSION \
  --query 'data."ssh-metadata"."command"' \
  --raw-output > /tmp/ssh_cmd.sh

# Probar conectividad
chmod +x /tmp/ssh_cmd.sh
bash /tmp/ssh_cmd.sh << 'EOF'
# Verificar que puede resolver DB node
nslookup $DB_NODE_IP 2>/dev/null || echo "DB IP: $DB_NODE_IP"

# Verificar puerto 1521 accesible (SQL*Net)
timeout 2 bash -c "</dev/tcp/$DB_NODE_IP/1521" && echo "Puerto 1521 accesible" || echo "Puerto 1521 no accesible"

exit
EOF
```

### Conectar a Base de Datos via Bastion (Port Forwarding)

```bash
# Crear sesión de port-forwarding (1521 → local 1521)
PF_SESSION=$(oci bastion session create-port-forwarding \
  --bastion-id $BASTION_ID \
  --target-private-ip $DB_NODE_IP \
  --target-port 1521 \
  --session-ttl-in-seconds 10800 \
  --ssh-public-key-file ~/.ssh/oci_webserver.pub \
  --wait-for-state ACTIVE \
  --query 'data.id' \
  --raw-output)

echo "Port-forward session: $PF_SESSION"

# Obtener comando SSH
oci bastion session get --session-id $PF_SESSION \
  --query 'data."ssh-metadata"."command"' \
  --raw-output > /tmp/pf_cmd.sh

# Ejecutar port-forward en background
chmod +x /tmp/pf_cmd.sh
bash /tmp/pf_cmd.sh &
PF_PID=$!

# Esperar a que se establezca
sleep 3

# Conectar con sqlplus (si tienes instalado)
# NOTA: Reemplazar puerto según output de port-forward (ej: 34521 → 1521)
# sqlplus sys/${DB_PASSWORD}@localhost:1521/APPDB as sysdba << 'SQL'
# SELECT name, open_cursors FROM v$database;
# exit
# SQL

# Alternativa: verificar conectividad con nc/telnet
nc -zv 127.0.0.1 1521
# Esperado: Connection successful

# Limpiar
kill $PF_PID
```

### Monitorear DB desde OCI Console (sin Bastion)

```bash
# Ver logs de alert en OCI CLI
oci db alert-log list --db-system-id $DB_OCID \
  --limit 10 \
  --query 'data[*].[time_generated, message_type, message_text]' \
  --output table | head -20

# Verificar backups automáticos
oci db backup list --database-id $(oci db database list --db-system-id $DB_OCID \
  --query 'data[0].id' --raw-output) \
  --query 'data[*].[id, "lifecycle-state", time_ended]' \
  --output table
```

---

## Limpieza Completa (IMPORTANTE: Alto Costo)

### Destruir Recursos

```bash
# ADVERTENCIA: Esto elimina base de datos, datos backups, todo
# Hacer backup final si es necesario

# Listar backups existentes
oci db backup list --database-id $(oci db database list --db-system-id $DB_OCID \
  --query 'data[0].id' --raw-output) \
  --query 'data[*].id' --raw-output

# Destroy
terraform plan -destroy
terraform destroy

# Confirmar 'yes'
```

### Validar Limpieza

```bash
# Verificar DB System eliminado
oci db system list --compartment-id $COMPARTMENT_OCID | jq '.data | length'
# Esperado: 0

# Verificar instancias eliminadas
oci compute instance list --compartment-id $COMPARTMENT_OCID | jq '.data | length'
# Esperado: 0

# Limpiar archivos locales sensibles
rm -f /tmp/credentials.sh /tmp/db_password.txt terraform.tfstate*
```

---

## Troubleshooting

### Problema: "Database system creation timed out (>25 min)"

**Síntoma**: Terraform cuelga esperando `oci_database_db_system`, después timeout

**Causa**: OCI está creando DB System lentamente (normal en algunos datacenters)

**Solución**:
```bash
# Verificar estado en OCI Console
# Database → DB Systems → [tu sistema] → Lifecycle state debe ser AVAILABLE

# Aumentar timeout en terraform.tf:
# En recurso oci_database_db_system:
# timeouts {
#   create = "60m"  # default 40m
# }

# O monitorear manualmente:
watch -n 10 "oci db system get --db-system-id $DB_OCID \
  --query 'data.\"lifecycle-state\"' --raw-output"

# Una vez AVAILABLE, terraform apply de nuevo (recupera estado)
```

### Problema: "Port 1521 unreachable from webserver"

**Síntoma**: Desde WS1: `timeout 2 bash -c "</dev/tcp/$DB_NODE_IP/1521"` → timeout

**Causa**: NSG DB no permite ingress desde WS subnet, o DB aún no está listo

**Solución**:
```bash
# Verificar NSG DB rules
DB_NSG_ID=$(oci network security-group rules list \
  --security-group-id $(terraform output -raw db_nsg_id) | \
  jq -r '.[0].security_group_id')

oci network security-group rules list --security-group-id $DB_NSG_ID | \
  grep -A3 "\"1521\""

# Debe existir: Direction: INGRESS, Protocol: TCP, Port: 1521, Source: WS_SUBNET_CIDR

# Si no existe, reaplica:
terraform apply -var="force_nsgrule_update=true"

# Esperar 2-3 minutos después de reaplicar
sleep 180
```

### Problema: "Cannot connect to DB - Invalid username/password"

**Síntoma**: `sqlplus sys/<password>@localhost:1521/APPDB` → ORA-01017

**Causa**: Password incorrecto o usuario SYS no disponible durante setup

**Solución**:
```bash
# Verificar que DB está AVAILABLE (no en PROVISIONING)
oci db system get --db-system-id $DB_OCID \
  --query 'data.\"lifecycle-state\"' --raw-output

# Si PROVISIONING: esperar 5-10 min más

# Si AVAILABLE pero password no funciona:
# 1. Verificar que usaste el password correcto (output de terraform)
# 2. Usuario debe ser SYS con "as sysdba"
# 3. Verificar SID correcto (default: APPDB)

# Reset password SYS (vía OCI API):
# No hay forma directa - destruir/recrear
```

### Problema: "NSG rule creation failed - Circular dependency"

**Síntoma**: Terraform error: NSG rules reference WS subnet que también reference DB NSG

**Causa**: Error de configuración en módulos (circular dependency)

**Solución**:
```bash
# Revalidar main.tf en módulos
terraform validate

# Si error persiste, clean state:
terraform taint oci_core_network_security_group.db_nsg
terraform apply

# O reiniciar plan:
rm terraform.tfstate*
terraform init
terraform apply
```

### Problema: "WS cloud-init failed - NFS mount error after DB creation"

**Síntoma**: WS no monta NFS después de agregar DB System

**Causa**: Cambio en DNS o NSG NFS de webserver durante creación

**Solución**:
```bash
# Reiniciar cloud-init en WS (via Bastion)
bash /tmp/ssh_cmd.sh << 'EOF'
sudo cloud-init clean --logs --seed
sudo cloud-init init
sudo cloud-init modules --mode=config
exit
EOF

# Verificar montaje
bash /tmp/ssh_cmd.sh << 'EOF'
mount | grep nfs
exit
EOF
```

---

## Siguiente Nivel: Arquitectura 07

Esta arquitectura es la base para **DataGuard HA**, donde se agrega:
- **Oracle Data Guard**: Replicación automática a segundo nodo (AD2)
- **Failover automático**: Si nodo primario cae, standby se promociona
- **Load Balancer para BD**: Distribuye lecturas entre primary + standby
- **Aplicación multi-instancia**: Redondeo de conexiones a DB

**Siguiente paso**: [`../07-dataguard-ha/README.md`](../07-dataguard-ha/README.md) (cuando esté disponible)

---

## Consideraciones Importantes para Producción

### Seguridad

- [ ] Cambiar password SYS inmediatamente después de crear DB
- [ ] Implementar VPN para acceso administrativo (no bastion directo)
- [ ] Habilitar audit database (AUDIT ALL by SYS)
- [ ] Configurar Data Pump encryption para backups
- [ ] Usar Database Vault para separación de roles

### Alta Disponibilidad

- [ ] Considerar Data Guard (Primary + Standby en AD diferentes)
- [ ] Configurar backup incremental (semanal + diario)
- [ ] Implementar monitores de health check (uptime monitoring)
- [ ] Probar failover regularmente (monthly DR drills)

### Optimización de Costos

- [ ] Usar standby database solo en producción (no dev/test)
- [ ] Implementar backup a Object Storage de larga retención (vs 30 días default)
- [ ] Usar SQL Tuning Advisor para optimizar queries
- [ ] Monitorear Alert Log regularmente para problemas de performance

### Compliance

- [ ] Documentar políticas de backup (RPO/RTO)
- [ ] Implementar Change Control (CR antes de cambios)
- [ ] Auditar accesos administrativos (OCI Identity Provider)
- [ ] Mantener logs de auditoría por mínimo 1 año

---

## Deploy Button

[![Deploy to OCI](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-06-base-de-datos.zip)

---

## Soporte y Documentación

- [Oracle DB System - Guía Completa](https://docs.oracle.com/en-us/iaas/Content/Database/home.htm)
- [Data Guard Configuration](https://docs.oracle.com/en-us/iaas/Content/Database/Tasks/creatingdataguardassociation.htm)
- [DB Backup and Recovery](https://docs.oracle.com/en-us/iaas/Content/Database/Tasks/backupandrecovery.htm)
- [Security Best Practices - OCI DB](https://docs.oracle.com/en-us/iaas/Content/Database/Concepts/dbsecurityoverview.htm)
- [Terraform OCI Database Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/database_db_system)
- [Oracle Database SQL Reference](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/index.html)

---

## FAQ

**P: Puedo usar Database Express Edition?**
R: No, OCI DB System solo soporta Standard Edition 2 y Enterprise Edition. Express Edition es para desarrollo local.

**P: Cuanto cuesta realmente una DB?**
R: Desde ~$25/mes (E4.Flex 2 OCPU) en Always Free hasta $500+/mes con Data Guard, M6.Flex y alta concurrencia.

**P: Necesito Data Guard?**
R: Para producción: sí (SLA 99.99%). Para desarrollo/testing: no (costo ~50% extra).

**P: Dónde guardo mis archivos compartidos (NFS) vs datos (DB)?**
R: Archivos estáticos, uploads, caché → NFS. Datos críticos, transacciones → Base de Datos. Ambos con backup.

**P: Puedo conectar de forma local a la DB sin Bastion?**
R: No (recomendado). Si necesitas: usar VPN + subnet privada. Bastion es más seguro.

**P: Cómo escalo a múltiples bases de datos?**
R: Crear segundo compartment → nueva arquitectura 06 con schema diferente. O usar CDBs (Container Databases) en Enterprise.
