terraform {
  required_version = ">= 1.0.0"
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}


resource "oci_database_data_guard_association" "db_standby" {
  creation_type                    = "NewDbSystem"
  database_id                      = var.primary_database_id
  database_admin_password          = var.db_admin_password
  protection_mode                  = var.protection_mode
  transport_type                   = var.transport_type
  delete_standby_db_home_on_delete = var.delete_standby_db_home_on_delete

  availability_domain = var.availability_domain
  subnet_id           = var.subnet_id
  shape               = var.shape
  # cpu_core_count: define las OCPUs. La RAM la asigna OCI automáticamente (no es configurable en Data Guard).
  cpu_core_count      = var.cpu_core_count
  nsg_ids             = var.nsg_ids
  display_name        = "${var.proyecto}-${var.ambiente}-dbstandby"
  hostname            = "${var.proyecto}stby"
}
