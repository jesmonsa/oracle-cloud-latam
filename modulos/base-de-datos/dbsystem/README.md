# Módulo OCI DB System

Este módulo despliega un Oracle Cloud Infrastructure (OCI) DB System virtual machine. Por defecto se configura utilizando un modelo de licencia incluyente (`LICENSE_INCLUDED`), edición Standard (`STANDARD_EDITION`), y redundancia normal en el almacenamiento de bloque adjunto.

## Uso Básico

```hcl
module "base_de_datos" {
  source              = "./modulos/base-de-datos/dbsystem"
  compartment_id      = var.compartment_ocid
  availability_domain = "XyZa:US-ASHBURN-AD-1"
  subnet_id           = oci_core_subnet.db_subnet.id
  proyecto            = "applatam"
  ambiente            = "produccion"
  
  db_admin_password   = "MiContrasenaYSegura123#!"
  db_name             = "APPLDB"
  ssh_public_keys     = ["ssh-rsa AAAA..."]
  
  timezone            = "America/Bogota"
}
```

> **NOTA:** El despliegue de un OCI DB System (Virtual Machine) normalmente toma entre 45 y 90 minutos para completar todas las operaciones de inicialización, instanciación del OS, Grid Infrastructure, y RDBMS. Dependerá de la región y recursos asignados.
