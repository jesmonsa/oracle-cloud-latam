# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Locals - Valores calculados y tags                                         ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

locals {
  prefijo = "${var.proyecto}-${var.ambiente}"

  tags_comunes = {
    Proyecto      = var.proyecto
    Ambiente      = var.ambiente
    Propietario   = var.propietario
    Arquitectura  = "03-load-balancer-ha"
    Gestionado    = "terraform"
    FechaCreacion = formatdate("YYYY-MM-DD", timestamp())
  }

  # Detectar si la región tiene múltiples ADs o solo uno
  es_multi_ad = length(data.oci_identity_availability_domains.ad.availability_domains) > 1

  # AD para instancia 2: si hay múltiples ADs, usar AD2; si no, usar AD1 con Fault Domain diferente
  ad_instancia_1 = data.oci_identity_availability_domains.ad.availability_domains[0].name
  ad_instancia_2 = local.es_multi_ad ? data.oci_identity_availability_domains.ad.availability_domains[1].name : data.oci_identity_availability_domains.ad.availability_domains[0].name

  # Fault Domains para regiones de un solo AD
  fd_instancia_1 = "FAULT-DOMAIN-1"
  fd_instancia_2 = local.es_multi_ad ? "FAULT-DOMAIN-1" : "FAULT-DOMAIN-2"

  ssh_abierto_al_mundo = var.ssh_cidr_permitido == "0.0.0.0/0"

  # IPs privadas de los backends para el Load Balancer
  backend_private_ips = [
    module.webserver_ad1.ips_privadas[0],
    module.webserver_ad2.ips_privadas[0]
  ]
}
