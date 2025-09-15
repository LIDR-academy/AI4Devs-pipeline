IDE: Cursor
Agente: Auto

# 🚀 **PROMPTS  - Sistema LTI-ATS**

## **PROMPT 1: Conexión a Amazon EC2**

**Role**: DevOps Senior con experiencia en AWS EC2 y conectividad SSH.

**Context & Situation**: Necesitas conectarte a una instancia EC2 de Amazon para verificar la conectividad y preparar el entorno para despliegue.

**Primary Task**: Establecer conexión SSH segura a la instancia EC2 y verificar que no haya errores de conectividad.

**Critical Success Criteria**:
- ✅ Conexión SSH exitosa a la instancia EC2
- ✅ Verificación de que no hay errores de conectividad
- ✅ Validación de permisos y configuración de la llave

**Step-by-Step Execution Framework**:

# PHASE 1: Verificación de la llave privada
# Verificar que el archivo .pem existe y tiene los permisos correctos
ls -la AI4Devs-pipeline.pem
chmod 400 AI4Devs-pipeline.pem

# PHASE 2: Conexión SSH
# Conectarse a la instancia EC2 usando la llave privada
ssh -i "AI4Devs-pipeline.pem" ec2-user@ec2-18-218-63-89.us-east-2.compute.amazonaws.com

# PHASE 3: Verificación de conectividad
# Verificar que la conexión es estable y no hay errores
# - Verificar que se puede ejecutar comandos básicos
# - Verificar que no hay timeouts
# - Verificar que la instancia responde correctamente

**Troubleshooting Protocols**:
- **Error de permisos**: `chmod 400 AI4Devs-pipeline.pem`
- **Error de conectividad**: Verificar Security Groups y VPC
- **Error de autenticación**: Verificar que la llave corresponde a la instancia
- **Timeout**: Verificar que la instancia esté en estado "Running"

---

## **PROMPT 2: Pipeline de GitHub Actions para EC2**

**Role**: Experto en infraestructura de despliegue en EC2 y GitHub Actions.

**Context & Situation**: Necesitas crear un pipeline completo en GitHub Actions que se dispare con un push a una rama con Pull Request abierto y realice tests, build y despliegue del backend en EC2.

**Primary Task**: Configurar workflow de GitHub Actions que ejecute:
- Tests de backend
- Generación del build del backend
- Despliegue del backend en EC2

**Critical Success Criteria**:
- ✅ Workflow configurado en `.github/workflows/pipeline.yml`
- ✅ Tests de backend ejecutándose correctamente
- ✅ Build del backend generándose exitosamente
- ✅ Despliegue en EC2 funcionando
- ✅ Pipeline se dispara con push a rama con PR abierto
- ✅ Rama `pipeline-solved-sp` creada

**Step-by-Step Execution Framework**:

# PHASE 1: Creación de la rama
# Crear la rama pipeline-solved-sp
git checkout -b pipeline-solved-sp

# PHASE 2: Configuración del workflow
# Crear archivo .github/workflows/pipeline.yml
# - Configurar trigger para push a rama con PR abierto
# - Configurar jobs para tests, build y deploy
# - Usar actions/checkout@v4
# - Usar appleboy/ssh-action@master para deploy

# PHASE 3: Configuración de secrets
# Configurar los siguientes secrets en GitHub:
# - EC2_PRIVATE_KEY: Contenido del archivo .pem
# - EC2_HOST: ec2-18-218-63-89.us-east-2.compute.amazonaws.com
# - EC2_USERNAME: ec2-user
# - EC2_TARGET_DIR: /home/ec2-user/lti-app

# PHASE 4: Pruebas locales
# Verificar que los tests y build funcionan localmente
cd backend
npm test
npm run build

**Technical Implementation Details**:

**Workflow Structure**:
```yaml
name: LTI Full-Stack CI/CD

on:
  pull_request:
    branches:
      - main
      - pipeline-solved-sp

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      
      - name: Install Backend Dependencies
        run: |
          cd backend
          npm install
      
      - name: Run Backend Tests
        run: |
          cd backend
          npm test
      
      - name: Build Backend
        run: |
          cd backend
          npm run build
      
      - name: Deploy to EC2
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.EC2_HOST }}
          username: ${{ secrets.EC2_USERNAME }}
          key: ${{ secrets.EC2_PRIVATE_KEY }}
          script: |
            # Script de despliegue en EC2
```

**Expected Deliverables**:
- *** Create File: `.github/workflows/pipeline.yml`
- *** Update File: `PIPELINE_DOCUMENTATION.md`
- **Rama**: `pipeline-solved-sp` creada y configurada

---

## **PROMPT 3: Configuración Avanzada del Pipeline**

**Role**: Experto en GitHub Actions y despliegue automatizado.

**Context & Situation**: Necesitas adaptar el archivo de pipeline existente con las mejores prácticas y configuraciones avanzadas para GitHub Actions.

**Primary Task**: Mejorar el pipeline existente implementando:
- Definición correcta de jobs
- Uso de actions/checkout@v4 (actualizado desde v2)
- Configuración de easingthemes/ssh-deploy
- Configuración de secrets de GitHub
- Trigger solo en push a rama específica

**Critical Success Criteria**:
- ✅ Jobs definidos correctamente con status reports individuales
- ✅ actions/checkout@v4 implementado
- ✅ easingthemes/ssh-deploy configurado correctamente
- ✅ Secrets de GitHub configurados
- ✅ Trigger configurado para rama pipeline-solved-sp
- ✅ Indentación YAML corregida
- ✅ Espacios en blanco eliminados

**Step-by-Step Execution Framework**:

# PHASE 1: Análisis del pipeline existente
# Revisar el archivo .github/workflows/pipeline.yml actual
# Identificar problemas de indentación y espacios en blanco
# Verificar configuración de secrets

# PHASE 2: Corrección de YAML
# Corregir indentación en líneas 12, 16, 23, 27, 31, 37, 41
# Eliminar espacios en blanco al final de líneas
# Normalizar espaciado en steps

# PHASE 3: Actualización de actions
# Actualizar actions/checkout@v2 a actions/checkout@v4
# Corregir indentación de listas bajo steps
# Verificar compatibilidad con nuevos runners

# PHASE 4: Configuración de secrets
# Verificar que los secrets estén configurados:
# - EC2_SSH_KEY: Archivo .pem
# - HOST_DNS: ec2-18-218-63-89.us-east-2.compute.amazonaws.com
# - USERNAME: ec2-user
# - TARGET_DIR: /home/ec2-user/lti-app

**Technical Implementation Details**:

**Secrets Configuration**:
```
EC2_SSH_KEY: Contenido completo del archivo AI4Devs-pipeline.pem
HOST_DNS: ec2-18-218-63-89.us-east-2.compute.amazonaws.com
USERNAME: ec2-user
TARGET_DIR: /home/ec2-user/lti-app
```

**YAML Structure**:
```yaml
name: LTI Full-Stack CI/CD

on:
  push:
    branches:
      - pipeline-solved-sp

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout the files
        uses: actions/checkout@v4
      
      - name: Deploy to Server
        uses: easingthemes/ssh-deploy@main
        env:
          SSH_PRIVATE_KEY: ${{ secrets.EC2_SSH_KEY }}
          REMOTE_HOST: ${{ secrets.HOST_DNS }}
          REMOTE_USER: ${{ secrets.USERNAME }}
          TARGET: ${{ secrets.TARGET_DIR }}
```

**Expected Deliverables**:
- *** Update File: `.github/workflows/pipeline.yml`
- **Correcciones**: Indentación YAML, espacios en blanco, actions actualizadas
- **Verificación**: Pipeline funcional y sin errores de linting

---

## **PROMPT 4: Correcciones Finales del Pipeline**

**Role**: Especialista en GitHub Actions y corrección de errores de linting.

**Context & Situation**: Necesitas aplicar correcciones finales al pipeline para eliminar errores de linting y mejorar la calidad del código YAML.

**Primary Task**: Aplicar correcciones específicas:
- Fix YAML indentation y trailing spaces
- Upgrade checkout action a v4
- Corregir indentación de listas bajo steps
- Eliminar espacios en blanco en líneas específicas

**Critical Success Criteria**:
- ✅ YAML sin errores de linting
- ✅ Indentación correcta en todos los steps
- ✅ Espacios en blanco eliminados
- ✅ actions/checkout@v4 implementado
- ✅ Indentación de listas corregida

**Step-by-Step Execution Framework**:

# PHASE 1: Identificación de problemas
# Revisar errores de linting en el archivo YAML
# Identificar líneas con problemas de indentación
# Identificar líneas con espacios en blanco

# PHASE 2: Corrección de indentación
# Corregir indentación en líneas 12, 16, 23, 27, 31, 37, 41
# Normalizar espaciado en todos los steps
# Verificar consistencia de indentación

# PHASE 3: Eliminación de espacios en blanco
# Eliminar trailing spaces en líneas problemáticas
# Verificar que no queden espacios al final de líneas
# Limpiar formato del archivo

# PHASE 4: Actualización de actions
# Actualizar actions/checkout@v2 a actions/checkout@v4
# Corregir indentación de listas bajo steps
# Verificar compatibilidad con nuevos runners

**Technical Implementation Details**:

**Líneas a corregir**:
- Línea 12: Indentación de steps
- Línea 16: Espacios en blanco
- Línea 23: Indentación de uses
- Línea 27: Espacios en blanco
- Línea 31: Indentación de with
- Línea 37: Espacios en blanco
- Línea 41: Indentación de listas

**YAML corregido**:
```yaml
name: LTI Full-Stack CI/CD

on:
  push:
    branches:
      - pipeline-solved-sp

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout the files
        uses: actions/checkout@v4
      
      - name: Deploy to Server
        uses: easingthemes/ssh-deploy@main
        env:
          SSH_PRIVATE_KEY: ${{ secrets.EC2_SSH_KEY }}
          REMOTE_HOST: ${{ secrets.HOST_DNS }}
          REMOTE_USER: ${{ secrets.USERNAME }}
          TARGET: ${{ secrets.TARGET_DIR }}
```

**Expected Deliverables**:
- *** Update File: `.github/workflows/pipeline.yml`
- **Correcciones aplicadas**: Indentación, espacios en blanco, actions actualizadas
- **Verificación**: Archivo sin errores de linting