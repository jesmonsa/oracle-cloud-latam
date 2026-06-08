# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Locals - Valores calculados y tags                                         ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

locals {
  prefijo = "${var.proyecto}-${var.ambiente}"

  tags_comunes = {
    Proyecto      = var.proyecto
    Ambiente      = var.ambiente
    Propietario   = var.propietario
    Arquitectura  = "04-bastion-privado"
    Gestionado    = "terraform"
    FechaCreacion = formatdate("YYYY-MM-DD", timestamp())
  }

  # Detectar si la región tiene múltiples ADs o solo uno
  es_multi_ad = length(data.oci_identity_availability_domains.ad.availability_domains) > 1

  ad_instancia_1 = data.oci_identity_availability_domains.ad.availability_domains[0].name
  ad_instancia_2 = local.es_multi_ad ? data.oci_identity_availability_domains.ad.availability_domains[1].name : data.oci_identity_availability_domains.ad.availability_domains[0].name

  fd_instancia_1 = "FAULT-DOMAIN-1"
  fd_instancia_2 = local.es_multi_ad ? "FAULT-DOMAIN-1" : "FAULT-DOMAIN-2"

  # IPs privadas de los backends para el Load Balancer
  backend_private_ips = [
    module.webserver_ad1.ips_privadas[0],
    module.webserver_ad2.ips_privadas[0]
  ]
}
