# 🛠️ Herramientas Utilizadas

* IDE: CursorAI
* Modelo: Claude Sonnet 4

# 🚀 Desarrollo del Ejercicio

## 3. Ejecución: Prompts

### Prompt #1: Creación de pipeline

```markdown
Eres un Devops engineer y se te ha solicitado crear un pipeline usando Github Actions para desplegar una aplicación de React en una instancia EC2. Para ello, debes crear el archivo .yml que ejecutará el pipeline cuando se genere una pull request. Ten en cuenta que este proyecto es un monorepo y que tiene el frontend y el backend en carpetas independientes, donde cada una de las capas mensionadas tienen dependencias que deben ser instaladas antes de construir y desplegar. Te dejo el listado de secretos que ya tengo creados en la configuración de mi repositorio para 
mayor claridad:

* AWS_ACCESS_ID
* AWS_ACCESS_KEY
* EC2_INSTANCE
* EC2_SSH_PRIVATE_KEY
* EC2_USER
```

### Prompt #2: Explicación del pipeline construido

```marddown
soy amateur en esto de devops e integración y despliegue contínuo, podrías por favor simplifar ese pipeline pero que al mismo tiempo sea funcional y cumpla su objetivo? También agrega la ínima documentación que me ayude a entender cada paso del job
```

### Prompt #3: Problemas con la activación del action en GitHub

```marddown
mira mi @.github/workflows/ci.yml a pesar que tengo branches: [main, develop, solved-jairopolo] y hacer un push de un commit, no se activó el action, que pasa?
```

### Prompt #4: Error en la ejecución del primer intento del job

```markdown
tengo el siguiente error en el step: 🧪 Run ${{ matrix.component }} tests para el frontend
  Run cd frontend

  > frontend@0.1.0 test
  > jest --config jest.config.js --watchAll=false --passWithNoTests --coverage

  Error: Can't find a root directory while resolving a config file path.
  Provided path to resolve: jest.config.js
  cwd: 
  /home/runner/work/AI4Devs-pipeline-solved-jairopolo/AI4Devs-pipeline-solved-jairopolo/frontend
      at resolveConfigPath (/home/runner/work/AI4Devs-pipeline-solved-jairopolo/AI4Devs-pipeline-s
  olved-jairopolo/frontend/node_modules/jest-config/build/resolveConfigPath.js:134:11)
      at readConfig (/home/runner/work/AI4Devs-pipeline-solved-jairopolo/AI4Devs-pipeline-solved-j
  airopolo/frontend/node_modules/jest-config/build/index.js:220:49)
      at readConfigs (/home/runner/work/AI4Devs-pipeline-solved-jairopolo/AI4Devs-pipeline-solved-
  jairopolo/frontend/node_modules/jest-config/build/index.js:420:32)
      at runCLI (/home/runner/work/AI4Devs-pipeline-solved-jairopolo/AI4Devs-pipeline-solved-jairo
  polo/frontend/node_modules/@jest/core/build/cli/index.js:133:29)
      at Object.run (/home/runner/work/AI4Devs-pipeline-solved-jairopolo/AI4Devs-pipeline-solved-j
  airopolo/frontend/node_modules/jest-cli/build/cli/index.js:155:62)
      at Object.<anonymous> (/home/runner/work/AI4Devs-pipeline-solved-jairopolo/AI4Devs-pipeline-
  solved-jairopolo/frontend/node_modules/jest-cli/bin/jest.js:16:17)
      at Module._compile (node:internal/modules/cjs/loader:1364:14)
      at Module._extensions..js (node:internal/modules/cjs/loader:1422:10)
      at Module.load (node:internal/modules/cjs/loader:1203:32)
      at Module._load (node:internal/modules/cjs/loader:1019:12)
  Error: Process completed with exit code 1.
```

### Prompt #5: Error en la ejecución del segundo intento del job

```markdown
ahora tengo este error en la ejecución del job: Current runner version: '2.328.0'                 
   Runner Image Provisioner                                                                          
   Operating System                                                                                  
   Runner Image                                                                                      
   GITHUB_TOKEN Permissions                                                                          
   Secret source: Actions                                                                            
   Prepare workflow directory                                                                        
   Prepare all required actions                                                                      
   Getting action download info                                                                      
   Error: This request has been automatically failed because it uses a deprecated version of         
   `actions/upload-artifact: v3`. Learn more:                                                        
   https://github.blog/changelog/2024-04-16-deprecation-notice-v3-of-the-artifact-actions/  
```

### Prompt #6: Error en la ejecución del tercer intento del job

```markdown
ahora tengo este error en el paso: ⚙️ Setup Node.js: Error: Dependencies lock file is not found in /home/runner/work/AI4Devs-pipeline-solved-jairopolo/AI4Devs-pipeline-solved-jairopolo. Supported file patterns: package-lock.json,npm-shrinkwrap.json,yarn.lock  
```

```markdown
ahora el job de Deploy Frontend to EC2 me dice: Run rsync -avz --delete \                         
     rsync -avz --delete \                                                                           
       -e "ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no" \                                       
       deploy/frontend/ \                                                                            
       ***@***:/var/www/html/                                                                        
     shell: /usr/bin/bash -e {0}                                                                     
     env:                                                                                            
       NODE_VERSION: 18                                                                              
       AWS_DEFAULT_REGION: us-east-2                                                                 
   sending incremental file list                                                                     
   rsync: [Receiver] mkdir "/var/www/html" failed: No such file or directory (2)                     
   rsync error: error in file IO (code 11) at main.c(791) [Receiver=3.4.0]                           
   Error: Process completed with exit code 11.
```

### Prompt #7: Generación de PR

```markdown
Actúa como un desarrollador senior experto en documentación técnica. 

Analiza el contexto disponible del proyecto y genera el cuerpo completo de un Pull Request para la rama actual. 

**Instrucciones de análisis automático:**
- Examina el archivo @execution-plan.md para extraer historias de usuario desarrolladas
- Analiza los archivos modificados/creados mediante git diff para entender los cambios
- Identifica el stack tecnológico basado en la estructura del proyecto
- Extrae ejemplos de respuesta de archivos de test o documentación API disponibles
- Revisa commits recientes para entender el alcance del desarrollo

**Estructura requerida:**

# Pull Request: [Título auto-generado basado en las funcionalidades]

## 📋 Resumen
[Descripción concisa de 2-3 líneas de los incrementos funcionales desarrollados]

## 🚀 Historia de Usuario #[N]: [Nombre de la funcionalidad]

### 📝 Descripción de la Historia de Usuario
[Formato: Como... Quiero... Para que... - extraído del execution plan]

### 🔄 Diagrama de Secuencia
[Diagrama auto-generado mostrando el flujo de interacción entre actores, frontend, backend y base de datos en formato mermaid]

### 🏗️ Implementación Técnica
**📁 Archivos creados:**
- [Lista auto-generada de archivos nuevos]

**🔧 Archivos modificados:**
- [Lista auto-generada con descripción de cambios principales]

### 🧪 Evidencia de Pruebas de Aceptación
[Tabla con casos de prueba ejecutados y resultados - extraer de tests disponibles]

### 💻 Ejemplo de Consumo
[Ejemplo real de request/response si está disponible]

---

[Repetir sección por cada historia de usuario implementada]

## ✅ Criterios de Aceptación Completados
- [ ] [Auto-generar checkboxes basado en las funcionalidades implementadas]

**Estado:** ✅ READY FOR REVIEW

**Restricciones:**
- Sé conciso, no verboso
- Enfócate en indicadores críticos de incrementos funcionales
- Incluye solo evidencia relevante de pruebas de aceptación
- Usa emojis para mejorar legibilidad
- Si no encuentras información específica, omítela en lugar de inventarla
- SIEMPRE incluye diagrama de secuencia Mermaid para cada historia de usuario (es crítico para comprensión del equipo)

Genera el cuerpo del PR analizando automáticamente el contexto disponible.
```