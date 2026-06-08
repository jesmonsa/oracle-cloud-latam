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
    Modulo = "red-load-balancer"
  })
}

resource "oci_load_balancer_load_balancer" "lb" {
  compartment_id = var.compartment_id
  display_name   = "${local.prefijo}-lb"
  shape          = var.shape
  subnet_ids     = [var.subnet_id]

  dynamic "shape_details" {
    for_each = var.shape == "flexible" ? [1] : []
    content {
      minimum_bandwidth_in_mbps = var.bandwidth_min_mbps
      maximum_bandwidth_in_mbps = var.bandwidth_max_mbps
    }
  }

  is_private                 = false
  network_security_group_ids = var.nsg_ids
  freeform_tags              = local.tags_comunes
}

resource "oci_load_balancer_backend_set" "bset" {
  load_balancer_id = oci_load_balancer_load_balancer.lb.id
  name             = "${local.prefijo}-bset"
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = var.puerto_backend
    protocol            = var.protocolo
    response_body_regex = ".*"
    url_path            = "/"
    return_code         = 200
  }
}

resource "oci_load_balancer_backend" "backend" {
  count            = length(var.backend_ips)
  load_balancer_id = oci_load_balancer_load_balancer.lb.id
  backendset_name  = oci_load_balancer_backend_set.bset.name
  ip_address       = var.backend_ips[count.index]
  port             = var.puerto_backend
}

resource "oci_load_balancer_listener" "listener" {
  load_balancer_id         = oci_load_balancer_load_balancer.lb.id
  name                     = "${local.prefijo}-listener"
  default_backend_set_name = oci_load_balancer_backend_set.bset.name
  port                     = var.puerto_listener
  protocol                 = var.protocolo

  dynamic "connection_configuration" {
    for_each = var.protocolo == "HTTP" ? [1] : []
    content {
      idle_timeout_in_seconds = "60"
    }
  }
}

