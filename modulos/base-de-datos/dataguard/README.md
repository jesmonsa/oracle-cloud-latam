# Módulo OCI DataGuard Association

Este módulo configura un **DataGuard Association** y aprovisiona de forma automática un nuevo OCI DB System (Virtual Machine) dedicado como nodo en espera (Standby). Esta es la forma nativa de OCI de habilitar Disaster Recovery (DR) y Alta Disponibilidad de base de datos a nivel de sistema.

## Requisitos Previos
1. Contar con un DB System Primario. 
2. Para que la instanciación sea fluida, es necesario disponer de la contraseña inicial del administrador (`SYS`).

## Uso Básico

```hcl
module "base_de_datos_primaria" {
  source              = "./modulos/base-de-datos/dbsystem"
  # ... Configuración Primaria
}

module "dataguard_standby" {
  source              = "./modulos/base-de-datos/dataguard"
  primary_database_id = module.base_de_datos_primaria.database_id
  db_admin_password   = var.db_password
  
  # Debe aprovisionarse idealmente en otro Fault Domain, Availability Domain o incluso otra VCN Remota
  availability_domain = "XyZa:US-ASHBURN-AD-2" 
  subnet_id           = oci_core_subnet.db_standby_subnet.id
  shape               = var.shape
  
  proyecto            = "applatam"
  ambiente            = "produccion"
  
  protection_mode     = "MAXIMUM_PERFORMANCE"
}
```

> **NOTA:** La sincronización inicial (instanciación lógica y clonación de la BD) incrementará sustancialmente el tiempo del `terraform apply`. Puede demorar entre 50 a 100 minutos adicionales tras crear el `dbsystem` primario.
