# TODO: Implementar Data Integration Workspace y Pipelines
# - oci_dataintegration_workspace
# - oci_dataintegration_task
# - oci_dataintegration_pipeline

locals {
  display_name = "${var.project_name}-${var.workspace_name}-${var.environment}"
}
