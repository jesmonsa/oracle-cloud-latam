# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Locals - Valores calculados y tags comunes                                ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

locals {
  prefijo = "${var.proyecto}-${var.ambiente}"

  tags_comunes = {
    Proyecto      = var.proyecto
    Ambiente      = var.ambiente
    Propietario   = var.propietario
    Region        = var.region
    ManagedBy     = "Terraform"
    Repositorio   = "oracle-cloud-latam"
    Arquitectura  = "01-fundamentos-webserver"
    FechaCreacion = formatdate("YYYY-MM-DD", timestamp())
  }

  # Advertencia de seguridad: SSH abierto al mundo
  ssh_abierto_al_mundo = var.ssh_cidr_permitido == "0.0.0.0/0"
}
