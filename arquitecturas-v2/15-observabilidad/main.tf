# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  15 - Observabilidad — Logging, Monitoring y Alarms                        ║
# ║                                                                            ║
# ║  Topología:                                                                ║
# ║                                                                            ║
# ║    Webserver (instancia) ──► Custom Logs ──► Log Group                     ║
# ║         │                                                                  ║
# ║         ├──► Monitoring Metric (CPU) ──► Alarm ──► ONS Topic ──► Email     ║
# ║         │                                                                  ║
# ║         └──► VCN Flow Logs ──► Log Group                                   ║
# ║                                                                            ║
# ║    Logging Service:    Log Groups + Custom Logs + VCN Flow Logs            ║
# ║    Monitoring Service: Alarm (CPU > 80%) → ONS Notification               ║
# ║    Events Service:     Instance state change → ONS Notification            ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

locals {
  prefijo = "${var.proyecto}-${var.ambiente}"
  tags_comunes = {
    Proyecto     = var.proyecto
    Ambiente     = var.ambiente
    Propietario  = var.propietario
    Arquitectura = "15-observabilidad"
    ManagedBy    = "terraform"
  }
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_images" "ol8" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.shape_webserver
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# ═══════════════════════════════════════════════════════════════════════════════
#  1. RED
# ═══════════════════════════════════════════════════════════════════════════════

module "red" {
  source = "../../modulos/red/vcn"

  compartment_id            = var.compartment_ocid
  proyecto                  = var.proyecto
  ambiente                  = var.ambiente
  vcn_cidr                  = var.vcn_cidr
  habilitar_nat_gateway     = true
  habilitar_service_gateway = true
  tags                      = local.tags_comunes
}

resource "oci_core_security_list" "sl_vacia" {
  count          = var.habilitar_nsg ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = module.red.vcn_id
  display_name   = "${local.prefijo}-sl-vacia"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
  }

  freeform_tags = local.tags_comunes
}

module "nsgs" {
  count  = var.habilitar_nsg ? 1 : 0
  source = "../../modulos/seguridad/nsg"

  compartment_id     = var.compartment_ocid
  vcn_id             = module.red.vcn_id
  proyecto           = var.proyecto
  ambiente           = var.ambiente
  habilitar_nsg_web  = true
  habilitar_nsg_ssh  = true
  cidr_ssh_permitido = var.ssh_cidr_permitido
  cidr_red_interna   = [var.vcn_cidr]
  tags               = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  2. SUBNETS
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_core_subnet" "publica" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = module.red.vcn_id
  cidr_block                 = var.subnet_publica_cidr
  display_name               = "${local.prefijo}-sub-publica"
  dns_label                  = "pub"
  prohibit_public_ip_on_vnic = false
  route_table_id             = module.red.route_table_publica_id
  security_list_ids          = var.habilitar_nsg ? [oci_core_security_list.sl_vacia[0].id] : []
  freeform_tags              = local.tags_comunes
}

resource "oci_core_subnet" "privada" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = module.red.vcn_id
  cidr_block                 = var.subnet_privada_cidr
  display_name               = "${local.prefijo}-sub-privada"
  dns_label                  = "priv"
  prohibit_public_ip_on_vnic = true
  route_table_id             = module.red.route_table_privada_id
  security_list_ids          = var.habilitar_nsg ? [oci_core_security_list.sl_vacia[0].id] : []
  freeform_tags              = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  3. WEBSERVER (instancia para monitorear)
# ═══════════════════════════════════════════════════════════════════════════════

module "webserver" {
  source = "../../modulos/computo/webserver"

  compartment_id = var.compartment_ocid
  proyecto       = var.proyecto
  ambiente       = var.ambiente
  cantidad       = 1
  subnet_id      = oci_core_subnet.publica.id
  imagen_os      = data.oci_core_images.ol8.images[0].id
  shape          = var.shape_webserver
  ocpus          = var.ocpus_webserver
  memoria_gb     = var.memoria_webserver_gb
  ssh_public_key = var.ssh_public_key
  asignar_ip_publica = true
  nsg_ids            = var.habilitar_nsg ? module.nsgs[0].todos_nsg_ids : []
  tags               = local.tags_comunes

  userdata_extra = <<-EXTRA
# ─── Arquitectura 15: Página de observabilidad ────────────────────────────────
cat > /var/www/html/index.html << 'HTMLPAGE'
<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"><title>Observabilidad Backend</title>
<style>body{font-family:'Segoe UI',sans-serif;background:#0d1117;color:#c9d1d9;display:flex;justify-content:center;align-items:center;min-height:100vh;margin:0}.card{background:#161b22;border-radius:16px;padding:2.5rem;max-width:560px;box-shadow:0 10px 40px rgba(0,0,0,.4);border:1px solid #30363d}h1{color:#58a6ff;margin-top:0;font-size:1.5rem}.badge{display:inline-block;background:#238636;color:#fff;padding:3px 12px;border-radius:12px;font-size:.75rem;font-weight:700;margin-left:8px}.info{margin:.5rem 0;padding:.5rem 0;border-bottom:1px solid #21262d}.label{color:#8b949e;font-size:.85rem}.value{color:#f0f6fc;font-weight:600}.features{background:#0d1117;border-radius:10px;padding:1rem;margin-top:1rem;border:1px solid #30363d}.features h3{color:#58a6ff;margin:0 0 .5rem;font-size:.95rem}.feature{color:#7ee787;margin:.3rem 0}.footer{margin-top:1.5rem;font-size:.78rem;color:#484f58;text-align:center}</style></head>
<body><div class="card"><h1>Arquitectura 15 <span class="badge">Observabilidad</span></h1>
<div class="info"><span class="label">Hostname</span><br><span class="value">__HOSTNAME__</span></div>
<div class="info"><span class="label">IP</span><br><span class="value">__IP__</span></div>
<div class="features"><h3>Servicios de Observabilidad</h3>
<div class="feature">Logging Service (Custom Logs + VCN Flow Logs)</div>
<div class="feature">Monitoring (Métricas de CPU, Memoria)</div>
<div class="feature">Alarm (CPU > 80% → ONS Notification)</div>
<div class="feature">Events (Instance state change → Notification)</div></div>
<div class="footer">Observabilidad | oracle-cloud-latam</div></div></body></html>
HTMLPAGE
HOSTNAME_A=$(hostname)
IP_A=$(hostname -I | awk '{print $1}')
sed -i "s/__HOSTNAME__/$HOSTNAME_A/g" /var/www/html/index.html
sed -i "s/__IP__/$IP_A/g" /var/www/html/index.html
EXTRA
}

# ═══════════════════════════════════════════════════════════════════════════════
#  4. ONS — Notification Topic + Subscription
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_ons_notification_topic" "alertas" {
  compartment_id = var.compartment_ocid
  name           = "${local.prefijo}-alertas"
  description    = "Topic de alertas de observabilidad"
  freeform_tags  = local.tags_comunes
}

resource "oci_ons_subscription" "email" {
  compartment_id = var.compartment_ocid
  topic_id       = oci_ons_notification_topic.alertas.id
  protocol       = "EMAIL"
  endpoint       = var.email_notificacion
  freeform_tags  = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  5. LOGGING — Log Group + Custom Log + VCN Flow Log
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_logging_log_group" "app_logs" {
  compartment_id = var.compartment_ocid
  display_name   = "${local.prefijo}-log-group-app"
  description    = "Log group para aplicación web"
  freeform_tags  = local.tags_comunes
}

resource "oci_logging_log" "custom_log" {
  display_name = "${local.prefijo}-custom-log"
  log_group_id = oci_logging_log_group.app_logs.id
  log_type     = "CUSTOM"
  freeform_tags = local.tags_comunes
}

resource "oci_logging_log_group" "vcn_logs" {
  compartment_id = var.compartment_ocid
  display_name   = "${local.prefijo}-log-group-vcn"
  description    = "Log group para VCN Flow Logs"
  freeform_tags  = local.tags_comunes
}

resource "oci_logging_log" "vcn_flow_log" {
  display_name = "${local.prefijo}-vcn-flow-log"
  log_group_id = oci_logging_log_group.vcn_logs.id
  log_type     = "SERVICE"

  configuration {
    source {
      category    = "all"
      resource    = oci_core_subnet.publica.id
      service     = "flowlogs"
      source_type = "OCISERVICE"
    }
    compartment_id = var.compartment_ocid
  }

  is_enabled    = true
  freeform_tags = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  6. MONITORING — Alarm (CPU > 80%)
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_monitoring_alarm" "cpu_alta" {
  compartment_id        = var.compartment_ocid
  display_name          = "${local.prefijo}-alarm-cpu-alta"
  namespace             = "oci_computeagent"
  query                 = "CpuUtilization[5m]{resourceId = \"${module.webserver.instancia_ids[0]}\"}.mean() > 80"
  severity              = "CRITICAL"
  is_enabled            = true
  pending_duration      = "PT5M"
  body                  = "ALERTA: CPU del webserver supera 80% durante 5 minutos. Arquitectura 15 - Observabilidad."
  metric_compartment_id = var.compartment_ocid

  destinations = [oci_ons_notification_topic.alertas.id]

  freeform_tags = local.tags_comunes
}

resource "oci_monitoring_alarm" "status_instancia" {
  compartment_id        = var.compartment_ocid
  display_name          = "${local.prefijo}-alarm-status"
  namespace             = "oci_compute_infrastructure_health"
  query                 = "instance_status[1m]{resourceId = \"${module.webserver.instancia_ids[0]}\"}.count() < 1"
  severity              = "WARNING"
  is_enabled            = true
  pending_duration      = "PT5M"
  body                  = "ADVERTENCIA: Instancia webserver no reporta estado. Verificar disponibilidad."
  metric_compartment_id = var.compartment_ocid

  destinations = [oci_ons_notification_topic.alertas.id]

  freeform_tags = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  7. EVENTS — Instance State Change Rule
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_events_rule" "instancia_cambio_estado" {
  compartment_id = var.compartment_ocid
  display_name   = "${local.prefijo}-event-instance-state"
  description    = "Notificar cambios de estado en instancias de cómputo"
  is_enabled     = true

  condition = jsonencode({
    eventType = ["com.oraclecloud.computeapi.terminateinstance.end",
                 "com.oraclecloud.computeapi.launchinstance.end"]
  })

  actions {
    actions {
      action_type = "ONS"
      is_enabled  = true
      topic_id    = oci_ons_notification_topic.alertas.id
    }
  }

  freeform_tags = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  8. BASTION
# ═══════════════════════════════════════════════════════════════════════════════

module "bastion" {
  source = "../../modulos/red/bastion-service"

  compartment_id = var.compartment_ocid
  subnet_id      = oci_core_subnet.privada.id
  proyecto       = var.proyecto
  ambiente       = var.ambiente
  tags           = local.tags_comunes
}
