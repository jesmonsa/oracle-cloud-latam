# Módulo OCI Bastion Service

Reemplaza al bastion host VM del curso original. Es serverless, más seguro, sin mantenimiento
y con coste de cómputo nulo para sesiones SSH a servidores privados.

## Ejemplo de conexión por SSH (Session)

Después de desplegar, puedes crear una sesión gestionada por OCI CLI:

```bash
oci bastion session create-managed-ssh \
  --bastion-id <bastion_id> \
  --target-resource-id <instance_ocid> \
  --target-os-username opc \
  --session-ttl 3600
```
