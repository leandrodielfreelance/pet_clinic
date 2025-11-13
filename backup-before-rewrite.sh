#!/bin/bash
echo "📦 Creando backup completo antes de OpenRewrite..."

# Crear carpeta de backup
BACKUP_DIR="openrewrite-backup-$(date +%Y%m%d-%H%M)"
mkdir -p "$BACKUP_DIR"

echo "📋 Guardando información del proyecto..."

# 1. Estado de Git
git status > "$BACKUP_DIR/01-git-status.txt"
git log --oneline -10 > "$BACKUP_DIR/02-recent-commits.txt"
git diff > "$BACKUP_DIR/03-current-changes.txt" 2>/dev/null || echo "No changes" > "$BACKUP_DIR/03-current-changes.txt"

# 2. Información del proyecto
find src -name "*.java" | head -20 > "$BACKUP_DIR/04-java-files-sample.txt"
mvn --version > "$BACKUP_DIR/05-maven-version.txt"

# 3. Configuración OpenRewrite
mvn rewrite:activeRecipes > "$BACKUP_DIR/06-active-recipes.txt" 2>/dev/null
mvn rewrite:discover > "$BACKUP_DIR/07-all-recipes.txt" 2>/dev/null

# 4. Dry-run completo
echo "🔍 Ejecutando dry-run (puede tardar unos minutos)..."
mvn rewrite:dryRun > "$BACKUP_DIR/08-dry-run-complete.txt" 2>&1

# 5. Copiar archivo patch si existe
if [ -f "target/rewrite/rewrite.patch" ]; then
    cp target/rewrite/rewrite.patch "$BACKUP_DIR/09-rewrite-patch.txt"
fi

# 6. Resumen
echo "✅ Backup completado en: $BACKUP_DIR"
echo "📊 Archivos creados:"
ls -la "$BACKUP_DIR"/*.txt