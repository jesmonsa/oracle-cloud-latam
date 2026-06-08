# 15 - Observabilidad: Logging, Monitoring y Alarms

Arquitectura empresarial que implementa observabilidad completa en Oracle Cloud Infrastructure con **Logging Service**, **Monitoring Service** y **Oracle Notification Service (ONS)** para garantizar visibilidad total de la infraestructura. Incluye logs personalizados, métricas de CPU, alarmas inteligentes y notificaciones en tiempo real.

[![Deploy to OCI](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-15-observabilidad.zip)

## Descripción General

Observabilidad es la capacidad de entender el estado interno de un sistema observando únicamente sus salidas. Esta arquitectura implementa:

- **Logging Service**: Centraliza logs de aplicaciones, instancias y VCN
- **Monitoring Service**: Recolecta métricas y crea alarmas basadas en umbrales
- **Oracle Notification Service (ONS)**: Envía notificaciones por email, SMS u otro medio
- **Events Service**: Reacciona a cambios de estado (startup, shutdown, etc.)
- **VCN Flow Logs**: Registra tráfico de red para auditoría y troubleshooting
- **Custom Logs**: Logs personalizados desde aplicaciones con agent OCA

## Arquitectura

```
                        Webserver Instance
                        (Compute)
                              │
                ┌─────────────┼─────────────┐
                │             │             │
                ▼             ▼             ▼
           ┌─────────┐   ┌──────────┐  ┌──────────┐
           │ Custom  │   │Monitoring│  │  VCN     │
           │ Logs    │   │ Metric   │  │Flow Logs │
           │(Agent)  │   │(CPU %)   │  │(L3/L4)   │
           └────┬────┘   └────┬─────┘  └────┬─────┘
                │             │             │
                └─────────────┼─────────────┘
                              │
                       ┌──────▼──────┐
                       │ Log Groups  │
                       │(Centralizado)
                       └──────┬──────┘
                              │
                ┌─────────────┴──────────┐
                │                        │
                ▼                        ▼
          ┌──────────┐          ┌──────────────┐
          │Monitoring│          │Event Service │
          │Alarm     │          │(State change)│
          │CPU > 80% │          │(Start/Stop)  │
          └────┬─────┘          └────┬─────────┘
               │                      │
               └──────────┬───────────┘
                          │
                    ┌─────▼──────┐
                    │  ONS Topic  │
                    │(Notification)
                    └─────┬──────┘
                          │
                    ┌─────▼──────────┐
                    │  Email Alert   │
                    │(SNS Subscriber)│
                    └────────────────┘
```

### Flujo de Eventos

```
1. Webserver ejecuta aplicación
   └─► Escribe logs en /var/log/app.log

2. OCA Agent lee logs
   └─► Envía a Logging Service → Log Group

3. Monitoring Service recolecta CPU metric
   └─► Compara con threshold (80%)
   └─► Si CPU > 80% → Dispara Alarm

4. Alarm publica en ONS Topic
   └─► Topic envía email a suscriptores

5. Events Service monitorea instancia
   └─► Cuando cambia estado (START/STOP)
   └─► Publica en ONS Topic → Email
```

## Recursos Desplegados

| Recurso | Descripción | Tipo OCI |
|---------|-------------|----------|
| **VCN** | Red Virtual Cloud con CIDR 10.0.0.0/16 | oci_core_vcn |
| **Subnet Pública** | Subred 10.0.0.0/24 para bastion/acceso | oci_core_subnet |
| **Subnet Privada** | Subred 10.0.1.0/24 para webserver | oci_core_subnet |
| **Internet Gateway** | Puerta de enlace a internet | oci_core_internet_gateway |
| **NAT Gateway** | Para egress desde subnet privada | oci_core_nat_gateway |
| **Webserver (Compute)** | VM con Oracle Linux 8 y agent OCA | oci_core_instance |
| **NSG (Web)** | Firewall para tráfico HTTP/HTTPS | oci_core_network_security_group |
| **NSG (SSH)** | Firewall para acceso SSH | oci_core_network_security_group |
| **Log Group** | Repositorio centralizado de logs | oci_logging_log_group |
| **Log** | Destino para custom logs del webserver | oci_logging_log |
| **VCN Flow Log** | Registra tráfico de red (Layer 3/4) | oci_logging_log |
| **Monitoring Query** | Métricas de CPU de la instancia | oci_monitoring_alarm |
| **Alarm** | Alerta cuando CPU > 80% | oci_monitoring_alarm |
| **ONS Topic** | Tema de notificación centralizado | oci_ons_notification_topic |
| **ONS Subscription** | Suscriptor email para alertas | oci_ons_notification_topic_subscription |
| **Events Rule** | Reacciona a cambios de estado | oci_events_rule |

## Shapes Compatibles

El webserver puede utilizar cualquiera de estos shapes. Las métricas de monitoring funcionan con todos:

| Shape | vCPU | Memoria | Costo | Notas |
|-------|------|---------|-------|-------|
| **VM.Standard.E4.Flex** | 1-32 | 1-192 GB | $0.0263/OCPUh | Recomendado, Always Free 1 OCPU |
| **VM.Standard.E5.Flex** | 1-32 | 1-192 GB | $0.0273/OCPUh | Arquitectura más reciente (Skylake) |
| **VM.Standard.A1.Flex** | 1-80 | 1-480 GB | $0.0145/OCPUh | ARM64, ideal para pruebas |
| **VM.Standard.X9.Flex** | 1-64 | 1-512 GB | $0.3456/OCPUh | Alto rendimiento, GPU opcional |

**Configuración recomendada**: 1 OCPU + 8 GB RAM (E4.Flex) para testing observabilidad.

## Variables Principales

| Variable | Descripción | Tipo | Default | Requerido |
|----------|-------------|------|---------|-----------|
| `tenancy_ocid` | OCID del Tenancy | string | - | Sí |
| `compartment_ocid` | OCID del Compartment | string | - | Sí |
| `region` | Región OCI | string | us-ashburn-1 | No |
| `proyecto` | Prefijo para recursos | string | observa | No |
| `ambiente` | Ambiente (dev/staging/prod) | string | desarrollo | No |
| `propietario` | Propietario de recursos | string | admin | No |
| `vcn_cidr` | CIDR de la VCN | string | 10.0.0.0/16 | No |
| `subnet_publica_cidr` | CIDR de subnet pública | string | 10.0.0.0/24 | No |
| `subnet_privada_cidr` | CIDR de subnet privada | string | 10.0.1.0/24 | No |
| `shape_webserver` | Shape del webserver | string | VM.Standard.E4.Flex | No |
| `ocpus_webserver` | OCPU para webserver | number | 1 | No |
| `memoria_webserver_gb` | RAM en GB | number | 8 | No |
| `ssh_public_key` | Clave SSH pública | string | - | Sí |
| `habilitar_nsg` | Usar NSG en lugar de Security Lists | bool | true | No |
| `ssh_cidr_permitido` | CIDR permitido para SSH | string | 0.0.0.0/0 | No |
| `email_notificacion` | Email para recibir alertas | string | admin@example.com | Sí |

### Ejemplo de terraform.tfvars

```hcl
tenancy_ocid       = "ocid1.tenancy.oc1..xxxxxxxxxx"
compartment_ocid   = "ocid1.compartment.oc1..xxxxxxxxxx"
current_user_ocid  = "ocid1.user.oc1..xxxxxxxxxx"
fingerprint        = "aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99"
private_key_path   = "~/.oci/oci_api_key.pem"

region           = "us-ashburn-1"
proyecto         = "observa"
ambiente         = "desarrollo"
shape_webserver  = "VM.Standard.E4.Flex"
ocpus_webserver  = 1
memoria_webserver_gb = 8

ssh_public_key   = "ssh-rsa AAAA... user@host"
habilitar_nsg    = true
ssh_cidr_permitido = "203.0.113.0/32"  # Tu IP pública

# IMPORTANTE: Cambiar a tu email
email_notificacion = "tu-email@example.com"
```

## Estimación de Costos

### Always Free Tier

Dentro del Always Free Tier de Oracle Cloud:

- **Logging Service**: Ingestión de 10 GB/mes (gratis)
- **Monitoring Service**: Métricas estándar de compute (gratis)
- **Alarms**: Primeras 5 alarmas (gratis)
- **ONS**: Primeros 1,000 publicaciones/mes (gratis)
- **Compute (VM.Standard.E4.Flex)**: 1 OCPU + 8 GB RAM (gratis)
- **VCN, Subnets, Flow Logs**: Gratis

**Costo mensual con Always Free**: $0.00 USD/mes

### Con recursos adicionales

Si escalas fuera del Always Free:

- Logging Service (ingestión): $0.50 por GB
- Monitoring (alarmas adicionales): $0.10 por alarma/mes
- ONS (publicaciones): $0.60 por millón
- Compute: ~$19.76/mes (1 OCPU E4.Flex)

**Costo estimado (dentro Always Free)**: ~$0.00 USD/mes

### Optimizaciones de costo

- Mantener logs < 10 GB/mes: Usar retention policies
- Filtrar logs innecesarios: Usar exclusión de patrones
- Consolidar alarmas: Usar una sola alarma multi-métrica
- Usar Always Free regions: us-ashburn-1, us-phoenix-1, uk-london-1

## Requisitos Previos

### Credenciales OCI

1. **Crear API Key para Terraform**:
   ```bash
   # Ir a OCI Console → User Settings → API Keys
   # Descargar clave privada: oci_api_key.pem
   chmod 600 ~/.oci/oci_api_key.pem
   ```

2. **Obtener OCIDs**:
   ```bash
   # Profile → Tenancy Settings → Copy OCID
   # Profile → Copy User OCID
   # Compartments → Copy OCID
   ```

3. **Obtener Fingerprint**:
   ```bash
   openssl rsa -pubout -outform DER -in ~/.oci/oci_api_key.pem | \
     openssl md5 -c | sed 's/^.* //' | tr '[:lower:]' '[:upper:]'
   ```

### Software Requerido

- **Terraform** >= 1.5.0
- **OCI CLI** >= 3.0 (opcional)
- **SSH key pair**:
  ```bash
  ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
  cat ~/.ssh/id_rsa.pub
  ```

### Permisos IAM

El usuario debe tener permisos para crear:

- VCN, Subnets, Internet Gateway
- Compute Instances
- Network Security Groups
- Log Groups y Custom Logs
- Alarms y Monitoring
- ONS Topics y Subscriptions
- Events Rules

Ejemplo de política:

```hcl
Allow group developers to manage virtual-network-family
Allow group developers to manage compute-family
Allow group developers to manage logging-family
Allow group developers to manage monitoring-family
Allow group developers to manage ons-family
Allow group developers to manage events-rules
```

## Despliegue Rápido

### Paso 1: Preparar Entorno

```bash
# Acceder al directorio
cd arquitecturas-v2/15-observabilidad

# Copiar plantilla
cp terraform.tfvars.example terraform.tfvars

# Editar con tus valores (IMPORTANTE: cambiar email)
vim terraform.tfvars
```

### Paso 2: Inicializar Terraform

```bash
# Inicializar backend local
terraform init

# (Opcional) Usar remote state
terraform init -backend-config=../00-bootstrap-remotestate/backend.hcl
```

### Paso 3: Validar y Planificar

```bash
# Validar sintaxis
terraform validate

# Mostrar plan
terraform plan -out=plan.tfplan

# Revisar recursos (debe mostrar ~18 recursos)
```

### Paso 4: Aplicar Configuración

```bash
# Aplicar
terraform apply plan.tfplan

# O directamente (sin guardar plan):
terraform apply
```

**Tiempo esperado**: 5-7 minutos

### Paso 5: Verificar Despliegue

```bash
# Obtener outputs
terraform output

# Guardar para referencia
terraform output > outputs.txt
```

## Verificación

### 1. Verificar en OCI Console

```bash
# Log Group
Observability & Management → Logging → Log Groups
→ Debería existir: observa-desarrollo-lg

# Logs
Observability & Management → Logging → Logs
→ Debería existir: observa-desarrollo-custom-log (estado: Enabled)

# Alarma
Observability & Management → Monitoring → Alarms
→ Debería existir: observa-desarrollo-cpu-alarm (threshold: 80%)

# ONS Topic
Messaging → Notification Service → Topics
→ Debería existir: observa-desarrollo-topic
→ Subscription debe estar en estado PENDING (confirmar en email)
```

### 2. Confirmar Suscripción a Email

**Acciones requeridas**:

```
Deberías recibir 2 emails:

1. De: oci-notifications@oraclecloud.com
   Asunto: "Confirm subscription to topic..."
   → Hacer clic en "Confirm subscription"
   
2. De: Oracle Cloud Infrastructure
   Asunto: "test-message from topic..."
   → Confirma que el sistema está funcionando
```

Si no recibes:
- Verificar spam/junk
- Confirmar email en terraform.tfvars
- Redeployer: `terraform destroy && terraform apply`

### 3. Generar Carga de CPU

```bash
# Obtener IP del webserver
WEBSERVER_IP=$(terraform output -raw webserver_private_ip)

# Conectar via Bastion o Systems Manager
ssh opc@$WEBSERVER_IP

# En el webserver, generar carga CPU
cat > /tmp/stress.sh << 'EOF'
#!/bin/bash
# Ejecutar 8 procesos que calculan números primos
for i in {1..8}; do
  ( yes | sha256sum | head -c 32000000 ) &
done
wait
EOF

chmod +x /tmp/stress.sh
/tmp/stress.sh &

# Monitorear CPU
top -b -n 1
```

### 4. Verificar Alarma Disparada

Después de ~5 minutos con CPU > 80%:

```bash
# En OCI Console
Observability & Management → Monitoring → Alarms
→ observa-desarrollo-cpu-alarm → Status: FIRING

# Debería llegar email de ONS Topic:
# Asunto: "Oracle Cloud Alarm Notification"
# Body: "Alarm Name: observa-desarrollo-cpu-alarm"
```

### 5. Revisar Logs

```bash
# En OCI Console
Observability & Management → Logging → Log Search
→ Resource Type: Instance
→ Buscar: observa-desarrollo
→ Ver eventos de startup, CPU, cambios de estado

# Desde CLI
oci logging-search search-logs \
  --compartment-id <compartment-id> \
  --search-query "search \"observa-desarrollo\""
```

## Limpieza

### Destruir Todos los Recursos

```bash
# Mostrar plan de destrucción
terraform plan -destroy

# Destruir
terraform destroy

# Sin confirmación:
terraform destroy -auto-approve
```

**Nota importante**: La limpieza puede eliminar logs y métricas históricas.

### Conservar Logs para Auditoría

Si quieres mantener logs después de destruir infraestructura:

```hcl
# En terraform, usar lifecycle para preservar

resource "oci_logging_log_group" "logs" {
  lifecycle {
    prevent_destroy = true
  }
}

# Destruir sin destruir log group
terraform destroy -target='!oci_logging_log_group.logs'
```

## Troubleshooting

### Problema 1: No Recibo Emails del ONS

**Síntoma**: Email subscription permanece en "PENDING"

**Causa**: 
- Email incorrecto en terraform.tfvars
- Email confirmación en spam
- Límite de suscriptores alcanzado

**Solución**:

```bash
# Verificar suscripción
oci ons subscription list --compartment-id <compartment-id>

# Volver a crear suscripción
terraform taint oci_ons_notification_topic_subscription.email
terraform apply

# Verificar email en spam/junk
# Marcar como no spam y hacer clic en "Confirm subscription"

# Probar publicación manual
oci ons message publish \
  --topic-id ocid1.onstopic.... \
  --message "Test message from CLI"
```

### Problema 2: Alarma No se Dispara Nunca

**Síntoma**: CPU > 80% pero alarm state = OK

**Causa**:
- Métrica no se está recolectando
- Threshold mal configurado
- Período de evaluación muy largo

**Solución**:

```bash
# Verificar que existe métrica CPU
oci monitoring metric-data summarize-metrics-data \
  --namespace oci_computeagent \
  --query-text 'CpuUtilization[1m]{resourceId = "ocid1.instance..."}'

# Verificar configuración de alarm
terraform output | grep -A 5 "alarm"

# Generar carga más intensa
stress-ng --cpu 0 --timeout 600s --quiet &
```

### Problema 3: Logs No Aparecen en Log Group

**Síntoma**: Log Group existe pero está vacío

**Causa**:
- OCA Agent no está instalado/running
- Log path incorrecto
- Permisos insuficientes

**Solución**:

```bash
# SSH al webserver
ssh opc@webserver

# Verificar agent está running
sudo systemctl status oracle-cloud-agent
sudo systemctl status oracle-cloud-agent-updater

# Reiniciar si es necesario
sudo systemctl restart oracle-cloud-agent

# Verificar logs agent
cat /var/log/oracle-cloud-agent/oracle-cloud-agent.log

# Crear log de prueba
echo "test log message" >> /var/log/messages

# Esperar 1-2 minutos y verificar en OCI Console
```

### Problema 4: Permisos Insuficientes para Crear Recursos

**Síntoma**:
```
Error: Service error: Forbidden
Details: Authorization failed or requested resource not found
```

**Causa**: Usuario no tiene permisos IAM necesarios

**Solución**:

```bash
# Verificar perfil actual
oci identity user get --user-id <user-ocid>

# Aplicar política (como administrador)
oci iam policy create \
  --name terraform-observability-policy \
  --statements '[
    "Allow group developers to manage virtual-network-family",
    "Allow group developers to manage compute-family",
    "Allow group developers to manage logging-family",
    "Allow group developers to manage monitoring-family",
    "Allow group developers to manage ons-family",
    "Allow group developers to manage events-family"
  ]'

# Reintentar deploy
terraform apply
```

## Mejores Prácticas

### 1. Log Retention Policies

```hcl
# Mantener logs máximo 30 días para reducir costos
resource "oci_logging_log" "app_log" {
  log_group_id = oci_logging_log_group.logs.id
  
  retention_duration = 30  # días
  # O usar: is_enabled = false (después de 30 días)
}
```

### 2. Alarmas Multi-Métrica

```hcl
# Combinar múltiples condiciones
resource "oci_monitoring_alarm" "composite" {
  metric_compartment_id = var.compartment_ocid
  metric_dimension_filters_map = {
    instance_id = oci_core_instance.server.id
  }
  
  # Alarmar si CPU > 80% O Memoria > 90%
  query = <<EOQ
  CPU > 80 or Memory > 90
  EOQ
}
```

### 3. Logs Estructurados (JSON)

```bash
# En tu aplicación, usar JSON para mejor análisis
echo '{"timestamp":"2026-04-12T10:30:45Z","level":"INFO","message":"Request processed","duration_ms":145}' >> /var/log/app.log
```

### 4. Dashboard de Monitoring

```hcl
# Crear dashboard personalizado
resource "oci_monitoring_dashboard" "main" {
  compartment_id = var.compartment_ocid
  display_name   = "observa-development-dashboard"
  
  dashboard_json = jsonencode({
    widgets = [
      {
        title = "CPU Utilization"
        query = "CpuUtilization[1m]"
      },
      {
        title = "Network Inbound"
        query = "NetworksBytesIn[1m]"
      }
    ]
  })
}
```

## Siguientes Pasos

Una vez desplegada observabilidad, puedes:

### 1. Conectar a Vault y Baselines (Arquitectura 16)

Asegurar credenciales y aplicar baseline de seguridad:

[16 - Vault & Baselines](../16-vault-baselines/)

### 2. Escalar con Arquitectura Completa

Integrar con:
- Database
- Load Balancer
- WAF
- Multi-region replication

[17 - Arquitectura Completa](../17-arquitectura-completa/)

### 3. Automatizar Remediación

```hcl
# Crear función que ejecute automáticamente
resource "oci_functions_function" "remediate" {
  # Se ejecuta cuando alarm dispara
  # Ej: restart instancia, escalar carga, etc.
}

# Conectar alarm a Events Rule
resource "oci_events_rule" "auto_remediate" {
  event_type = ["com.oraclecloud.monitoring.alarm"]
  target = oci_functions_function.remediate.id
}
```

## Referencias

- [OCI Logging Service](https://docs.oracle.com/en-us/iaas/Content/Logging/home.htm)
- [OCI Monitoring Service](https://docs.oracle.com/en-us/iaas/Content/Monitoring/home.htm)
- [OCI Notification Service](https://docs.oracle.com/en-us/iaas/Content/Notification/home.htm)
- [OCI Events Service](https://docs.oracle.com/en-us/iaas/Content/Events/home.htm)
- [OCI Terraform Provider - Logging](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/logging_log_group)
- [OCI Terraform Provider - Monitoring](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/monitoring_alarm)

## Contribuciones

Para contribuir:

1. Fork el repositorio
2. Crea rama: `git checkout -b feature/nombre`
3. Commit: `git commit -am 'Descripción'`
4. Push: `git push origin feature/nombre`
5. Pull Request

## Licencia

Este proyecto está bajo la licencia MIT. Ver LICENSE para detalles.

## Soporte

- **Issues**: GitHub Issues
- **Documentación**: Ver README.md en cada arquitectura
- **Comunidad**: LATAM Oracle Cloud Community

---

**Última actualización**: Abril 2026
**Versión**: 2.0
**Compatibilidad**: Terraform >= 1.5.0, OCI Provider >= 5.0
**Tested on**: Oracle Cloud (us-ashburn-1, us-phoenix-1)
