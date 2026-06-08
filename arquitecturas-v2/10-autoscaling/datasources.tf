# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Data Sources — Arquitectura 10: Autoscaling                               ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_identity_fault_domains" "fds" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
}

data "oci_core_images" "ol8" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.shape_webserver
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.tenancy_ocid
}
