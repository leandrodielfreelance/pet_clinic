#!/bin/bash
# analyze-petclinic-legacy.sh - Análisis específico para Spring PetClinic legacy
echo "🔍 Análisis Spring PetClinic 1.5.1 Legacy..."

echo "📖 Contexto: Proyecto oficial Spring Boot 1.5.1"
echo "🎯 Objetivo: Identificar deuda técnica para modernización"

# Verificar que estamos en el proyecto correcto
if [ ! -f "pom.xml" ] || ! grep -q "spring-petclinic" "pom.xml"; then
    echo "❌ No se detecta Spring PetClinic"
    exit 1
fi

# Usar Maven Wrapper como sugiere el README
if [ -f "./mvnw" ]; then
    echo "🛠️ Usando Maven Wrapper del proyecto..."
    MVN_CMD="./mvnw"
else
    echo "🛠️ Usando Maven del sistema..."
    MVN_CMD="mvn"
fi

# Compilar como indica el README
echo "🏗️ Compilando con Spring Boot 1.5.x..."
$MVN_CMD clean compile -DskipTests

# Análisis SonarQube
read -sp "🔑 Password de SonarQube admin: " SONAR_PASSWORD
echo

echo "📊 Iniciando análisis de deuda técnica..."
sonar-scanner \
  -Dproject.settings=sonar-project-analysis.properties \
  -Dsonar.login=admin \
  -Dsonar.password=$SONAR_PASSWORD

echo "✅ Análisis completado!"
echo "📈 Revisar: http://localhost:9000/dashboard?id=spring-petclinic-1.5.1-legacy"
echo "🎯 Buscar: Code smells, vulnerabilidades, deuda técnica"