# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Outputs — Arquitectura 14: API Gateway                                    ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

output "apigw_hostname" {
  description = "Hostname del API Gateway"
  value       = oci_apigateway_gateway.apigw.hostname
}

output "api_base_url" {
  description = "URL base de la API"
  value       = "${oci_apigateway_gateway.apigw.hostname}/v1"
}

output "api_health_url" {
  value = "${oci_apigateway_gateway.apigw.hostname}/v1/health"
}

output "api_info_url" {
  value = "${oci_apigateway_gateway.apigw.hostname}/v1/info"
}

output "api_stock_url" {
  value = "${oci_apigateway_gateway.apigw.hostname}/v1/stock"
}

output "functions_app_id" {
  description = "OCID de la Functions Application"
  value       = oci_functions_application.fn_app.id
}

output "webserver_ip" {
  value = module.webserver.ips_privadas[0]
}

output "resumen" {
  value = <<-EOT

  ╔══════════════════════════════════════════════════════════════╗
  ║  Arquitectura 14 — API Gateway + Functions                 ║
  ╠══════════════════════════════════════════════════════════════╣
  ║                                                            ║
  ║  API Gateway:    ${oci_apigateway_gateway.apigw.hostname}
  ║                                                            ║
  ║  Rutas:                                                    ║
  ║    GET /v1/health  → Health check                          ║
  ║    GET /v1/info    → Server info (JSON)                    ║
  ║    GET /v1/stock   → Inventory mock                        ║
  ║    GET /v1/        → Página principal                      ║
  ║                                                            ║
  ║  Backend:        ${module.webserver.ips_privadas[0]} (privado)
  ║  Functions App:  ${local.prefijo}-functions-app
  ║  Bastion:        ${local.prefijo}-bastion
  ╚══════════════════════════════════════════════════════════════╝

  EOT
}
