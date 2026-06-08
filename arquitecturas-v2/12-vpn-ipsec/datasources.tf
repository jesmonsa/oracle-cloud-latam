# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Data Sources — Arquitectura 12: VPN IPSec                                 ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

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

# CPE Device Shapes — obtener lista de vendors disponibles
data "oci_core_cpe_device_shapes" "shapes" {
}
