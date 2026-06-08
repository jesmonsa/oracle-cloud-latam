# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  16 - Vault + Baselines — KMS, Cloud Guard y Security Zones                ║
# ║                                                                            ║
# ║  Topología:                                                                ║
# ║                                                                            ║
# ║    OCI Vault (KMS)                                                         ║
# ║      └── Master Encryption Key (AES 256)                                   ║
# ║                                                                            ║
# ║    Cloud Guard                                                             ║
# ║      └── Target → Compartment (detector + responder recipes)               ║
# ║                                                                            ║
# ║    ONS Topic → Email (alertas de seguridad)                                ║
# ║                                                                            ║
# ║    Logging Audit + Security Log Group                                      ║
# ║                                                                            ║
# ║  Esta arquitectura demuestra las mejores prácticas de seguridad:           ║
# ║  cifrado de datos con Vault/KMS, detección de amenazas con Cloud Guard,    ║
# ║  y auditoría con Logging.                                                  ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

locals {
  prefijo = "${var.proyecto}-${var.ambiente}"
  tags_comunes = {
    Proyecto     = var.proyecto
    Ambiente     = var.ambiente
    Propietario  = var.propietario
    Arquitectura = "16-vault-baselines"
    ManagedBy    = "terraform"
  }
}

# ═══════════════════════════════════════════════════════════════════════════════
#  1. RED (mínima — solo para demostración de Vault endpoint)
# ═══════════════════════════════════════════════════════════════════════════════

module "red" {
  source = "../../modulos/red/vcn"

  compartment_id            = var.compartment_ocid
  proyecto                  = var.proyecto
  ambiente                  = var.ambiente
  vcn_cidr                  = var.vcn_cidr
  habilitar_nat_gateway     = false
  habilitar_service_gateway = true
  tags                      = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  2. VAULT (KMS) — Almacén de claves de cifrado
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
#  3. ONS — Notification Topic para alertas de seguridad
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_ons_notification_topic" "seguridad" {
  compartment_id = var.compartment_ocid
  name           = "${local.prefijo}-seguridad"
  description    = "Alertas de seguridad — Vault + Cloud Guard"
  freeform_tags  = local.tags_comunes
}

resource "oci_ons_subscription" "email" {
  compartment_id = var.compartment_ocid
  topic_id       = oci_ons_notification_topic.seguridad.id
  protocol       = "EMAIL"
  endpoint       = var.email_notificacion
  freeform_tags  = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  4. CLOUD GUARD — (requiere permisos de tenancy admin, se documenta aquí)
#     Para habilitar Cloud Guard:
#       oci_cloud_guard_cloud_guard_configuration + oci_cloud_guard_target
#       Requiere: manage cloud-guard-family in tenancy
# ═══════════════════════════════════════════════════════════════════════════════

# ═══════════════════════════════════════════════════════════════════════════════
#  5. LOGGING — Security Audit Log Group
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_logging_log_group" "security_logs" {
  compartment_id = var.compartment_ocid
  display_name   = "${local.prefijo}-log-group-security"
  description    = "Security and audit logs"
  freeform_tags  = local.tags_comunes
}

resource "oci_logging_log" "audit_log" {
  display_name = "${local.prefijo}-audit-log"
  log_group_id = oci_logging_log_group.security_logs.id
  log_type     = "CUSTOM"
  freeform_tags = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  6. EVENTS — Vault Key rotation + Cloud Guard problems
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_events_rule" "vault_events" {
  compartment_id = var.compartment_ocid
  display_name   = "${local.prefijo}-event-vault"
  description    = "Notificar eventos de Vault (creación/rotación de claves)"
  is_enabled     = true

  condition = jsonencode({
    eventType = [
      "com.oraclecloud.kms.createkey",
      "com.oraclecloud.kms.rotatekey",
      "com.oraclecloud.kms.disablekey",
      "com.oraclecloud.kms.schedulekeydeletion"
    ]
  })

  actions {
    actions {
      action_type = "ONS"
      is_enabled  = true
      topic_id    = oci_ons_notification_topic.seguridad.id
    }
  }

  freeform_tags = local.tags_comunes
}

resource "oci_events_rule" "cloud_guard_events" {
  compartment_id = var.compartment_ocid
  display_name   = "${local.prefijo}-event-cloudguard"
  description    = "Notificar problemas detectados por Cloud Guard"
  is_enabled     = true

  condition = jsonencode({
    eventType = [
      "com.oraclecloud.cloudguard.problemdetected"
    ]
  })

  actions {
    actions {
      action_type = "ONS"
      is_enabled  = true
      topic_id    = oci_ons_notification_topic.seguridad.id
    }
  }

  freeform_tags = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  7. MONITORING — Alarm para Vault
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_monitoring_alarm" "vault_operations" {
  compartment_id        = var.compartment_ocid
  display_name          = "${local.prefijo}-alarm-vault-ops"
  namespace             = "oci_vault"
  query                 = "ListKeys[1h]{resourceId = \"${oci_kms_vault.vault.id}\"}.count() > 0"
  severity              = "INFO"
  is_enabled            = true
  pending_duration      = "PT5M"
  body                  = "INFO: Operaciones detectadas en el Vault KMS."
  metric_compartment_id = var.compartment_ocid

  destinations = [oci_ons_notification_topic.seguridad.id]

  freeform_tags = local.tags_comunes
}
