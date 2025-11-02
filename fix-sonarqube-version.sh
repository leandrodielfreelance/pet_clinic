#!/bin/bash
# fix-sonarqube-version.sh - Corregir versión de SonarQube

echo "🔧 CORRIGIENDO VERSIÓN DE SONARQUBE..."

echo "1. 🛑 Parando servicios..."
docker compose down

echo "2. 🗑️  Limpiando datos anteriores..."
docker volume rm sonarqube-analysis_sonarqube_data 2>/dev/null || echo "Volumen data ya eliminado"
docker volume rm sonarqube-analysis_sonarqube_extensions 2>/dev/null || echo "Volumen extensions ya eliminado"  
docker volume rm sonarqube-analysis_sonarqube_logs 2>/dev/null || echo "Volumen logs ya eliminado"

echo "3. 🔄 Actualizando a versión válida..."
# Opciones de versión válidas
VERSION_OPTIONS=("sonarqube:9.9-community" "sonarqube:lts-community" "sonarqube:9.6-community")

# Probar con la primera opción
SELECTED_VERSION=${VERSION_OPTIONS[0]}

echo "   Usando versión: $SELECTED_VERSION"

# Actualizar docker-compose.yml
cp docker-compose.yml docker-compose.yml.backup
sed -i "s|image: sonarqube:.*|image: $SELECTED_VERSION|" docker-compose.yml

echo "4. 📦 Descargando nueva imagen..."
docker compose pull

echo "5. 🚀 Iniciando SonarQube..."
docker compose up -d

echo "6. ⏳ Esperando inicialización (2-3 minutos)..."
sleep 30

echo "7. 📊 Verificando estado..."
docker compose logs --tail=10 sonarqube

echo ""
echo "✅ Corrección completada"
echo "🌐 Acceder a: http://localhost:9000"
echo "🔑 Credenciales: admin / admin"
echo ""
echo "💡 Si hay problemas, probar con otras versiones:"
printf '%s\n' "${VERSION_OPTIONS[@]}"
