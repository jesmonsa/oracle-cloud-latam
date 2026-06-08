# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  17 - Arquitectura Completa — Integración total de servicios OCI           ║
# ║                                                                            ║
# ║  Topología:                                                                ║
# ║                                                                            ║
# ║    Internet ──► Load Balancer (público)                                    ║
# ║                     │                                                      ║
# ║                     ├──► Webserver 1 (privado)                             ║
# ║                     └──► Webserver 2 (privado)                             ║
# ║                                                                            ║
# ║    Vault (KMS) → Master Key (AES-256)                                     ║
# ║    Logging     → VCN Flow Logs + Custom Logs                              ║
# ║    Monitoring  → CPU Alarm → ONS Topic → Email                            ║
# ║    Events      → Instance state change → Email                            ║
# ║    Bastion     → Acceso SSH a instancias privadas                         ║
# ║                                                                            ║
# ║  Esta arquitectura integra: red, seguridad, cómputo, balanceo de carga,   ║
# ║  cifrado, observabilidad y acceso seguro en una sola implementación.       ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

locals {
  prefijo = "${var.proyecto}-${var.ambiente}"
  tags_comunes = {
    Proyecto     = var.proyecto
    Ambiente     = var.ambiente
    Propietario  = var.propietario
    Arquitectura = "17-arquitectura-completa"
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
#  3. WEBSERVERS (2 instancias para alta disponibilidad)
# ═══════════════════════════════════════════════════════════════════════════════

module "webserver" {
  source = "../../modulos/computo/webserver"

  compartment_id = var.compartment_ocid
  proyecto       = var.proyecto
  ambiente       = var.ambiente
  cantidad       = 2
  subnet_id      = oci_core_subnet.privada.id
  imagen_os      = data.oci_core_images.ol8.images[0].id
  shape          = var.shape_webserver
  ocpus          = var.ocpus_webserver
  memoria_gb     = var.memoria_webserver_gb
  ssh_public_key = var.ssh_public_key
  nsg_ids        = var.habilitar_nsg ? module.nsgs[0].todos_nsg_ids : []
  tags           = local.tags_comunes

  userdata_extra = <<-EXTRA
# ─── Arquitectura 17: Página de arquitectura completa ─────────────────────
cat > /var/www/html/index.html << 'HTMLPAGE'
<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"><title>Arquitectura Completa</title>
<style>body{font-family:'Segoe UI',sans-serif;background:#0d1117;color:#c9d1d9;display:flex;justify-content:center;align-items:center;min-height:100vh;margin:0}.card{background:#161b22;border-radius:16px;padding:2.5rem;max-width:620px;box-shadow:0 10px 40px rgba(0,0,0,.4);border:1px solid #30363d}h1{color:#58a6ff;margin-top:0;font-size:1.5rem}.badge{display:inline-block;background:#da3633;color:#fff;padding:3px 12px;border-radius:12px;font-size:.75rem;font-weight:700;margin-left:8px}.info{margin:.5rem 0;padding:.5rem 0;border-bottom:1px solid #21262d}.label{color:#8b949e;font-size:.85rem}.value{color:#f0f6fc;font-weight:600}.services{display:grid;grid-template-columns:1fr 1fr;gap:.5rem;margin-top:1rem}.svc{background:#0d1117;border-radius:8px;padding:.6rem;border:1px solid #30363d;font-size:.82rem}.svc-name{color:#58a6ff;font-weight:600}.svc-desc{color:#8b949e;font-size:.75rem}.footer{margin-top:1.5rem;font-size:.78rem;color:#484f58;text-align:center}</style></head>
<body><div class="card"><h1>Arquitectura 17 <span class="badge">COMPLETA</span></h1>
<div class="info"><span class="label">Servidor</span><br><span class="value">__HOSTNAME__</span></div>
<div class="info"><span class="label">IP Privada</span><br><span class="value">__IP__</span></div>
<div class="services">
<div class="svc"><span class="svc-name">VCN + Subnets</span><br><span class="svc-desc">Red virtual con subnets públicas y privadas</span></div>
<div class="svc"><span class="svc-name">Load Balancer</span><br><span class="svc-desc">Balanceo HTTP con health checks</span></div>
<div class="svc"><span class="svc-name">NSG Security</span><br><span class="svc-desc">Network Security Groups granulares</span></div>
<div class="svc"><span class="svc-name">Vault KMS</span><br><span class="svc-desc">Master Encryption Key AES-256</span></div>
<div class="svc"><span class="svc-name">Logging</span><br><span class="svc-desc">VCN Flow Logs + Custom Logs</span></div>
<div class="svc"><span class="svc-name">Monitoring</span><br><span class="svc-desc">Alarma CPU > 80%</span></div>
<div class="svc"><span class="svc-name">Events</span><br><span class="svc-desc">Instance state → ONS</span></div>
<div class="svc"><span class="svc-name">Bastion</span><br><span class="svc-desc">Acceso SSH seguro</span></div>
</div>
<div class="footer">Arquitectura Completa v2 | oracle-cloud-latam</div></div></body></html>
HTMLPAGE
HOSTNAME_A=$(hostname)
IP_A=$(hostname -I | awk '{print $1}')
sed -i "s/__HOSTNAME__/$HOSTNAME_A/g" /var/www/html/index.html
sed -i "s/__IP__/$IP_A/g" /var/www/html/index.html
EXTRA
}

# ═══════════════════════════════════════════════════════════════════════════════
#  4. LOAD BALANCER
# ═══════════════════════════════════════════════════════════════════════════════

module "lb" {
  source = "../../modulos/red/load-balancer"

  compartment_id = var.compartment_ocid
  proyecto       = var.proyecto
  ambiente       = var.ambiente
  subnet_id      = oci_core_subnet.publica.id
  backend_ips    = module.webserver.ips_privadas
  nsg_ids        = var.habilitar_nsg ? [module.nsgs[0].nsg_web_id] : []
  tags           = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  5. VAULT (KMS)
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_kms_vault" "vault" {
  compartment_id = var.compartment_ocid
  display_name   = "${local.prefijo}-vault"
  vault_type     = "DEFAULT"
  freeform_tags  = local.tags_comunes
}

resource "oci_kms_key" "master_key" {
  compartment_id = var.compartment_ocid
  display_name   = "${local.prefijo}-master-key"

  key_shape {
    algorithm = "AES"
    length    = 32
  }

  management_endpoint = oci_kms_vault.vault.management_endpoint
  freeform_tags       = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  6. ONS — Notificaciones
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_ons_notification_topic" "alertas" {
  compartment_id = var.compartment_ocid
  name           = "${local.prefijo}-alertas"
  description    = "Alertas de la arquitectura completa"
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
#  7. LOGGING — VCN Flow Logs + Custom Logs
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_logging_log_group" "app_logs" {
  compartment_id = var.compartment_ocid
  display_name   = "${local.prefijo}-log-group-app"
  description    = "Application and infrastructure logs"
  freeform_tags  = local.tags_comunes
}

resource "oci_logging_log" "custom_log" {
  display_name  = "${local.prefijo}-custom-log"
  log_group_id  = oci_logging_log_group.app_logs.id
  log_type      = "CUSTOM"
  freeform_tags = local.tags_comunes
}

resource "oci_logging_log" "vcn_flow_log" {
  display_name = "${local.prefijo}-vcn-flow-log"
  log_group_id = oci_logging_log_group.app_logs.id
  log_type     = "SERVICE"

  configuration {
    source {
      category    = "all"
      resource    = oci_core_subnet.privada.id
      service     = "flowlogs"
      source_type = "OCISERVICE"
    }
    compartment_id = var.compartment_ocid
  }

  is_enabled    = true
  freeform_tags = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  8. MONITORING — Alarms
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_monitoring_alarm" "cpu_alta" {
  compartment_id        = var.compartment_ocid
  display_name          = "${local.prefijo}-alarm-cpu-alta"
  namespace             = "oci_computeagent"
  query                 = "CpuUtilization[5m]{resourceId = \"${module.webserver.instancia_ids[0]}\"}.mean() > 80"
  severity              = "CRITICAL"
  is_enabled            = true
  pending_duration      = "PT5M"
  body                  = "ALERTA: CPU del webserver supera 80%. Arquitectura 17 Completa."
  metric_compartment_id = var.compartment_ocid

  destinations = [oci_ons_notification_topic.alertas.id]

  freeform_tags = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  9. EVENTS — Instance state change
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_events_rule" "instancia_cambio" {
  compartment_id = var.compartment_ocid
  display_name   = "${local.prefijo}-event-instance"
  description    = "Notificar cambios de estado en instancias"
  is_enabled     = true

  condition = jsonencode({
    eventType = [
      "com.oraclecloud.computeapi.terminateinstance.end",
      "com.oraclecloud.computeapi.launchinstance.end"
    ]
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
#  10. BASTION
# ═══════════════════════════════════════════════════════════════════════════════

module "bastion" {
  source = "../../modulos/red/bastion-service"

  compartment_id = var.compartment_ocid
  subnet_id      = oci_core_subnet.privada.id
  proyecto       = var.proyecto
  ambiente       = var.ambiente
  tags           = local.tags_comunes
}
