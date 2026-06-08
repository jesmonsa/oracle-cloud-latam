# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Data Sources                                                               ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

data "oci_identity_availability_domains" "ad" {
  compartment_id = var.tenancy_ocid
}

data "oci_identity_fault_domains" "fd" {
  compartment_id      = var.tenancy_ocid
  availability_domain = data.oci_identity_availability_domains.ad.availability_domains[0].name
}

data "oci_core_images" "os_image" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.shape_webserver
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

data "oci_identity_tenancy" "tenant" {
  tenancy_id = var.tenancy_ocid
}
