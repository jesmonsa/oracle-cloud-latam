# Módulo Block Volume

Crea un Block Volume iSCSI y lo adjunta a una instancia específica. Contiene un script para montarlo automáticamente.

## Ejemplo de uso
```hcl
module "block_volume" {
  source              = "github.com/jesmonsa/oracle-cloud-latam//modulos/almacenamiento/block-volume"
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ad.availability_domains[0].name
  instancia_id        = module.webserver.instancia_ids[0]
  proyecto            = var.proyecto
  ambiente            = var.ambiente
  tamano_gb           = 100
  punto_montaje       = "/u01"
}
```
