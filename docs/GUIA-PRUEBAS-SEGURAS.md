# Guía Completa: Pruebas Seguras vs Publicación en GitHub

## Arquitectura de Separación: Pruebas vs GitHub

El secreto de mantener un repositorio Terraform seguro es una **separación clara y automatizada** entre lo que pruebas localmente y lo que publicas públicamente.

### Diagrama: El Perímetro de Seguridad

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                   │
│  TU PC LOCAL (Pruebas)            GITHUB (Público)               │
│  ═══════════════════════════      ═══════════════════════════   │
│                                                                   │
│  terraform.tfvars ← TUS DATOS    terraform.tfvars.example ← PH  │
│  backend.hcl ← TUS CREDENCIALES  (NO EXISTE backend.hcl)        │
│  .terraform/ ← providers cache    .terraform/ (NO EXISTE)        │
│  *.tfstate ← estado real           *.tfstate (NO EXISTE)         │
│  *.tfplan ← plan real              *.tfplan (NO EXISTE)          │
│  *.pem ← SSH keys                  *.pem (NO EXISTE)             │
│  *.key ← API keys                  *.key (NO EXISTE)             │
│                                                                   │
│  ↑ Estos NUNCA salen de tu PC   ↑ 100% seguro, sin secretos     │
│    (.gitignore los bloquea)       (Visible a todo el mundo)      │
│    (pre-commit los valida)        (GitHub Actions verifica)      │
│    (hooks evitan errores)         (Listo para clonar y usar)     │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

### Las Tres Líneas de Defensa

```
┌─ LÍNEA 1: .gitignore (Local) ────────────────────────────────┐
│ Bloquea automáticamente que archivos sensibles se stageen     │
│ NUNCA alcanzan el área de stage de Git                        │
└────────────────────────────────────────────────────────────────┘

┌─ LÍNEA 2: Pre-commit Hooks (Local) ──────────────────────────┐
│ Se ejecuta ANTES de cada commit                               │
│ Escanea lo que intentas commitear                             │
│ Rechaza si detecta secretos/OCIDs/keys                        │
└────────────────────────────────────────────────────────────────┘

┌─ LÍNEA 3: GitHub Actions (Remoto) ──────────────────────────┐
│ Se ejecuta en cada push/PR                                    │
│ Verifica nuevamente que no hay secretos                       │
│ Valida sintaxis Terraform                                     │
│ Es tu red de seguridad final                                  │
└────────────────────────────────────────────────────────────────┘
```

---

## 1. El .gitignore: Tu Primera Línea de Defensa

El archivo `.gitignore` le dice a Git qué archivos **NUNCA** debe rastrear. Es automático y evita errores humanos.

### Contenido recomendado para `.gitignore`

```gitignore
# ==================== TERRAFORM ====================
# Variables con datos reales (solo .example se sube)
terraform.tfvars
terraform.tfvars.json
terraform.tfvars.*.example

# Estado de Terraform (nunca debe subirse)
*.tfstate
*.tfstate.*
*.tfstate.backup

# Plans con datos sensibles
*.tfplan
*.tfplan.*

# Archivos de backend con credenciales
backend.hcl
backend.local.hcl

# Directorio .terraform (descargado al hacer init)
.terraform/
.terraform.lock.hcl

# ==================== CLAVES Y CREDENCIALES ====================
# Claves privadas
*.pem
*.key
*.pub
*.ppk
*.cer
*.crt

# Credenciales de servicios
kubeconfig
kubeconfig-*
*-credentials.json
*-credentials.yaml
credentials
.aws/
.gcloud/
.oci/
.env
.env.local
.env.*.local

# ==================== IDE Y HERRAMIENTAS ====================
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store
.cache/

# ==================== LOGS ====================
*.log
*.logs
debug.log
crash.log

# ==================== TEMPORAL ====================
*.tmp
*.temp
*.bak
.tmp/
__pycache__/
```

**Punto clave:** Un archivo en `.gitignore` **NO puede ser staged accidentalmente**, pero si ya estaba en el repositorio antes de agregarlo, hay que borrarlo del historio de Git.

---

## 2. terraform.tfvars.example: La Plantilla Pública

Este archivo **SÍ se sube a GitHub** y contiene **placeholders** en lugar de valores reales.

### Estructura correcta de terraform.tfvars.example

```hcl
# ==================== TENANCY Y COMPARTMENT ====================
tenancy_ocid = "<tu_tenancy_ocid>"        # Ej: ocid1.tenancy.oc1..
compartment_id = "<tu_compartment_id>"    # Ej: ocid1.compartment.oc1..

# ==================== REGION Y AVAILABILITY DOMAINS ====================
region = "<tu_region>"                    # Ej: us-phoenix-1, us-ashburn-1, sa-santiago-1
availability_domain = "<tu_ad>"           # Ej: VBpb:US-PHOENIX-1-AD-1

# ==================== NETWORKING ====================
vpc_cidr = "10.0.0.0/16"                 # Este SÍ es ejemplo seguro (RFC1918)
subnet_cidr = "10.0.1.0/24"
dns_label = "<tu_dns_label>"              # Ej: myapp (sin comillas)

# ==================== INSTANCIAS ====================
instance_shape = "VM.Standard.E4.Flex"
instance_image_ocid = "<tu_image_ocid>"   # Ej: ocid1.image.oc1...
instance_count = 1
ssh_public_key = "<contenido_de_tu_ssh_public_key>"  # Contiene BEGIN SSH PUBLIC KEY, pero el usuario lo proporciona

# ==================== CERTIFICADOS (si aplica) ====================
certificate_content = "<contenido_de_tu_certificado>" # El usuario rellena esto
private_key_content = "<contenido_de_tu_private_key>" # El usuario rellena esto

# ==================== TAGS ====================
common_tags = {
  "Environment" = "dev"
  "Project"     = "mi-proyecto"
  "ManagedBy"   = "terraform"
  "CostCenter"  = "<tu_cost_center>"
}
```

### Cómo el usuario lo utiliza

```bash
# 1. Clonar el repo
git clone https://github.com/tu-org/Arquitectura-base.git
cd Arquitectura-base/arquitecturas-v2/01-fundamentos-webserver

# 2. Copiar el ejemplo como base
cp terraform.tfvars.example terraform.tfvars

# 3. Editar con SUS datos reales
nano terraform.tfvars
# (Cambiar <tu_tenancy_ocid> por su OCID real, etc.)

# 4. terraform.tfvars ahora tiene datos reales
# Pero .gitignore lo protege: Git NUNCA lo verá
git status
# (terraform.tfvars no aparece en los cambios)
```

---

## 3. Las Pruebas se Hacen 100% en Local

Las evidencias de tus pruebas **NUNCA** deben subirse a GitHub. Aquí está el flujo completo:

### Flujo de Pruebas Local (Paso a Paso)

```
┌─ PASO 1: CLONAR ────────────────────────────────────────┐
│ $ git clone <repo>                                      │
│ $ cd <arquitectura>                                     │
│ ✓ Obtienes: *.tf, *.tfvars.example, README, etc.       │
│ ✓ NO obtienes: terraform.tfvars (no existe en remote) │
└─────────────────────────────────────────────────────────┘

┌─ PASO 2: CREAR VARIABLES LOCALES ──────────────────────┐
│ $ cp terraform.tfvars.example terraform.tfvars         │
│ $ nano terraform.tfvars                                │
│   (cambiar <tu_tenancy_ocid> por valor real)           │
│   (cambiar <tu_compartment_id> por valor real)         │
│   (etc.)                                               │
│ ✓ Ahora tienes datos reales, pero .gitignore lo cubre │
└─────────────────────────────────────────────────────────┘

┌─ PASO 3: INICIALIZAR TERRAFORM ────────────────────────┐
│ $ terraform init                                        │
│ ✓ Descarga providers (AWS, OCI, etc.)                  │
│ ✓ Crea directorio .terraform/ (oculto por .gitignore) │
│ ✓ Crea .terraform.lock.hcl (SÍ se sube)               │
└─────────────────────────────────────────────────────────┘

┌─ PASO 4: VALIDAR SINTAXIS ─────────────────────────────┐
│ $ terraform validate                                    │
│ ✓ Verifica que la sintaxis es correcta                 │
│ ✗ NO conecta a OCI aún                                │
└─────────────────────────────────────────────────────────┘

┌─ PASO 5: GENERAR PLAN ─────────────────────────────────┐
│ $ terraform plan -out=tfplan                           │
│ ✓ Conecta a OCI                                        │
│ ✓ Valida que tus credenciales funcionen               │
│ ✓ Calcula qué recursos se crearán/modificarán         │
│ ✗ AÚN no crea nada en OCI                             │
│ ⚠️  Crea archivo tfplan (oculto por .gitignore)       │
└─────────────────────────────────────────────────────────┘

┌─ PASO 6: REVISAR PLAN Y APLICAR ───────────────────────┐
│ $ terraform apply tfplan                               │
│ ✓ Ejecuta EXACTAMENTE lo que mostró el plan           │
│ ✓ Crea recursos en OCI (¡GENERA COSTOS!)              │
│ ✗ Los recursos son REALES en tu tenancy               │
│ ✓ Muestra outputs (IPs, OCIDs, URLs, etc.)            │
└─────────────────────────────────────────────────────────┘

┌─ PASO 7: VERIFICAR QUE FUNCIONA ──────────────────────┐
│ (Aquí pruebas manualmente:                             │
│  - ¿Puedes SSH a la instancia?                         │
│  - ¿Responde la aplicación?                            │
│  - ¿Están los backups configurados?                    │
│  - etc.)                                               │
└─────────────────────────────────────────────────────────┘

┌─ PASO 8: LIMPIAR RECURSOS ────────────────────────────┐
│ $ terraform destroy                                     │
│ ✓ Elimina TODOS los recursos que creó                 │
│ ✓ Evita costos continuos innecesarios                  │
│ ✓ Leaves .terraform/, tfplan, .tfstate en local       │
│ (Estos archivos con datos sensibles quedan en tu PC)  │
└─────────────────────────────────────────────────────────┘

┌─ PASO 9: HACER PUSH A GITHUB (si es necesario) ────────┐
│ $ git status                                            │
│ ✓ terraform.tfvars NO aparece (oculto)                │
│ ✓ .terraform/ NO aparece (oculto)                      │
│ ✓ *.tfstate NO aparece (oculto)                        │
│ ✓ *.tfplan NO aparece (oculto)                         │
│ $ git push                                              │
│ ✓ Solo se sube: *.tf, *.tfvars.example, docs, etc.    │
└─────────────────────────────────────────────────────────┘
```

---

## 4. Las Variables Sensibles: backend.hcl

Si usas **remote state** (guardando estado en OCI Object Storage), el archivo `backend.hcl` contiene credenciales.

### ¿Qué es backend.hcl?

```hcl
# backend.hcl — Se especifica con: terraform init -backend-config=backend.hcl
bucket         = "tu-bucket-nombre"
key            = "arquitecturas-v2/01-fundamentos/terraform.tfstate"
region         = "us-phoenix-1"
# En OCI, las credenciales PUEDEN venir del perfil local en ~/.oci/config
# O puedes especificar:
# access_key = "tu_access_key"       ← ⚠️  NUNCA en Git, solo local
# secret_key = "tu_secret_key"       ← ⚠️  NUNCA en Git, solo local
```

### Cómo protegerlo

```bash
# 1. backend.hcl NUNCA se sube a GitHub
#    Asegúrate de que está en .gitignore
echo "backend.hcl" >> .gitignore

# 2. El usuario lo crea localmente
#    cp backend.hcl.example backend.hcl
#    # Edita con credenciales reales

# 3. Se especifica al inicializar:
#    terraform init -backend-config=backend.hcl

# 4. Si prefieres, usa variables de entorno:
#    export TF_VAR_backend_bucket="mi-bucket"
#    terraform init
```

---

## 5. Pre-commit Hooks: La Segunda Línea de Defensa

Los hooks de pre-commit se ejecutan **ANTES** de cada `git commit` y pueden **rechazarlo** si detectan secretos.

### Instalación del Hook

```bash
# 1. Copiar el script
cp scripts/pre-commit-hook.sh .git/hooks/pre-commit

# 2. Hacerlo ejecutable
chmod +x .git/hooks/pre-commit

# 3. Listo. En el siguiente commit, se ejecutará automáticamente
git commit -m "Cambios"
# (hook se ejecuta → rechaza si hay secretos)
```

### Qué hace el pre-commit hook

El hook rechaza commits que contengan:
- `terraform.tfvars` (variables con datos reales)
- `backend.hcl` (con credenciales)
- `*.tfstate` o `*.tfstate.backup`
- `*.tfplan`
- Claves privadas (`.pem`, `.key`)
- OCIDs reales en archivos staged
- AWS Access Keys (patrón `AKIA...`)
- Private keys inline (BEGIN RSA PRIVATE KEY, etc.)

### Ejemplo de uso

```bash
$ nano scripts/test-arquitectura.sh  # Haces cambios
$ git add scripts/test-arquitectura.sh
$ git commit -m "Mejorar script de pruebas"
✓ Pre-commit hook se ejecuta
✓ Verifica: ¿hay terraform.tfvars, .tfstate, etc.?
✓ No detecta secretos → commit permitido
✓ Commit se crea

# Pero si haces esto:
$ echo 'password = "mi-password-real"' >> variables.tf
$ git add variables.tf
$ git commit -m "Agregar password"
✗ Pre-commit hook se ejecuta
✗ Detecta: "password = "algo real""
✗ Commit RECHAZADO
✗ Error: "COMMIT RECHAZADO: Se detectaron secretos"
→ Tienes que quitar el archivo del staging: git reset HEAD variables.tf
```

---

## 6. GitHub Actions: La Tercera Línea de Defensa

Incluso si el pre-commit hook falla o lo saltas, GitHub Actions verifica en remoto.

### El flujo de GitHub Actions

```
┌─────────────────────────────────────────────────┐
│ $ git push origin main                          │
├─────────────────────────────────────────────────┤
│ GitHub recibe el push                           │
│ ↓                                               │
│ Dispara workflow: "Escaneo de Secretos"         │
│ ↓                                               │
│ Job 1: scan-secretos                           │
│   ✓ Busca terraform.tfvars, .tfstate, etc.     │
│   ✓ Busca OCIDs reales                          │
│   ✓ Busca AWS keys                              │
│   ✓ Busca private keys inline                   │
│   ✓ Verifica emails reales                      │
│                                                 │
│ Job 2: validar-terraform                       │
│   ✓ terraform validate en cada arquitectura    │
│   ✓ terraform fmt (verificar formateo)         │
│                                                 │
│ ↓                                               │
│ ✓ Si TODO PASÓ:                                 │
│   - Workflow marca PASSING                      │
│   - PR puede ser merged                         │
│                                                 │
│ ✗ Si ALGO FALLÓ:                                │
│   - Workflow marca FAILING                      │
│   - PR bloqueada hasta que se corrija           │
│   - Email al autor con detalles del error       │
└─────────────────────────────────────────────────┘
```

### Qué verifica GitHub Actions

1. **Archivos sensibles:** No existen `terraform.tfvars`, `*.tfstate`, `.pem`, `.key` en el repositorio.
2. **OCIDs reales:** Busca el patrón `ocid1.*.oc1.*` seguido de 20+ caracteres.
3. **AWS Keys:** Busca `AKIA[A-Z0-9]{16}`.
4. **Private keys inline:** Busca `BEGIN RSA PRIVATE KEY`, `BEGIN OPENSSH PRIVATE KEY`, etc.
5. **Placeholders correctos:** Verifica que `*.tfvars.example` use placeholders como `<tu_tenancy_ocid>`, no valores reales.
6. **Sintaxis Terraform:** Ejecuta `terraform validate` en cada arquitectura.
7. **Formato:** Ejecuta `terraform fmt -check` para asegurar código formateado.

---

## 7. Plan de Pruebas por Costo

Diferentes módulos tienen diferentes costos. Aquí está el orden recomendado para empezar:

### TIER 1: Gratis o Mínimo Costo (~$0-2/día)

Usa recursos **Always Free** de Oracle Cloud.

```
✓ 00-bootstrap
  - Solo crea compartments, grupos, políticas
  - Sin compute, storage, ni DB
  - Costo: $0

✓ 01-fundamentos-webserver (con micro instance)
  - 1x Compute VM.Standard.A1 (Ampere, Always Free)
  - VCN, subnets, internet gateway
  - Costo: $0 (Always Free tier)

✓ 15-observabilidad (con OCI Monitoring Free)
  - OCI Monitoring (50 métricas gratis)
  - Logs (primeros 1GB gratis)
  - Costo: $0-1

✓ 16-vault-secretos (Vault Local)
  - OCI Vault (primera 20 claves gratuitas)
  - Costo: $0
```

**Duración típica:** 10-15 minutos por módulo.

### TIER 2: Bajo Costo (~$5-10/día)

Pequeños clusters y load balancers.

```
✓ 02-alta-disponibilidad-multi-ad
  - 2x Compute VM.Standard.E4.Flex (1 OCPU)
  - Costo: ~$5/día

✓ 03-load-balancer-ha
  - Network Load Balancer
  - 2-3 instancias backend
  - Costo: ~$8-10/día

✓ 04-bastion-host
  - 1x Bastion host (pequeña)
  - Costo: ~$2/día
```

**Duración típica:** 10-20 minutos por módulo.

### TIER 3: Costo Medio (~$15-30/día)

Más recursos, databases small, WAF básico.

```
✓ 05-object-storage
  - Object Storage (pagado por uso)
  - Costo: ~$0.02/GB almacenado = ~$2/día típico

✓ 08-peering-vcn
✓ 09-peering-remoto-multiregion
  - Conectividad entre VCNs
  - Costo: ~$5-10/día

✓ 11-waf-web-application-firewall
  - WAF + Load Balancer
  - Costo: ~$10/día

✓ 12-vpn-site-to-site
  - IPSec VPN
  - Costo: ~$8-15/día

✓ 13-oke-cluster-pequeno
  - Kubernetes cluster (3 nodos small)
  - Costo: ~$15-20/día

✓ 14-api-gateway
  - API Gateway + funciones
  - Costo: ~$5/día
```

**Duración típica:** 15-30 minutos por módulo.

### TIER 4: Costo Alto (~$50+/día)

Producción, bases de datos grandes, high availability completo.

```
✗ 06-base-datos-oracle
  - Oracle Database (incluso la pequeña)
  - Costo: $50-100+/día

✗ 07-dataguard-standby
  - 2x Oracle Database con replicación
  - Costo: $100+/día

✗ 17-arquitectura-completa
  - Todo junto: BD, OKE, WAF, Peering
  - Costo: $200+/día
```

**RECOMENDACIÓN:** Probar primero los TIER 1 y 2 para familiarizarte con Terraform y OCI. Solo avanza a TIER 3+ cuando necesites estos recursos específicamente.

---

## 8. Always-Free Resources: Cómo Ahorrar

Oracle Cloud ofrece una **capa Always-Free** permanente. Aprovéchala:

```hcl
# ✓ SIEMPRE GRATIS (sin límite de tiempo)
resource "oci_core_instance" "app" {
  shape = "VM.Standard.A1.Flex"  # Ampere, 4 OCPUs Always-Free
  # ... resto de config
}

resource "oci_database_autonomous_database" "db" {
  db_workload = "OLTP"
  # Versión Always-Free: 1 OCPU, 20GB storage
  is_always_free_eligible = true
  # Costo: $0/mes
}

resource "oci_core_volume" "storage" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  size_gb             = 200  # 200GB Always-Free
  # Costo: $0/mes para los primeros 200GB
}
```

**Total Always-Free aproximado:**
- 2x A1 Compute (4 OCPUs total)
- 200GB Block Storage
- 1x Autonomous Database (1 OCPU, 20GB)
- 10GB Object Storage (+ $0.023/GB adicional)
- 1TB Bandwidth egress gratuito/mes

---

## 9. Checklist: Antes de Hacer Push a GitHub

Antes de `git push`, ejecuta este checklist:

```bash
# 1. Ejecutar escáner de secretos
./scripts/scan-secretos.sh

# 2. Verificar que .gitignore está actualizado
cat .gitignore | grep -E "terraform.tfvars|\.tfstate|\.pem|\.key|backend\.hcl"

# 3. Revisar cambios antes de commit
git status          # ¿Aparecen archivos sensibles aquí?
git diff --cached   # ¿Veo OCIDs, passwords, keys?

# 4. Hacer commit (pre-commit hook se ejecuta automáticamente)
git commit -m "Cambios..."

# 5. Si todo pasó, hacer push
git push origin main

# 6. Revisar que GitHub Actions pasó
# → Ve a https://github.com/tu-org/repo/actions
# → Busca el último workflow run
# → ¿Está en verde (PASSED)?
```

Si algo falla, **detente y revisa** antes de hacer push nuevamente.

---

## 10. Recuperarse si Acciónaste un Secreto

Esto sucede. No entres en pánico. Aquí está cómo recuperarte:

### Caso 1: Detectaste ANTES de hacer push

```bash
# Si lo detectó el pre-commit hook:
✗ COMMIT RECHAZADO

# Solución:
git reset HEAD <archivo>  # Quitar del staging
git restore <archivo>     # Restaurar versión anterior
# O simplemente eliminar el archivo:
rm terraform.tfvars

# Ahora vuelve a intentar:
git commit -m "..."
```

### Caso 2: Cometiste el error pero no hiciste push aún

```bash
# El secreto está en un commit local, pero no subió
git log --oneline      # Ver commit reciente

# Opción A: Deshacer el último commit (si recién lo hiciste)
git reset --soft HEAD~1  # El commit se revierte pero archivos quedan
git reset HEAD terraform.tfvars  # Quitar del staging
git restore terraform.tfvars      # Restaurar limpio

# Opción B: Si ya pasó tiempo, usar rebase interactivo
git rebase -i HEAD~5   # Editar los últimos 5 commits
# (Esto es más complejo, mejor contacta a tu lead)
```

### Caso 3: Ya hiciste push (¡oh no!)

```bash
# El secreto está en GitHub público

# Pasos de emergencia:
# 1. Revocar la credencial INMEDIATAMENTE
#    (si es OCID, cambiar la llave de la tenancy en OCI)
#    (si es AWS key, desactivar en IAM)
#    (etc.)

# 2. Limpiar el historio de Git:
git filter-branch --tree-filter 'rm -f terraform.tfvars' -- --all
# (Esto es destructivo, mejor contacta a tu lead)

# 3. Force push (solo si tienes permiso)
git push origin --force-with-lease

# 4. Avisar al equipo que el secreto fue expuesto
#    (pueden haber otros clones locales)
```

**Recomendación:** Usa `scan-secretos.sh` regularmente para evitar esto.

---

## 11. Flujo Completo: Desarrollo → GitHub → Producción

```
┌─────────────────────────────────────────────────────────────┐
│ 1. DESARROLLO LOCAL                                         │
│  └─ Archivos: *.tf, .tfvars.example, scripts, docs         │
│  └─ Editas código Terraform                                │
│  └─ Ejecutas: terraform plan/apply LOCALMENTE              │
│  └─ Credenciales: En terraform.tfvars (local, oculto)      │
└─────────────────────────────────────────────────────────────┘
                           │
                           ↓
        ┌──────────────────────────────────────┐
        │ 2. SCAN-SECRETOS (local)             │
        │   ./scripts/scan-secretos.sh         │
        │   ✓ Pasa → continúa                  │
        │   ✗ Falla → revisa qué está expuesto│
        └──────────────────────────────────────┘
                           │
                           ↓
        ┌──────────────────────────────────────┐
        │ 3. GIT COMMIT (local)                │
        │   git add .                          │
        │   git commit -m "..."                │
        │   ↓ Pre-commit hook se ejecuta       │
        │   ✓ Pasa → commit creado             │
        │   ✗ Falla → rechaza commit           │
        └──────────────────────────────────────┘
                           │
                           ↓
        ┌──────────────────────────────────────┐
        │ 4. GIT PUSH (a GitHub)               │
        │   git push origin main               │
        │   Sube: *.tf, .tfvars.example, docs  │
        │   NO sube: .tfvars, .tfstate, .pem   │
        └──────────────────────────────────────┘
                           │
                           ↓
        ┌──────────────────────────────────────┐
        │ 5. GITHUB ACTIONS (remoto)           │
        │   Dispara: scan-secretos workflow    │
        │   Dispara: validar-terraform workflow│
        │   ✓ Ambos pasan → PR status green    │
        │   ✗ Algo falla → PR status red       │
        └──────────────────────────────────────┘
                           │
                           ↓
        ┌──────────────────────────────────────┐
        │ 6. PULL REQUEST / MERGE (GitHub)     │
        │   ✓ Si workflows pasaron:            │
        │     → PR puede ser merged            │
        │     → Cambios van a main             │
        │   ✗ Si workflows fallaron:           │
        │     → PR bloqueada                   │
        │     → Tienes que arreglarlo          │
        └──────────────────────────────────────┘
                           │
                           ↓
        ┌──────────────────────────────────────┐
        │ 7. PRODUCCIÓN / OTROS EQUIPOS       │
        │   El repo está ahora actualizado     │
        │   Otros pueden clonar el repo        │
        │   Siguen: cp .example → rellena     │
        │   Ejecutan: terraform init/plan/apply│
        │   Con TULS CREDENCIALES (no públicas)│
        └──────────────────────────────────────┘
```

---

## 12. Preguntas Frecuentes

**P: ¿Qué pasa si alguien clona mi repo sin mis credenciales?**
R: No pueden hacer `terraform apply`. Necesitan:
```bash
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars con TULS credenciales OCI
terraform init
terraform plan  # Ahora usa sus credenciales, no las mías
```

**P: ¿Puedo usar variables de entorno en lugar de archivos?**
R: Sí, es más seguro aún:
```bash
export TF_VAR_tenancy_ocid="mi_ocid"
export TF_VAR_compartment_id="mi_compartment"
# terraform plan/apply ahora lee del entorno, no de archivos
# (Aunque sigue siendo bueno tener .tfvars.example como documentación)
```

**P: ¿Qué hago con el directorio .terraform/?**
R: Se descarga automáticamente con `terraform init`. Se oculta con .gitignore. Cada usuario tiene el suyo. NO lo subes.

**P: ¿Puedo commitear .terraform.lock.hcl?**
R: **Sí, DEBES hacerlo.** Es un lockfile que asegura que todos usen las mismas versiones de providers.

**P: ¿Y si genero un .tfplan durante las pruebas?**
R: Queda local (en .gitignore). Puedes borrarlo después:
```bash
rm tfplan
```

**P: ¿Cómo hago que otros desarrolladores ejecuten el scan automáticamente?**
R: Instalan el hook:
```bash
cp scripts/pre-commit-hook.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

**P: ¿GitHub Actions ralentiza los pushes?**
R: No. GitHub Actions corre en paralelo, después del push. Tu commit es instantáneo. El workflow corre en segundos en los servidores de GitHub.

---

## Conclusión

El flujo de **Pruebas Seguras vs Publicación** protege:
1. ✓ Tus credenciales (nunca salen de tu PC)
2. ✓ Tu tenancy (no hay exposición de OCIDs reales)
3. ✓ Tu dinero (no riesgos de cryptominería, etc.)
4. ✓ El repo (limpio, documentado, auditable)
5. ✓ El equipo (todos saben cuál es el proceso)

**La clave:** Tres líneas de defensa (.gitignore, pre-commit, GitHub Actions) que trabajan juntas para hacer que sea *imposible* (no difícil) exponer secretos.
