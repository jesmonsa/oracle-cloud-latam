# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  11 - WAF + DNS Zone — Protección L7 y DNS Público                         ║
# ║                                                                            ║
# ║  Topología:                                                                ║
# ║                                                                            ║
# ║    Internet ──► WAF Policy ──► LB Público ──► Webserver (privado)          ║
# ║                    │                                                       ║
# ║                    ├─ Protección XSS                                       ║
# ║                    ├─ Protección SQL Injection                             ║
# ║                    └─ Request Rate Limiting                                ║
# ║                                                                            ║
# ║    DNS Zone: ejemplo-dominio.com                                             ║
# ║      ├─ A Record: app → LB IP                                             ║
# ║      └─ NS Records (auto-generados)                                       ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ═══════════════════════════════════════════════════════════════════════════════
#  1. RED — VCN + Subnets
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
    description = "Permitir todo tráfico de salida"
  }

  freeform_tags = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  2. SEGURIDAD — NSGs
# ═══════════════════════════════════════════════════════════════════════════════

module "nsgs" {
  count  = var.habilitar_nsg ? 1 : 0
  source = "../../modulos/seguridad/nsg"

  compartment_id     = var.compartment_ocid
  vcn_id             = module.red.vcn_id
  proyecto           = var.proyecto
  ambiente           = var.ambiente
  habilitar_nsg_web  = true
  habilitar_nsg_ssh  = true
  habilitar_nsg_db   = false
  habilitar_nsg_nfs  = false
  cidr_ssh_permitido = var.ssh_cidr_permitido
  cidr_red_interna   = [var.vcn_cidr]
  tags               = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  3. SUBNETS
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
#  4. WEBSERVER
# ═══════════════════════════════════════════════════════════════════════════════

module "webserver" {
  source = "../../modulos/computo/webserver"

  compartment_id = var.compartment_ocid
  proyecto       = var.proyecto
  ambiente       = var.ambiente
  cantidad       = 1
  subnet_id      = oci_core_subnet.privada.id
  imagen_os      = local.imagen_id
  shape          = var.shape_webserver
  ocpus          = var.ocpus_webserver
  memoria_gb     = var.memoria_webserver_gb
  ssh_public_key = var.ssh_public_key
  nsg_ids        = var.habilitar_nsg ? module.nsgs[0].todos_nsg_ids : []
  userdata_extra = local.userdata_extra
  tags           = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  5. LOAD BALANCER
# ═══════════════════════════════════════════════════════════════════════════════

module "load_balancer" {
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
#  6. WAF POLICY (Web Application Firewall)
# ═══════════════════════════════════════════════════════════════════════════════

# WAF Policy asociada al Load Balancer (protección L7)
resource "oci_waf_web_app_firewall_policy" "waf_policy" {
  compartment_id = var.compartment_ocid
  display_name   = "${local.prefijo}-waf-policy"
  freeform_tags  = local.tags_comunes

  # ─── Protección contra XSS ──────────────────────────────────────────────
  request_protection {
    rules {
      name        = "xss-protection"
      type        = "PROTECTION"
      action_name = "check_action"
      condition   = "i_contains(keys(http.request.headers), 'x-custom-test')"

      protection_capabilities {
        key     = "941110"
        version = 2
      }
    }
  }

  # ─── Rate Limiting ──────────────────────────────────────────────────────
  request_rate_limiting {
    rules {
      name        = "rate-limit-rule"
      type        = "REQUEST_RATE_LIMITING"
      action_name = "check_action"

      configurations {
        period_in_seconds          = 60
        requests_limit             = 100
        action_duration_in_seconds = 300
      }
    }
  }

  # ─── Acciones ───────────────────────────────────────────────────────────
  actions {
    name = "check_action"
    type = "CHECK"
  }

  actions {
    name = "block_action"
    type = "RETURN_HTTP_RESPONSE"
    body {
      type = "STATIC_TEXT"
      text = "Blocked by OCI WAF"
    }
    code = 403
    headers {
      name  = "X-Blocked-By"
      value = "OCI-WAF"
    }
  }
}

# WAF asociado al Load Balancer
resource "oci_waf_web_app_firewall" "waf" {
  compartment_id             = var.compartment_ocid
  display_name               = "${local.prefijo}-waf"
  backend_type               = "LOAD_BALANCER"
  load_balancer_id           = module.load_balancer.load_balancer_id
  web_app_firewall_policy_id = oci_waf_web_app_firewall_policy.waf_policy.id
  freeform_tags              = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  7. DNS ZONE + RECORDS
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_dns_zone" "zona" {
  compartment_id = var.compartment_ocid
  name           = var.dns_zone_name
  zone_type      = "PRIMARY"
  freeform_tags  = local.tags_comunes
}

# Record A: app.ejemplo-dominio.com → LB IP
resource "oci_dns_rrset" "app_record" {
  zone_name_or_id = oci_dns_zone.zona.id
  domain          = "app.${var.dns_zone_name}"
  rtype           = "A"
  compartment_id  = var.compartment_ocid

  items {
    domain = "app.${var.dns_zone_name}"
    rtype  = "A"
    rdata  = module.load_balancer.ip_publica
    ttl    = 300
  }
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
