# Módulo Network Security Groups (NSG)

Este módulo consolida las reglas de seguridad recomendadas en OCI para diferentes perfiles.

## Ejemplo de uso
```hcl
module "nsgs" {
  source             = "github.com/jesmonsa/oracle-cloud-latam//modulos/seguridad/nsg"
  compartment_id     = var.compartment_ocid
  vcn_id             = module.red.vcn_id
  proyecto           = var.proyecto
  ambiente           = var.ambiente
  habilitar_nsg_web  = true
  habilitar_nsg_ssh  = true
  cidr_ssh_permitido = var.ssh_cidr_permitido
}
```
