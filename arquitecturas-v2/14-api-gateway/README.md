# 14 - API Gateway: Exposición de APIs con Backend HTTP

Arquitectura empresarial que despliega **API Gateway** en Oracle Cloud Infrastructure para exponer y gestionar APIs con enrutamiento inteligente hacia backends HTTP. Esta arquitectura incluye un webserver backend en subred privada, una Functions Application lista para alojar funciones serverless, y rutas de ejemplo que demuestran patrones de integración.

[![Deploy to OCI](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-14-api-gateway.zip)

## Descripción General

API Gateway proporciona una única entrada controlada para múltiples APIs, permitiendo:

- **Enrutamiento inteligente**: Diferentes rutas dirigidas a diferentes backends
- **Autenticación centralizada**: Control de acceso desde un punto único
- **Rate limiting y throttling**: Protección contra abuso
- **Transformación de solicitudes/respuestas**: Manipulación de headers y payloads
- **Functions Integration**: Conexión con Oracle Functions para lógica serverless
- **Monitoreo centralizado**: Métricas y logs en un solo lugar

## Arquitectura

```
                       Internet
                          │
                          ▼
              ┌────────────────────────────┐
              │     API Gateway            │
              │  (IP Pública)              │
              │  10.0.0.0/24 (Pública)     │
              └─────────┬────────┬─────────┘
                        │        │
          ┌─────────────┤        │
          │             │        │
    ┌─────▼──┐   ┌──────▼──┐  ┌─▼──────────────┐
    │/api/    │   │Functions│  │ Stock Response │
    │health   │   │Application│ │(Mock/Static)  │
    │/api/    │   │(Ready)   │ └────────────────┘
    │info     │   └──────────┘
    └────┬────┘
         │
         ▼
    ┌─────────────────────────────┐
    │  Webserver Backend          │
    │  (Subnet Privada)           │
    │  10.0.1.0/24                │
    │  Oracle Linux 8             │
    │  Apache HTTP                │
    └─────────────────────────────┘
```

## Recursos Desplegados

| Recurso | Descripción | Tipo OCI |
|---------|-------------|----------|
| **VCN** | Red Virtual Cloud con CIDR 10.0.0.0/16 | oci_core_vcn |
| **Subnet Pública** | Subred 10.0.0.0/24 para API Gateway | oci_core_subnet |
| **Subnet Privada** | Subred 10.0.1.0/24 para backend | oci_core_subnet |
| **API Gateway** | Punto de entrada centralizado | oci_apigateway_gateway |
| **API Deployment** | Rutas y backends configurados | oci_apigateway_deployment |
| **Functions Application** | Contenedor para funciones serverless | oci_functions_application |
| **Webserver (Compute)** | VM con Apache HTTP | oci_core_instance |
| **NSG (Web)** | Firewall para tráfico HTTP/HTTPS | oci_core_network_security_group |
| **NSG (SSH)** | Firewall para acceso SSH | oci_core_network_security_group |

## Variables Principales

| Variable | Descripción | Default |
|----------|-------------|---------|
| `tenancy_ocid` | OCID del Tenancy | (requerido) |
| `compartment_ocid` | OCID del Compartment | (requerido) |
| `region` | Región OCI | us-ashburn-1 |
| `proyecto` | Prefijo para recursos | apigw |
| `ambiente` | Ambiente (dev/staging/prod) | desarrollo |
| `shape_webserver` | Shape del webserver | VM.Standard.E4.Flex |
| `ssh_public_key` | Clave SSH pública | (requerido) |
| `habilitar_nsg` | Usar NSG | true |

## Estimación de Costos

### Always Free Tier

- **API Gateway**: Primeros 1,000 invocaciones/mes (gratis)
- **Functions**: 2 millones de invocaciones/mes (gratis)
- **Compute (VM.Standard.E4.Flex)**: 1 OCPU + 8 GB RAM (gratis)
- **VCN, Subnets, Internet Gateway**: Gratis

**Costo mensual con Always Free**: $0.00 USD/mes

## Despliegue Rápido

```bash
cd arquitecturas-v2/14-api-gateway
terraform init -backend-config=../00-bootstrap-remotestate/backend.hcl
terraform plan -out=plan.tfplan
terraform apply plan.tfplan
```

## Verificación

```bash
API_GW_IP=$(terraform output -raw api_gateway_ip)
curl http://$API_GW_IP/api/health
curl http://$API_GW_IP/api/info
```

## Limpieza

```bash
terraform destroy -auto-approve
```

## Referencias

- [OCI API Gateway Documentation](https://docs.oracle.com/en-us/iaas/Content/APIGateway/home.htm)
- [OCI Functions Guide](https://docs.oracle.com/en-us/iaas/Content/Functions/home.htm)
- [OCI Terraform Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)

---

**Última actualización**: Abril 2026
**Versión**: 2.0
**Compatibilidad**: Terraform >= 1.5.0, OCI Provider >= 5.0
