# Módulo OCI File Storage Service (FSS)

Despliega un almacenamiento NFS gestionado (FSS) junto a su Mount Target y Export options.

## Ejemplo de uso
```hcl
module "fss" {
  source              = "github.com/jesmonsa/oracle-cloud-latam//modulos/almacenamiento/filesystem-compartido"
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ad.availability_domains[0].name
  subnet_id           = module.red.subnet_privada_id
  proyecto            = var.proyecto
  ambiente            = var.ambiente
  ruta_exportacion    = "/shared"
  cidr_permitido      = "10.0.0.0/16"
}
```
