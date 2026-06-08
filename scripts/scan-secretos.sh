#!/bin/bash
# scan-secretos.sh — Escanea el repositorio buscando secretos antes de hacer push
# Uso: ./scripts/scan-secretos.sh

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
ERRORES=0

echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  🔍 Escáner de Secretos — oracle-cloud-latam${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"

# 1. Archivos que NO deben existir en commits
echo -e "\n${YELLOW}1/7 Buscando archivos sensibles...${NC}"
for pattern in "terraform.tfvars" "*.tfstate" "*.tfstate.backup" "*.tfplan" "*.pem" "*.key" "s3_credentials" "kubeconfig"; do
    found=$(find . -name "$pattern" -not -name "*.example" -not -path "./.terraform/*" -not -path "./.git/*" 2>/dev/null || true)
    if [ -n "$found" ]; then
        echo -e "${RED}   ❌ ENCONTRADO: $found${NC}"
        ((ERRORES++))
    fi
done
if [ $ERRORES -eq 0 ]; then
    echo -e "${GREEN}   ✅ No hay archivos sensibles${NC}"
fi

# 2. Credenciales OCI reales (OCIDs con contenido real)
echo -e "\n${YELLOW}2/7 Buscando OCIDs reales...${NC}"
OCID_REAL=$(grep -rn 'ocid1\.[a-z]*\.oc1\.\.[a-z0-9]\{20,\}' --include='*.tf' --include='*.hcl' --include='*.yaml' --include='*.tfvars' . 2>/dev/null | grep -v '.example' | grep -v '.git/' || true)
if [ -n "$OCID_REAL" ]; then
    echo -e "${RED}   ❌ OCIDs reales encontrados:${NC}"
    echo "$OCID_REAL"
    ((ERRORES++))
else
    echo -e "${GREEN}   ✅ No hay OCIDs reales${NC}"
fi

# 3. AWS Keys
echo -e "\n${YELLOW}3/7 Buscando AWS keys...${NC}"
AWS_KEYS=$(grep -rn 'AKIA[A-Z0-9]\{16\}' . --include='*.tf' --include='*.hcl' --include='*.yaml' --include='*.sh' --include='*.example' 2>/dev/null | grep -v '.git/' || true)
if [ -n "$AWS_KEYS" ]; then
    echo -e "${RED}   ❌ AWS Access Keys encontradas:${NC}"
    echo "$AWS_KEYS"
    ((ERRORES++))
else
    echo -e "${GREEN}   ✅ No hay AWS keys${NC}"
fi

# 4. Private keys inline
echo -e "\n${YELLOW}4/7 Buscando claves privadas inline...${NC}"
PRIV_KEYS=$(grep -rn 'BEGIN.*PRIVATE\|BEGIN RSA\|BEGIN OPENSSH\|BEGIN EC PRIVATE' . --include='*.tf' --include='*.hcl' --include='*.yaml' --include='*.sh' --include='*.md' 2>/dev/null | grep -v '.git/' || true)
if [ -n "$PRIV_KEYS" ]; then
    echo -e "${RED}   ❌ Claves privadas encontradas:${NC}"
    echo "$PRIV_KEYS"
    ((ERRORES++))
else
    echo -e "${GREEN}   ✅ No hay claves privadas${NC}"
fi

# 5. Passwords hardcodeados
echo -e "\n${YELLOW}5/7 Buscando passwords hardcodeados...${NC}"
PASSWORDS=$(grep -rn 'password\s*=\s*"[^<"][^"]*"' --include='*.tf' --include='*.hcl' . 2>/dev/null | grep -v '.example' | grep -v '.git/' | grep -v 'variable\|description\|#' || true)
if [ -n "$PASSWORDS" ]; then
    echo -e "${RED}   ❌ Passwords encontrados:${NC}"
    echo "$PASSWORDS"
    ((ERRORES++))
else
    echo -e "${GREEN}   ✅ No hay passwords hardcodeados${NC}"
fi

# 6. backend.hcl con credenciales
echo -e "\n${YELLOW}6/7 Verificando backend.hcl...${NC}"
BACKEND_CREDS=$(find . -name "backend.hcl" -exec grep -l 'access_key\s*=\s*"[^<"]' {} \; 2>/dev/null || true)
if [ -n "$BACKEND_CREDS" ]; then
    echo -e "${RED}   ❌ backend.hcl con credenciales reales:${NC}"
    echo "$BACKEND_CREDS"
    ((ERRORES++))
else
    echo -e "${GREEN}   ✅ backend.hcl limpio${NC}"
fi

# 7. Emails reales (no @ejemplo.com, no @example.com)
echo -e "\n${YELLOW}7/7 Buscando emails potencialmente reales...${NC}"
EMAILS=$(grep -rohn '[a-zA-Z0-9._%+-]*@[a-zA-Z0-9.-]*\.[a-zA-Z]\{2,\}' --include='*.tf' --include='*.hcl' --include='*.yaml' --include='*.example' . 2>/dev/null | grep -v '@ejemplo\.com\|@example\.com\|@oraclecloud\.com\|@oracle\.com\|@hashicorp\.com' | grep -v '.git/' | sort -u || true)
if [ -n "$EMAILS" ]; then
    echo -e "${YELLOW}   ⚠️  Emails a revisar:${NC}"
    echo "$EMAILS"
else
    echo -e "${GREEN}   ✅ No hay emails sospechosos${NC}"
fi

# Resultado
echo -e "\n${BLUE}═══════════════════════════════════════════════════${NC}"
if [ $ERRORES -gt 0 ]; then
    echo -e "${RED}  ❌ FALLÓ: $ERRORES problemas encontrados${NC}"
    echo -e "${RED}  NO es seguro hacer push a GitHub${NC}"
    exit 1
else
    echo -e "${GREEN}  ✅ PASÓ: Repositorio limpio y seguro para push${NC}"
fi
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
