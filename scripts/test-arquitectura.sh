#!/bin/bash
# test-arquitectura.sh — Prueba segura de una arquitectura
# Uso: ./scripts/test-arquitectura.sh arquitecturas-v2/01-fundamentos-webserver

set -euo pipefail

ARCH_DIR="${1:?Uso: $0 <directorio-arquitectura>}"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Prueba Segura: $(basename $ARCH_DIR)${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"

# 1. Verificar que existe terraform.tfvars (no .example)
if [ ! -f "$ARCH_DIR/terraform.tfvars" ]; then
    echo -e "${YELLOW}⚠️  No existe terraform.tfvars${NC}"
    echo -e "   Creando desde template..."
    cp "$ARCH_DIR/terraform.tfvars.example" "$ARCH_DIR/terraform.tfvars"
    echo -e "${RED}✏️  EDITA $ARCH_DIR/terraform.tfvars con tus datos reales y vuelve a ejecutar${NC}"
    exit 1
fi

# 2. Verificar que terraform.tfvars NO tiene placeholders
if grep -q '<tu_' "$ARCH_DIR/terraform.tfvars"; then
    echo -e "${RED}❌ terraform.tfvars aún tiene placeholders sin reemplazar:${NC}"
    grep '<tu_' "$ARCH_DIR/terraform.tfvars"
    exit 1
fi

# 3. Verificar .gitignore protege
echo -e "\n${YELLOW}🔒 Verificando protección .gitignore...${NC}"
PROTECTED=true
for pattern in "terraform.tfvars" "*.tfstate" ".terraform/" "*.tfplan" "backend.hcl"; do
    if ! grep -q "$pattern" .gitignore 2>/dev/null; then
        echo -e "${RED}   ❌ Falta en .gitignore: $pattern${NC}"
        PROTECTED=false
    fi
done
if [ "$PROTECTED" = true ]; then
    echo -e "${GREEN}   ✅ .gitignore protege todos los archivos sensibles${NC}"
fi

# 4. Terraform Init
echo -e "\n${YELLOW}📦 terraform init...${NC}"
cd "$ARCH_DIR"
terraform init -input=false

# 5. Terraform Validate
echo -e "\n${YELLOW}✅ terraform validate...${NC}"
terraform validate

# 6. Terraform Plan
echo -e "\n${YELLOW}📋 terraform plan...${NC}"
terraform plan -out=tfplan

# 7. Ask before apply
echo -e "\n${YELLOW}⚠️  ¿Deseas aplicar? Esto CREARÁ recursos en OCI y puede generar COSTOS${NC}"
read -p "Escribe 'apply' para continuar: " CONFIRM
if [ "$CONFIRM" != "apply" ]; then
    echo -e "${YELLOW}Cancelado. Plan guardado en tfplan${NC}"
    rm -f tfplan
    exit 0
fi

# 8. Apply
echo -e "\n${GREEN}🚀 terraform apply...${NC}"
terraform apply tfplan
rm -f tfplan

# 9. Show outputs
echo -e "\n${GREEN}📊 Outputs:${NC}"
terraform output

# 10. Remind to destroy
echo -e "\n${RED}═══════════════════════════════════════════════════${NC}"
echo -e "${RED}  ⚠️  RECUERDA: terraform destroy cuando termines${NC}"
echo -e "${RED}  Para evitar costos innecesarios ejecuta:${NC}"
echo -e "${RED}  cd $ARCH_DIR && terraform destroy${NC}"
echo -e "${RED}═══════════════════════════════════════════════════${NC}"
