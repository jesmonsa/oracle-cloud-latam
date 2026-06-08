# Arquitectura 02: Alta Disponibilidad Multi-AD

Arquitectura de referencia para desplegar una infraestructura de **alta disponibilidad** en Oracle Cloud Infrastructure (OCI), distribuida across **múltiples dominios de disponibilidad (Availability Domains)** o **dominios de fallos (Fault Domains)** para garantizar continuidad operativa.

---

## Despliegue Rápido

[![Deploy to OCI](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-02-alta-disponibilidad-multi-ad.zip)

---

## Topología de Arquitectura

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                    ARQUITECTURA: ALTA DISPONIBILIDAD MULTI-AD                ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

---

## Recursos Desplegados

| Recurso | Descripción | Tipo OCI | Cantidad |
|---------|-------------|----------|----------|
| **VCN** | Red privada aislada | `oci_core_vcn` | 1 |
| **Subnet Pública (AD1)** | Subnet en Availability Domain 1 | `oci_core_subnet` | 1 |
| **Subnet Pública (AD2)** | Subnet en Availability Domain 2 | `oci_core_subnet` | 1 |
| **Internet Gateway** | Puerta de entrada a Internet | `oci_core_internet_gateway` | 1 |
| **Instancia Webserver AD1** | Servidor web con Apache | `oci_core_instance` | 1 |
| **Instancia Webserver AD2** | Servidor web con Apache | `oci_core_instance` | 1 |

---

**Autor:** jesmonsa | **Versión:** 2.0.0
