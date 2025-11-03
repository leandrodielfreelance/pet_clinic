#Levantar docker (DB)

Levantar servicio mysql (NOTA: no es necesario en desarrollo o pruebas ya que se usa una DB en memoria por defecto).

docker compose up mysql

# Compilar el proyecto (ya debería estar compilado)
mvn clean package -DskipTests

# Ejecutar el JAR con Java 8 explícitamente
/usr/lib/jvm/java-8-openjdk-amd64/bin/java -jar target/spring-petclinic-1.5.1.jar

#SERVICIOS DOCKER:

#levantar servicio docker:

(parados en la carpeta donde esta el docker-compose.yml)

sudo docker compose up 

#bajar servicio:

sudo docker compose stop

## SonarQube:

Credenciales:

admin
pass
#Para escanear el codigo:

1. Levantar el servicio en el puerto 9000:
En la carpeta donde esta el docker-compose.yml de SonarQube hacemos:

sudo docker compose up 


2. Escanear codigo para sonarqube

-importante: este comando analiza la RAMA donde estoy parado y saltea los tests.

mvn clean compile sonar:sonar \
  -Dsonar.projectKey=petclinic-modernization-leandro \
  -Dsonar.projectName="PetClinic - Rama Modernization (Leandro)" \
  -Dsonar.sources=src/main/java \
  -Dsonar.tests=src/test/java \
  -Dsonar.java.binaries=target/classes \
  -Dsonar.login=admin \
  -Dsonar.password=pass \
  -DskipTests


#OTRAS FORMAS:

# Con MAVEN (ESTO NO lee el archivo de .properties):   

mvn sonar:sonar -Dsonar.login=admin -Dsonar.password=pass     <---- El que estoy usando ahora y funciona.

o

#Con Scanner (lee .properties y envía a SonarQube):

sonar-scanner -Dproject.settings=sonar-project-analysis.properties

nota:
-Si uso sonar-scanner:
Para cambiar la rama a analizar con sonarqube , editar el archivo de properties, ejemplo : sonar.branch.name=modernization
(Creo que solo esta disponible en la version de pago)

## 🔗 CÓMO SE CONECTA SONARQUBE CON LA APP

### **📁 ARCHIVO DE CONFIGURACIÓN**
`sonar-project-analysis.properties`:
```properties
sonar.projectKey=petclinic-legacy-modernization  # ID único en SonarQube
sonar.projectName=Spring PetClinic 1.5.1         # Nombre visible
sonar.sources=src/main/java                      # Donde está el código
sonar.java.binaries=target/classes              # Clases compiladas
sonar.host.url=http://localhost:9000            # Dónde está SonarQube
```

### **🔄 FLUJO DE CONEXIÓN**

1. **SonarQube corre** como servidor (puerto 9000)
2. **Scanner analiza** código local con el archivo .properties
3. **Scanner envía datos** al servidor SonarQube via HTTP
4. **SonarQube procesa** y muestra resultados en web

### **🎯 COMANDO CLAVE**
```bash

mvn sonar:sonar -Dsonar.login=admin -Dsonar.password=<'tu pass'>

O:

# Scanner lee .properties y envía a SonarQube:

sonar-scanner -Dproject.settings=sonar-project-analysis.properties(o nuestro archivo de properties)
```

### **📊 RESULTADO**
- SonarQube **NO modifica** tu código
- Solo **lee y analiza**
- Muestra **métricas de calidad** en interfaz web

**Es como un médico que examina pero no opera.**


### **🎯 OBSERVACION**
```bash
# No es necesario que la app a analizar este levantada o corriendor. SonarQube analiza el codigo.
```

## 🔍 QUÉ REVISAR EN SONARQUBE:

### **📊 PESTAÑAS IMPORTANTES:**
1. **Issues** → Vulnerabilidades y code smells específicos
2. **Measures** → Métricas técnicas (deuda, complejidad)
3. **Code** → Navegar código con problemas marcados

### **❌ PROBLEMAS COMUNES:**
- **"On new code" vacío**: No hay código nuevo (analizó todo como existente)
- **Coverage 0%**: Tests no se ejecutaron con cobertura

### **🌐 CAMBIAR IDIOMA:**
Sí, en SonarQube:
1. Click tu avatar (arriba derecha)
2. **My Account** → **General** → **Localization**
3. Cambiar **Language**

### **🌿 RAMA ANALIZADA:**
Por defecto analiza la rama **`main`/`master`**. Para cambiar:
```properties
# En sonar-project-analysis.properties
sonar.branch.name=develop
```

### **📈 COVERAGE EXPLICADO:**
- **Lines to Cover**: 39 líneas que deberían tener tests
- **Uncovered Lines**: 39 líneas SIN tests (por eso 0%)
- **"On new code"**: Se refiere a cambios recientes (vacío = todo es código existente)

**Revisá la pestaña "Issues"** - ahí están los 9 vulnerabilidades y 19 code smells específicos.

## 🔄 DIFERENCIA: SONAR-SCANNER vs MAVEN

### **📦 SONAR-SCANNER:**
- **Ejecutable independiente**
- **Lee solo** `sonar-project.properties`
- **No necesita** Maven ni `pom.xml`
- **Más liviano**

### **🍃 MAVEN:**
- **Plugin de Maven** 
- **Ignora** `sonar-project.properties` (usa config de `pom.xml`)
- **Necesita** todo el entorno Maven
- **Integrado** con build

### ❗ **PROBLEMA ACTUAL:**
Si usás `mvn sonar:sonar`, **IGNORA** tu `sonar-project-analysis.properties`. Usa la configuración del `pom.xml`.

## 🛠️ SOLUCIÓN:

### **Opción 1: Usar sonar-scanner (recomendado)**
```bash
# Instalar primero
sudo apt install sonar-scanner

# Luego ejecutar
sonar-scanner -Dproject.settings=sonar-project-analysis.properties
```

### **Opción 2: Pasar propiedades a Maven**
```bash
mvn sonar:sonar \
  -Dsonar.projectKey=petclinic-legacy-modernization \
  -Dsonar.projectName="Spring PetClinic 1.5.1" \
  -Dsonar.branch.name=develop
```

### **🔄 PARA VER CAMBIOS DE RAMA:**
No necesitás reiniciar todo. Solo re-analizar:
```bash
sonar-scanner -Dproject.settings=sonar-project-analysis.properties
```
**sonar-scanner no está en los repos de Ubuntu.** Hay que instalarlo manualmente.

## 🛠️ INSTALACIÓN RÁPIDA:

### **Opción 1: Descargar directo**
```bash
cd /tmp
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.0.2856-linux.zip
unzip sonar-scanner-cli-4.8.0.2856-linux.zip
sudo mv sonar-scanner-4.8.0.2856-linux /opt/sonar-scanner
echo 'export PATH=$PATH:/opt/sonar-scanner/bin' >> ~/.bashrc
source ~/.bashrc
```

### **Opción 2: Usar Maven con propiedades**
```bash
## 🛠️ COMANDO Maven CON PROPIEDADES Y RAMA:

```bash
cd petclinic

mvn clean compile test sonar:sonar \
  -Dsonar.projectKey=spring-petclinic-1.5.1-legacy \
  -Dsonar.projectName="Spring PetClinic Official 1.5.1 - Legacy Analysis" \
  -Dsonar.branch.name=modernization \
  -Dsonar.sources=src/main/java \
  -Dsonar.tests=src/test/java \
  -Dsonar.java.binaries=target/classes \
  -Dsonar.java.libraries=target/dependency/*.jar \
  -Dsonar.login=admin \
  -Dsonar.password=TU_PASSWORD_AQUI
```

## 📝 NOTAS:
- **`clean compile test`** → Asegura compilación y tests antes del análisis
- **`sonar.branch.name=modernization`** → Analiza esa rama específica
- **Credenciales** incluidas en el comando
- **Maven ignora** el archivo .properties cuando le pasas parámetros -D

**¿Ejecutamos este comando?** Así analizás la rama `modernization` con todas las configuraciones.
```

### **Opción 3: Snap (si tienes snap)**
```bash
sudo snap install sonar-scanner
```
**La Community Edition no soporta análisis de ramas.** Es una limitación de la versión gratuita.

## 🛠️ SOLUCIÓN:

### **Quitar la propiedad de rama:**
```bash
mvn clean compile sonar:sonar \
  -Dsonar.projectKey=spring-petclinic-1.5.1-legacy \
  -Dsonar.projectName="Spring PetClinic Official 1.5.1 - Legacy Analysis" \
  -Dsonar.sources=src/main/java \
  -Dsonar.tests=src/test/java \
  -Dsonar.java.binaries=target/classes \
  -Dsonar.login=admin \
  -Dsonar.password=TU_PASSWORD_AQUI \
  -DskipTests
```

## 📝 ALTERNATIVAS PARA RAMAS:

1. **Analizar solo `main`/`master`** (default)
2. **Cambiar el `projectKey`** por rama:
   ```properties
   sonar.projectKey=spring-petclinic-modernization-branch
   ```
3. **Usar SonarQube Developer Edition** (pago)

**La Community Edition analiza solo la rama principal.** ¿Ejecutamos sin la propiedad de rama?

## 🎯 ESCENARIO REAL DE MODERNIZACIÓN:

**Tienes RAZÓN.** En proyectos reales:

### **✅ FLUJO CORRECTO:**
1. **Master** → Código estable/producción
2. **Rama feature/modernizacion** → Donde VOS trabajás
3. **Analizás TU rama** → Para ver impacto de tus cambios

### **❌ PROBLEMA ACTUAL:**
Community Edition solo analiza `master` - inútil para desarrollo.

## 🛠️ SOLUCIONES REALES:

### **Opción 1: ProjectKey por rama**
```bash
# En TU rama "modernization":
mvn sonar:sonar \
  -Dsonar.projectKey=petclinic-modernization-$(date +%Y%m%d) \
  -Dsonar.projectName="PetClinic - Rama Modernization"
```

### **Opción 2: Developer Edition (empresas)**
- Versión paga que sí soporta ramas
- Común en empresas serias

### **Opción 3: Analizar local antes de mergear**
- Trabajás en tu rama
- Antes de mergear a master, analizás master+tu código

## 📝 EN LA PRÁCTICA:

**Para tu caso:**
- Analizá con projectKey único: `petclinic-modernization-tu-nombre`
- Así tenés "tu espacio" en SonarQube
- No interfiere con master

**¿Creás un projectKey único para tu análisis?** Ej: `petclinic-leandro-modernization`

## 🛠️ COMANDO MAVEN PARA RAMA MODERNIZATION:

```bash
mvn clean compile sonar:sonar \
  -Dsonar.projectKey=petclinic-modernization-leandro \
  -Dsonar.projectName="PetClinic - Rama Modernization (Leandro)" \
  -Dsonar.sources=src/main/java \
  -Dsonar.tests=src/test/java \
  -Dsonar.java.binaries=target/classes \
  -Dsonar.login=admin \
  -Dsonar.password=TU_PASSWORD \
  -DskipTests
```

## 🎯 ESTRATEGIA:
- **`petclinic-modernization-leandro`** → ProjectKey único para tu espacio
- Aparecerá como proyecto separado en SonarQube
- Podés analizar múltiples veces sin conflicto
- No necesitás ramas en Community Edition

**Así tenés tu "sandbox" personal** para experimentar con modernización sin afectar análisis de master.


**Tienes RAZÓN.** En el comando no especificamos la rama. 

## ❗ PROBLEMA:
El comando analiza **la rama actual del workspace** (la que tenés checkout en Git), pero SonarQube Community la muestra como "master".

## 🔍 PARA CONFIRMAR:
```bash
# Ver en qué rama estás realmente
git branch --show-current

# Debería decir: modernization
```

## 🛠️ SOLUCIÓN CORREGIDA:
Si estás en rama `modernization`, este comando SÍ la analiza:

```bash
# Ejecutar desde rama modernization
git checkout modernization

mvn clean compile sonar:sonar \
  -Dsonar.projectKey=petclinic-modernization-leandro \
  -Dsonar.projectName="PetClinic - Rama Modernization (Leandro)" \
  -Dsonar.sources=src/main/java \
  -Dsonar.tests=src/test/java \
  -Dsonar.java.binaries=target/classes \
  -Dsonar.login=admin \
  -Dsonar.password=TU_PASSWORD \
  -DskipTests
```

**El análisis es de tu rama actual**, aunque SonarQube diga "master". Es una limitación visual, no funcional.

-Ese comando analiza la rama en la que estoy parado, aunque en la interfaz grafica diga "master" o "main"

¿Estás en la rama `modernization` actualmente?


**Exacto. Esa es la prueba perfecta.**

## 🧪 PRUEBA RÁPIDA:

### **1. Hacer cambio mínimo en src/**
```bash
# Agregar comentario en cualquier clase Java
echo "// CAMBIO PRUEBA RAMA MODERNIZATION - $(date)" >> src/main/java/org/springframework/samples/petclinic/model/BaseEntity.java
```

### **2. Re-analizar**
```bash
mvn clean compile sonar:sonar \
  -Dsonar.projectKey=petclinic-modernization-leandro \
  -Dsonar.projectName="PetClinic - Rama Modernization (Leandro)" \
  -Dsonar.sources=src/main/java \
  -Dsonar.login=admin \
  -Dsonar.password=TU_PASSWORD \
  -DskipTests
```

### **3. Verificar en SonarQube**
- Buscar tu comentario en "Code"
- Ver última fecha de análisis

**Así confirmás que sí está analizando tu rama actual**, aunque diga "master".

## 🔧 SONARQUBE: DETECCIÓN vs CORRECCIÓN

### **❌ LO QUE NO HACE:**
- **NO corrige** código automáticamente
- **NO modifica** tus archivos
- **NO hace refactor** por sí solo

### **✅ LO QUE SÍ HACE:**
- **DETECTA** problemas (bugs, smells, vulnerabilidades)
- **EXPLICA** cada issue con ejemplos
- **SUGIERE** fixes (pero no los aplica)
- **PRIORIZA** por severidad

## 🛠️ FLUJO DE TRABAJO TÍPICO:

### **1. Analizar issues en SonarQube**
- Click en proyecto → "Issues"
- Filtrar por: Blocker, Critical, Major
- Leer explicación de cada problema

### **2. Corregir manualmente en tu IDE**
```bash
# Ejemplo issues comunes:
- "Remove this unused import" → Borrar import
- "Use isEmpty() instead of size() == 0" → Refactor código
- "Add a nested @author tag" → Agregar documentación
```

### **3. Re-analizar después de correcciones**
```bash
mvn sonar:sonar ... (mismo comando)
```

## 📝 EJEMPLO PRÁCTICO:

**Si SonarQube dice:**
- `"Vulnerability: Hard-coded password"`
- **TÚ debes:** Buscar en código y reemplazar por variable de entorno

**SonarQube es como un médico que diagnostica pero no opera.** Tú eres el cirujano.
