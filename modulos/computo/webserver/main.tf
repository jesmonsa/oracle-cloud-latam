terraform {
  required_version = ">= 1.0.0"
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

locals {
  prefijo = "${var.proyecto}-${var.ambiente}"
  tags_comunes = merge(var.tags, {
    Modulo = "computo-webserver"
  })

  # Si hay userdata_extra, insertarlo ANTES del exit 0 final del script base.
  # El userdata.sh termina con "exit 0" que impediría la ejecución del extra si se concatenara al final.
  userdata_base = file("${path.module}/userdata.sh")
  userdata = var.userdata_extra != "" ? replace(
    local.userdata_base,
    "# Siempre exit 0 para que cloud-init no marque error total\nexit 0",
    "${var.userdata_extra}\n\n# Siempre exit 0 para que cloud-init no marque error total\nexit 0"
  ) : local.userdata_base

  # Shapes que requieren shape_config (Flex y equivalentes con RAM configurable).
  # Los shapes X9 tienen CPU/RAM fija y NO aceptan shape_config.
  shapes_flex = toset([
    "VM.Standard.E4.Flex",
    "VM.Standard.E5.Flex",
    "VM.Standard.E6.Flex",
    "VM.Standard.A1.Flex",
    "VM.Standard3.Flex",
    "VM.Optimized3.Flex",
  ])

  es_flex = contains(local.shapes_flex, var.shape)
}

data "oci_identity_availability_domains" "ad" {
  compartment_id = var.compartment_id
}

resource "oci_core_instance" "web" {
  count = var.cantidad

  availability_domain = var.availability_domain != null ? var.availability_domain : data.oci_identity_availability_domains.ad.availability_domains[count.index % length(data.oci_identity_availability_domains.ad.availability_domains)].name
  fault_domain        = var.fault_domain
  compartment_id      = var.compartment_id
  display_name        = "${local.prefijo}-web-${count.index + 1}"
  shape               = var.shape

  # shape_config solo para shapes Flex; los X9 tienen configuración de hardware fija.
  dynamic "shape_config" {
    for_each = local.es_flex ? [1] : []
    content {
      ocpus         = var.ocpus
      memory_in_gbs = var.memoria_gb
    }
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    display_name     = "vnic-web-${count.index + 1}"
    assign_public_ip = var.asignar_ip_publica
    nsg_ids          = var.nsg_ids
    freeform_tags    = local.tags_comunes
  }

  source_details {
    source_type             = "image"
    source_id               = var.imagen_os
    boot_volume_size_in_gbs = var.boot_volume_gb
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(local.userdata)
  }

  freeform_tags = local.tags_comunes
}
