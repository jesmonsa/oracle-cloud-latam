# Módulo Webserver

Despliega instancias de cómputo configuradas como servidores web (Apache instalado por userdata).

## Ejemplo de uso
```hcl
module "webserver" {
  source             = "github.com/jesmonsa/oracle-cloud-latam//modulos/computo/webserver"
  compartment_id     = var.compartment_ocid
  subnet_id          = oci_core_subnet.publica.id
  ssh_public_key     = var.ssh_public_key
  proyecto           = var.proyecto
  ambiente           = var.ambiente
  shape              = "VM.Standard.E4.Flex"
  ocpus              = 1
  memoria_gb         = 8
  asignar_ip_publica = true
  cantidad           = 1
  imagen_os          = data.oci_core_images.os.images[0].id
  nsg_ids            = module.nsgs.todos_nsg_ids
}
```
