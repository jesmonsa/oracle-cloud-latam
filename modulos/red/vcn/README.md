# Módulo VCN (Virtual Cloud Network)

Módulo base para crear una arquitectura de red en OCI siguiendo las mejores prácticas.

## Recursos creados
- Virtual Cloud Network (VCN)
- Internet Gateway (IGW)
- NAT Gateway (Opcional, habilitado por defecto)
- Service Gateway (SGW) (Opcional, habilitado por defecto)
- Route Table Pública (apunta a IGW)
- Route Table Privada (apunta a NAT y SGW)

## Ejemplo de uso

```hcl
module "red" {
  source         = "github.com/jesmonsa/oracle-cloud-latam//modulos/red/vcn"
  compartment_id = var.compartment_ocid
  vcn_cidr       = "10.0.0.0/16"
  proyecto       = "miapp"
  ambiente       = "produccion"
  tags           = local.tags_comunes
}
```
