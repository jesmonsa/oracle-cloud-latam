#!/bin/bash
# pre-commit-hook.sh — Se ejecuta automáticamente antes de cada git commit
# Instalación: cp scripts/pre-commit-hook.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
ERRORES=0

echo "🔒 Pre-commit: Verificando que no se filtren secretos..."

# Verificar archivos staged
STAGED=$(git diff --cached --name-only --diff-filter=ACM)

for file in $STAGED; do
    # Bloquear terraform.tfvars (no .example)
    if [[ "$file" == *"terraform.tfvars" && "$file" != *".example" ]]; then
        echo -e "${RED}❌ BLOQUEADO: $file contiene variables con datos reales${NC}"
        ((ERRORES++))
    fi
    
    # Bloquear backend.hcl
    if [[ "$file" == *"backend.hcl" ]]; then
        echo -e "${RED}❌ BLOQUEADO: $file puede contener credenciales de remote state${NC}"
        ((ERRORES++))
    fi
    
    # Bloquear .tfstate
    if [[ "$file" == *".tfstate"* ]]; then
        echo -e "${RED}❌ BLOQUEADO: $file contiene estado de infraestructura${NC}"
        ((ERRORES++))
    fi
    
    # Bloquear .tfplan
    if [[ "$file" == *".tfplan"* ]]; then
        echo -e "${RED}❌ BLOQUEADO: $file contiene plan de ejecución${NC}"
        ((ERRORES++))
    fi
    
    # Bloquear .pem / .key
    if [[ "$file" == *.pem || "$file" == *.key ]]; then
        echo -e "${RED}❌ BLOQUEADO: $file es una clave privada${NC}"
        ((ERRORES++))
    fi
    
    # Buscar OCIDs reales en archivos staged
    if [[ "$file" == *.tf || "$file" == *.hcl || "$file" == *.yaml ]]; then
        if git diff --cached "$file" 2>/dev/null | grep -qE 'ocid1\.[a-z]+\.oc1\.\.[a-z0-9]{20,}'; then
            echo -e "${RED}❌ BLOQUEADO: $file contiene OCIDs reales${NC}"
            ((ERRORES++))
        fi
    fi
    
    # Buscar AWS keys
    if git diff --cached "$file" 2>/dev/null | grep -qE 'AKIA[A-Z0-9]{16}'; then
        echo -e "${RED}❌ BLOQUEADO: $file contiene AWS Access Keys${NC}"
        ((ERRORES++))
    fi
    
    # Buscar private keys inline
    if git diff --cached "$file" 2>/dev/null | grep -qE 'BEGIN.*(RSA|PRIVATE|OPENSSH)'; then
        echo -e "${RED}❌ BLOQUEADO: $file contiene claves privadas${NC}"
        ((ERRORES++))
    fi
done

if [ $ERRORES -gt 0 ]; then
    echo -e "\n${RED}🚫 COMMIT RECHAZADO: Se detectaron $ERRORES archivos/secretos que no deben subirse${NC}"
    echo -e "${RED}   Usa 'git reset HEAD <archivo>' para quitar archivos del staging${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Pre-commit: Todo limpio, commit permitido${NC}"
