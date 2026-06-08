# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Data Sources — Región 1 (Hub) + Región 2 (Spoke)                         ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ─── Región 1 ─────────────────────────────────────────────────────────────
data "oci_identity_availability_domains" "ads_r1" {
  provider       = oci.region1
  compartment_id = var.tenancy_ocid
}

data "oci_identity_fault_domains" "fds_r1" {
  provider            = oci.region1
  availability_domain = data.oci_identity_availability_domains.ads_r1.availability_domains[0].name
  compartment_id      = var.compartment_ocid
}

data "oci_core_images" "ol8_r1" {
  provider                 = oci.region1
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.shape_webserver
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

data "oci_identity_tenancy" "tenancy" {
  provider   = oci.region1
  tenancy_id = var.tenancy_ocid
}

# ─── Región 2 ─────────────────────────────────────────────────────────────
data "oci_identity_availability_domains" "ads_r2" {
  provider       = oci.region2
  compartment_id = var.tenancy_ocid
}

data "oci_identity_fault_domains" "fds_r2" {
  provider            = oci.region2
  availability_domain = data.oci_identity_availability_domains.ads_r2.availability_domains[0].name
  compartment_id      = var.compartment_ocid
}

data "oci_core_images" "ol8_r2" {
  provider                 = oci.region2
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.shape_webserver
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}
