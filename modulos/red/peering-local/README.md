# Módulo Local Peering Gateway

Establece una conexión LPG entre dos VCNs ubicadas en la misma región.

## Ejemplo de uso
```hcl
module "lpg" {
  source              = "github.com/jesmonsa/oracle-cloud-latam//modulos/red/peering-local"
  compartment_id_vcn1 = var.compartment_ocid
  compartment_id_vcn2 = var.compartment_ocid
  vcn_id_1            = module.red_1.vcn_id
  vcn_id_2            = module.red_2.vcn_id
  proyecto            = var.proyecto
  ambiente            = var.ambiente
}
```
