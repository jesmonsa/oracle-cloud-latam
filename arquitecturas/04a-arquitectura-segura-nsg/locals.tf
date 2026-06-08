locals {
  tags_comunes = {
    Proyecto    = var.proyecto
    Ambiente    = var.ambiente
    Propietario = var.propietario
    Region      = var.region
    ManagedBy   = "Terraform"
    Repositorio = "oracle-cloud-latam"
  }
}
