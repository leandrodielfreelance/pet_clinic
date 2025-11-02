#!/bin/bash
# init-analysis-environment.sh - Entorno completo de análisis PetClinic
# Autor: Leandro - Modernización Java Legacy

echo "🚀 INICIALIZACIÓN ENTORNO DE ANÁLISIS PETCLINIC"
echo "================================================"

# Configuración
SONARQUBE_DIR="../sonarqube-analysis"
APP_PORT=8080
SONARQUBE_PORT=9000
MYSQL_PORT=3306

# Función para verificar puertos
check_port() {
    netstat -tulpn 2>/dev/null | grep ":$1 " > /dev/null
}

# Función para mostrar estado
show_status() {
    echo ""
    echo "📊 ESTADO ACTUAL:"
    echo "-----------------"
    
    if check_port $SONARQUBE_PORT; then
        echo "✅ SonarQube: http://localhost:$SONARQUBE_PORT"
    else
        echo "❌ SonarQube: No iniciado"
    fi
    
    if check_port $MYSQL_PORT; then
        echo "✅ MySQL: localhost:$MYSQL_PORT"
    else
        echo "❌ MySQL: No iniciado"
    fi
    
    if check_port $APP_PORT; then
        echo "✅ PetClinic App: http://localhost:$APP_PORT"
    else
        echo "❌ PetClinic App: No iniciada"
    fi
    echo ""
}

# Función iniciar SonarQube
start_sonarqube() {
    echo "📊 Iniciando SonarQube..."
    if [ -d "$SONARQUBE_DIR" ]; then
        cd "$SONARQUBE_DIR"
        docker compose up -d
        sleep 10
        cd - > /dev/null
        echo "✅ SonarQube iniciado: http://localhost:$SONARQUBE_PORT"
    else
        echo "❌ No se encuentra directorio SonarQube: $SONARQUBE_DIR"
    fi
}

# Función iniciar MySQL
start_mysql() {
    echo "🐬 Iniciando MySQL con Docker..."
    docker compose -f docker-compose-analysis.yml up -d mysql
    sleep 5
    echo "✅ MySQL iniciado: localhost:$MYSQL_PORT"
}

# Función iniciar aplicación
start_application() {
    local use_mysql=$1
    
    echo "🖥️  Iniciando Spring PetClinic..."
    
    if [ "$use_mysql" = "true" ]; then
        echo "   🔧 Usando perfil MySQL..."
        # Buscar si existe el JAR compilado
        if [ -f "target/spring-petclinic-1.5.1.jar" ]; then
            /usr/lib/jvm/java-8-openjdk-amd64/bin/java -jar \
                -Dspring.profiles.active=mysql \
                target/spring-petclinic-1.5.1.jar &
        else
            echo "   ⚠️  JAR no encontrado, usando Maven Wrapper..."
            ./mvnw spring-boot:run -Dspring.profiles.active=mysql &
        fi
    else
        echo "   🔧 Usando base de datos en memoria (HSQLDB)..."
        if [ -f "target/spring-petclinic-1.5.1.jar" ]; then
            /usr/lib/jvm/java-8-openjdk-amd64/bin/java -jar \
                target/spring-petclinic-1.5.1.jar &
        else
            echo "   ⚠️  JAR no encontrado, usando Maven Wrapper..."
            ./mvnw spring-boot:run &
        fi
    fi
    
    sleep 8
    echo "✅ Aplicación iniciada: http://localhost:$APP_PORT"
}

# Menú principal
echo ""
echo "🎯 CONFIGURACIÓN DE INICIO:"
echo "1. Iniciar TODO (SonarQube + App con BD memoria)"
echo "2. Iniciar TODO con MySQL"
echo "3. Solo SonarQube"
echo "4. Solo Aplicación (BD memoria)"
echo "5. Solo Aplicación con MySQL"
echo "6. Solo estado actual"
echo "7. Parar todos los servicios"
echo ""

read -p "Selecciona opción (1-7): " choice

case $choice in
    1)
        start_sonarqube
        start_application false
        ;;
    2)
        start_sonarqube
        start_mysql
        start_application true
        ;;
    3)
        start_sonarqube
        ;;
    4)
        start_application false
        ;;
    5)
        start_mysql
        start_application true
        ;;
    6)
        show_status
        exit 0
        ;;
    7)
        echo "🛑 Deteniendo servicios..."
        docker compose -f docker-compose-analysis.yml down 2>/dev/null
        cd "$SONARQUBE_DIR" && docker compose down && cd - > /dev/null
        pkill -f "spring-petclinic"
        echo "✅ Todos los servicios detenidos"
        show_status
        exit 0
        ;;
    *)
        echo "❌ Opción inválida"
        exit 1
        ;;
esac

# Mostrar estado final
show_status

echo ""
echo "🎉 ENTORNO LISTO PARA ANÁLISIS"
echo "==============================="
echo "📊 SonarQube: http://localhost:9000"
echo "🖥️  PetClinic: http://localhost:8080" 
echo "🐬 MySQL: localhost:3306 (si se seleccionó)"
echo ""
echo "💡 Comandos útiles:"
echo "   ./analyze-with-workaround.sh  # Análisis SonarQube"
echo "   ./init-analysis-environment.sh 7  # Parar todo"
echo ""