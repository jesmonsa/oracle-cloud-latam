# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  14 - API Gateway — Exposición de APIs con backend HTTP                    ║
# ║                                                                            ║
# ║  Topología:                                                                ║
# ║                                                                            ║
# ║    Internet ──► API Gateway ──► /api/health  → Backend HTTP (webserver)    ║
# ║                    │          ──► /api/info   → Backend HTTP               ║
# ║                    │          ──► /api/stock  → Stock Response (mock)      ║
# ║                Subnet Pública                                              ║
# ║                                                                            ║
# ║    Functions Application (infraestructura creada, sin función desplegada)  ║
# ║                                                                            ║
# ║  El API Gateway expone rutas que dirigen a un webserver backend.           ║
# ║  También crea una Functions Application lista para alojar funciones.       ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

locals {
  prefijo = "${var.proyecto}-${var.ambiente}"
  tags_comunes = {
    Proyecto     = var.proyecto
    Ambiente     = var.ambiente
    Propietario  = var.propietario
    Arquitectura = "14-api-gateway"
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

# Security list para API Gateway (necesita ingress HTTPS)
resource "oci_core_security_list" "sl_apigw" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.red.vcn_id
  display_name   = "${local.prefijo}-sl-apigw"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
  }

  ingress_security_rules {
    source    = "0.0.0.0/0"
    protocol  = "6"
    stateless = false
    tcp_options {
      min = 443
      max = 443
    }
  }

  ingress_security_rules {
    source    = "0.0.0.0/0"
    protocol  = "6"
    stateless = false
    tcp_options {
      min = 80
      max = 80
    }
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
  security_list_ids          = [oci_core_security_list.sl_apigw.id]
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
#  3. WEBSERVER (backend para API Gateway)
# ═══════════════════════════════════════════════════════════════════════════════

module "webserver" {
  source = "../../modulos/computo/webserver"

  compartment_id = var.compartment_ocid
  proyecto       = var.proyecto
  ambiente       = var.ambiente
  cantidad       = 1
  subnet_id      = oci_core_subnet.privada.id
  imagen_os      = data.oci_core_images.ol8.images[0].id
  shape          = var.shape_webserver
  ocpus          = var.ocpus_webserver
  memoria_gb     = var.memoria_webserver_gb
  ssh_public_key = var.ssh_public_key
  nsg_ids        = var.habilitar_nsg ? module.nsgs[0].todos_nsg_ids : []
  tags           = local.tags_comunes

  userdata_extra = <<-EXTRA
# ─── Arquitectura 14: API endpoints simulados ────────────────────────────────
mkdir -p /var/www/html/api
cat > /var/www/html/api/health << 'APIJSON'
{"status":"healthy","service":"api-gateway-backend","timestamp":"$(date -u +%Y-%m-%dT%H:%M:%SZ)","arch":"14-api-gateway"}
APIJSON
cat > /var/www/html/api/info << 'APIJSON'
{"hostname":"$(hostname)","ip":"$(hostname -I | awk '{print $1}')","region":"us-ashburn-1","version":"1.0.0","managed_by":"terraform"}
APIJSON
cat > /var/www/html/api/stock << 'APIJSON'
{"items":[{"id":1,"name":"Widget A","qty":142},{"id":2,"name":"Widget B","qty":58},{"id":3,"name":"Gadget C","qty":301}],"total":3}
APIJSON
cat > /var/www/html/index.html << 'HTMLPAGE'
<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"><title>API Gateway Backend</title>
<style>body{font-family:'Segoe UI',sans-serif;background:#0d1117;color:#c9d1d9;display:flex;justify-content:center;align-items:center;min-height:100vh;margin:0}.card{background:#161b22;border-radius:16px;padding:2.5rem;max-width:560px;box-shadow:0 10px 40px rgba(0,0,0,.4);border:1px solid #30363d}h1{color:#58a6ff;margin-top:0;font-size:1.5rem}.badge{display:inline-block;background:#238636;color:#fff;padding:3px 12px;border-radius:12px;font-size:.75rem;font-weight:700;margin-left:8px}.info{margin:.5rem 0;padding:.5rem 0;border-bottom:1px solid #21262d}.label{color:#8b949e;font-size:.85rem}.value{color:#f0f6fc;font-weight:600}.routes{background:#0d1117;border-radius:10px;padding:1rem;margin-top:1rem;border:1px solid #30363d}.routes h3{color:#58a6ff;margin:0 0 .5rem;font-size:.95rem}.route{font-family:monospace;color:#7ee787;margin:.3rem 0}.footer{margin-top:1.5rem;font-size:.78rem;color:#484f58;text-align:center}</style></head>
<body><div class="card"><h1>Arquitectura 14 <span class="badge">API GW</span></h1>
<div class="info"><span class="label">Backend Server</span><br><span class="value">__HOSTNAME__</span></div>
<div class="info"><span class="label">IP Privada</span><br><span class="value">__IP__</span></div>
<div class="routes"><h3>API Routes</h3>
<div class="route">GET /api/health → Health check</div>
<div class="route">GET /api/info   → Server info (JSON)</div>
<div class="route">GET /api/stock  → Inventory mock (JSON)</div></div>
<div class="footer">API Gateway + Functions App | oracle-cloud-latam</div></div></body></html>
HTMLPAGE
HOSTNAME_A=$(hostname)
IP_A=$(hostname -I | awk '{print $1}')
sed -i "s/__HOSTNAME__/$HOSTNAME_A/g" /var/www/html/index.html
sed -i "s/__IP__/$IP_A/g" /var/www/html/index.html
EXTRA
}

# ═══════════════════════════════════════════════════════════════════════════════
#  4. API GATEWAY
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_apigateway_gateway" "apigw" {
  compartment_id = var.compartment_ocid
  endpoint_type  = "PUBLIC"
  subnet_id      = oci_core_subnet.publica.id
  display_name   = "${local.prefijo}-apigw"
  freeform_tags  = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  5. API DEPLOYMENT (rutas)
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_apigateway_deployment" "api" {
  compartment_id = var.compartment_ocid
  gateway_id     = oci_apigateway_gateway.apigw.id
  path_prefix    = "/v1"
  display_name   = "${local.prefijo}-api-v1"
  freeform_tags  = local.tags_comunes

  specification {
    routes {
      path    = "/health"
      methods = ["GET"]
      backend {
        type = "HTTP_BACKEND"
        url  = "http://${module.webserver.ips_privadas[0]}/api/health"
      }
    }

    routes {
      path    = "/info"
      methods = ["GET"]
      backend {
        type = "HTTP_BACKEND"
        url  = "http://${module.webserver.ips_privadas[0]}/api/info"
      }
    }

    routes {
      path    = "/stock"
      methods = ["GET"]
      backend {
        type = "HTTP_BACKEND"
        url  = "http://${module.webserver.ips_privadas[0]}/api/stock"
      }
    }

    routes {
      path    = "/"
      methods = ["GET"]
      backend {
        type = "HTTP_BACKEND"
        url  = "http://${module.webserver.ips_privadas[0]}/"
      }
    }
  }
}

# ═══════════════════════════════════════════════════════════════════════════════
#  6. FUNCTIONS APPLICATION (infraestructura lista)
# ═══════════════════════════════════════════════════════════════════════════════

resource "oci_functions_application" "fn_app" {
  compartment_id = var.compartment_ocid
  display_name   = "${local.prefijo}-functions-app"
  subnet_ids     = [oci_core_subnet.privada.id]
  freeform_tags  = local.tags_comunes
}

# ═══════════════════════════════════════════════════════════════════════════════
#  7. BASTION
# ═══════════════════════════════════════════════════════════════════════════════

module "bastion" {
  source = "../../modulos/red/bastion-service"

  compartment_id = var.compartment_ocid
  subnet_id      = oci_core_subnet.privada.id
  proyecto       = var.proyecto
  ambiente       = var.ambiente
  tags           = local.tags_comunes
}
