# TODO: Implementar GoldenGate
# - oci_core_instance: VM para GoldenGate
# - oci_core_network_security_group: NSG para puertos GG
# - oci_core_volume: Storage para trail files
# - oci_monitoring_alarm: Alertas para replicación

locals {
  display_name = "${var.project_name}-${var.instance_name}-${var.environment}"
}
