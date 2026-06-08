# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Data Sources - Consultas dinámicas a OCI                                  ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# Availability Domains disponibles en la región
data "oci_identity_availability_domains" "ad" {
  compartment_id = var.tenancy_ocid
}

# Última imagen de Oracle Linux 8 compatible con el shape seleccionado
data "oci_core_images" "os_image" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.shape_webserver
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# Información del tenancy (para namespace de Object Storage, etc.)
data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.tenancy_ocid
}
