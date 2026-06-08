# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Data Sources                                                               ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ─── Availability Domains disponibles en la región ───────────────────────────
data "oci_identity_availability_domains" "ad" {
  compartment_id = var.tenancy_ocid
}

# ─── Última imagen de Oracle Linux 8 ──────────────────────────────────────────
data "oci_core_images" "os_image" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.shape_webserver
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"

  filter {
    name   = "display_name"
    values = ["^Oracle-Linux-8\\.\\d+-\\d{4}\\.\\d{2}\\.\\d{2}-\\d+$"]
    regex  = true
  }
}

# ─── Información del Tenancy ─────────────────────────────────────────────────
data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.tenancy_ocid
}
