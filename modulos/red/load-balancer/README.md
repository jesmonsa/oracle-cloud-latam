# Módulo Load Balancer

Crea un Public Load Balancer flexible, configurando su Backend Set y Listeners.

## Ejemplo de uso
```hcl
module "load_balancer" {
  source         = "github.com/jesmonsa/oracle-cloud-latam//modulos/red/load-balancer"
  compartment_id = var.compartment_ocid
  subnet_id      = module.red.subnet_publica_id
  backend_ips    = module.webserver.ips_privadas
  proyecto       = var.proyecto
  ambiente       = var.ambiente
}
```
