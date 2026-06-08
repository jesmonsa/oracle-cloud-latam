#!/bin/bash
# ==============================================================================
# Script para empaquetar Arquitecturas de OCI en formato ZIP para OCI Resource Manager
# ==============================================================================

set -e

BASE_DIR="$(pwd)"
ARCH_DIR="$BASE_DIR/arquitecturas"
MOD_DIR="$BASE_DIR/modulos"
RELEASE_DIR="$BASE_DIR/releases"

echo "Preparando directorio de releases en $RELEASE_DIR..."
mkdir -p "$RELEASE_DIR"
rm -f "$RELEASE_DIR"/*.zip

for ARCH_PATH in "$ARCH_DIR"/*/; do
  ARCH_NAME=$(basename "$ARCH_PATH")
  
  echo "Empaquetando arquitectura: $ARCH_NAME"
  
  # Crear directorio temporal para el ensamblado
  TMP_BUILD_DIR=$(mktemp -d)
  
  # Copiar archivos de arquitectura
  cp -r "$ARCH_PATH"* "$TMP_BUILD_DIR/"
  
  # Mover módulos locales requeridos al zip
  # Buscamos todas las referencias al source "../../modulos/..."
  # y copiamos esos módulos físicos dentro de la misma carpeta del ZIP
  mkdir -p "$TMP_BUILD_DIR/modulos"
  
  if grep -q 'source.*=.*"../../modulos/' "$TMP_BUILD_DIR"/*.tf 2>/dev/null; then
    # Extraer las rutas de los modulos utilizados
    MODULES_USED=$(grep 'source.*=.*"../../modulos/' "$TMP_BUILD_DIR"/*.tf | awk -F '"' '{print $2}' | sort | uniq | sed 's/\.\.\/\.\.\/modulos\///')
    
    for MOD in $MODULES_USED; do
      echo "  - Incluyendo módulo: $MOD"
      # Extraer categoría y nombre (ej: red/vcn)
      MOD_CATEGORY=$(dirname "$MOD")
      MOD_NAME=$(basename "$MOD")
      
      mkdir -p "$TMP_BUILD_DIR/modulos/$MOD_CATEGORY/$MOD_NAME"
      cp -r "$MOD_DIR/$MOD"/* "$TMP_BUILD_DIR/modulos/$MOD_CATEGORY/$MOD_NAME/"
    done
    
    # Reemplazar ../../modulos/ por ./modulos/ en el temporal
    if [ "$(uname)" == "Darwin" ]; then
      # macOS / BSD sed
      find "$TMP_BUILD_DIR" -name "*.tf" -exec sed -i '' 's/\.\.\/\.\.\/modulos/\.\/modulos/g' {} +
    else
      # GNU Linux sed
      find "$TMP_BUILD_DIR" -name "*.tf" -exec sed -i 's/\.\.\/\.\.\/modulos/\.\/modulos/g' {} +
    fi
  fi
  
  # Empaquetar
  cd "$TMP_BUILD_DIR"
  zip -r "$RELEASE_DIR/$ARCH_NAME.zip" ./* > /dev/null
  cd "$BASE_DIR"
  
  # Limpiar temporal
  rm -rf "$TMP_BUILD_DIR"
  
  echo "  ✅ Creado $RELEASE_DIR/$ARCH_NAME.zip"
done

echo "Proceso finalizado. Total de zips generados en $RELEASE_DIR"
ls -lh "$RELEASE_DIR" | grep ".zip"
