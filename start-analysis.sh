#!/bin/bash
# start-analysis.sh - Script de análisis para modernización
echo "🔧 Iniciando entorno de análisis..."

# Verificar que tenemos el compose file de análisis
if [ ! -f "docker-compose-analysis.yml" ]; then
    echo "❌ Error: No se encuentra docker-compose-analysis.yml"
    exit 1
fi

# Iniciar MySQL para análisis
echo "🐬 Iniciando MySQL para análisis..."
docker compose -f docker-compose-analysis.yml up -d mysql

# Esperar que esté saludable
echo "⏳ Esperando que MySQL esté listo..."
sleep 10

# Verificar estado
docker compose -f docker-compose-analysis.yml ps

echo "✅ Entorno de análisis listo!"
echo "📊 MySQL corriendo en: localhost:3306"
echo "🔍 Usar: docker compose -f docker-compose-analysis.yml logs mysql"
