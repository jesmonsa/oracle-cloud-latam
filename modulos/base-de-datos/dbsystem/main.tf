terraform {
  required_version = ">= 1.0.0"
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}


resource "oci_database_db_system" "db_system" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id

  # cpu_core_count: define las OCPUs. En shapes Flex OCI acepta el valor indicado.
  # En x9-15 OCI ignora este valor y fija 15 OCPUs automáticamente.
  # Nota: la RAM en oci_database_db_system es de solo lectura (memory_size_in_gbs); OCI la asigna según shape y OCPUs.
  cpu_core_count   = var.cpu_core_count
  database_edition = var.database_edition

  db_home {
    database {
      admin_password = var.db_admin_password
      db_name        = var.db_name
      character_set  = "AL32UTF8"
      ncharacter_set = "AL16UTF16"
      db_workload    = "OLTP"
      pdb_name       = "${var.db_name}PDB"
    }
    db_version   = var.db_version
    display_name = "${var.proyecto}-${var.ambiente}-dbhome"
  }

  disk_redundancy         = "NORMAL"
  shape                   = var.shape
  subnet_id               = var.subnet_id
  ssh_public_keys         = var.ssh_public_keys
  display_name            = "${var.proyecto}-${var.ambiente}-dbsystem"
  hostname                = "${var.proyecto}db"
  data_storage_percentage = "40"
  data_storage_size_in_gb = var.data_storage_size_in_gb
  license_model           = var.license_model
  node_count              = var.node_count
  nsg_ids                 = var.nsg_ids
  time_zone               = var.timezone

  db_system_options {
    storage_management = "ASM"
  }

  freeform_tags = var.tags
}
