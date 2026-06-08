# Módulo Remote Peering Connection

Crea DRGs y establece una conexión de peering remota (cross-region) entre dos VCNs ubicadas en regiones diferentes.

## Requisitos de Proveedor
Dado que actúa en dos regiones, requiere configurar el uso de dos proveedores al invocar este módulo en el `main.tf` de tu arquitectura.

## Ejemplo de uso
```hcl
module "rpc" {
  source           = "github.com/jesmonsa/oracle-cloud-latam//modulos/red/peering-remoto"
  compartment_id   = var.compartment_ocid
  vcn_id_region1   = module.red_region1.vcn_id
  vcn_id_region2   = module.red_region2.vcn_id
  region1          = var.region
  region2          = var.region_secundaria
  proyecto         = var.proyecto
  ambiente         = var.ambiente
  providers        = {
    oci.region1 = oci
    oci.region2 = oci.secundaria
  }
}
```
