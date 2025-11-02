#!/bin/bash
# stop-analysis-environment.sh - Parada limpia de todos los servicios

echo "🛑 DETENIENDO ENTORNO DE ANÁLISIS..."

# Detener aplicación PetClinic
echo "🖥️  Deteniendo PetClinic..."
pkill -f "spring-petclinic" 2>/dev/null && echo "✅ PetClinic detenida"

# Detener MySQL
echo "🐬 Deteniendo MySQL..."
docker compose -f docker-compose-analysis.yml down 2>/dev/null && echo "✅ MySQL detenido"

# Detener SonarQube  
echo "📊 Deteniendo SonarQube..."
cd ../sonarqube-analysis && docker compose down && echo "✅ SonarQube detenido"

echo ""
echo "✅ TODOS LOS SERVICIOS DETENIDOS"
docker ps