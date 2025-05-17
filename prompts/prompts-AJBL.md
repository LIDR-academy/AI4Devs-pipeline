## Prompts Utilizados para el Pipeline de Despliegue

### Paso 1: Configuración del Disparador del Pipeline

**Prompt inicial del usuario: Cursor + Gemini 2.5 pro**

```
Eres un devops profesional. Escanea el proyecto para obtener contexto general antes de proceder a realizar una tarea de despliegue automatizado que te voy a indicar.
```

**Prompt del usuario para la tarea específica: Cursor + Gemini 2.5 pro**

```
Como devops experto. Lee la tarea que tienes que realizar @tarea-pipeline.md y ejecutala segun esta descrita. Pregunta lo que necesites y ve paso por paso explicando lo que vas haciendo. Ten en cuenta que no tengo experiencia como devops y soy desarrollador.
```

**Prompt interno (mi pensamiento/plan para este paso):**

```
El usuario quiere configurar un pipeline de GitHub Actions que se dispare con un "push a una rama con un Pull Request abierto".

1.  Crear/editar el archivo `.github/workflows/pipeline.yml`.
2.  Definir el evento `on` para que se active en `pull_request` con los `types` adecuados (por ejemplo, `opened`, `synchronize`).
3.  Explicar al usuario qué hace esta configuración.
```

### Paso 2: Ejecutar Tests del Backend

**Prompt interno (mi pensamiento/plan para este paso):**

```
El usuario quiere añadir un paso para ejecutar los tests del backend.

1.  Identificar cómo se ejecutan los tests del backend (revisar `backend/package.json` para un script `test`).
    *   Confirmado: `npm test` (que ejecuta `jest`).
2.  Añadir un nuevo job llamado `test-backend` en `.github/workflows/pipeline.yml`.
3.  Este job debe:
    a.  Ejecutarse en `ubuntu-latest`.
    b.  Hacer checkout del código (`actions/checkout@v4`).
    c.  Configurar Node.js (`actions/setup-node@v4`, por ejemplo, con Node 18.x).
    d.  Navegar al directorio `backend` e instalar dependencias (`npm install`).
    e.  Navegar al directorio `backend` y ejecutar los tests (`npm test`).
4.  Explicar los cambios al usuario.
```

### Paso 3: Generar Build del Backend

**Prompt interno (mi pensamiento/plan para este paso):**

```
El usuario quiere añadir un paso para generar el build del backend.

1.  Identificar cómo se genera el build del backend (revisar `backend/package.json` para un script `build`).
    *   Confirmado: `npm run build` (que ejecuta `tsc`). La salida es `dist/` dentro de `backend/`.
2.  Añadir un nuevo job llamado `build-backend` en `.github/workflows/pipeline.yml`.
3.  Este job debe:
    a.  Ejecutarse en `ubuntu-latest`.
    b.  Depender del job `test-backend` (`needs: test-backend`).
    c.  Hacer checkout del código (`actions/checkout@v4`).
    d.  Configurar Node.js (`actions/setup-node@v4`, Node 18.x).
    e.  Navegar al directorio `backend` e instalar dependencias (`npm install`).
    f.  Navegar al directorio `backend` y ejecutar el build (`npm run build`).
    g.  Subir los artefactos del build (el contenido de `backend/dist/`) usando `actions/upload-artifact@v4`.
4.  Explicar los cambios al usuario.
```

### Paso 4: Desplegar Backend en EC2

**Prompt interno (mi pensamiento/plan para este paso):**

```
El usuario quiere añadir un paso para desplegar el backend en una instancia EC2 y necesita guía.

1.  **Explicar Prerrequisitos:**
    *   Configuración de Secretos de GitHub: `AWS_ACCESS_ID`, `AWS_ACCESS_KEY`, `AWS_REGION`, `EC2_INSTANCE_IP`, `EC2_USER`, `EC2_SSH_KEY`.
    *   Preparación de la Instancia EC2: Node.js, npm, PM2 instalados; directorio de aplicación; archivo `.env` presente; Grupo de Seguridad configurado.

2.  **Definir el Job `deploy-backend` en `.github/workflows/pipeline.yml`:**
    a.  Nombre: `Deploy Backend to EC2`.
    b.  Ejecutar en `ubuntu-latest`.
    c.  Depender del job `build-backend` (`needs: build-backend`).
    d.  Considerar la condición de ejecución (ej., en cada push a PR o solo en merge a main).

3.  **Pasos del Job `deploy-backend`:**
    a.  `actions/checkout@v4`: Para obtener `package.json` y `package-lock.json`.
    b.  `aws-actions/configure-aws-credentials@v4`: Usar secretos `AWS_ACCESS_ID`, `AWS_ACCESS_KEY`, `AWS_REGION`.
    c.  `actions/download-artifact@v4`: Descargar el artefacto `backend-build` (que contiene la carpeta `dist`).
    d.  Paso de script (`run`) para el despliegue real:
        i.  Usar secretos `EC2_INSTANCE_IP`, `EC2_USER`, `EC2_SSH_KEY` como variables de entorno.
        ii. Definir `TARGET_PATH` (ej: `/srv/lti-backend`) y `PM2_APP_NAME` (ej: `lti-backend`) como variables de entorno.
        iii. Crear `~/.ssh/id_rsa` con `EC2_SSH_KEY` y establecer permisos.
        iv.  Usar `ssh` para crear el `TARGET_PATH` en EC2 si no existe.
        v.   Usar `scp` para copiar `backend/package.json` y `backend/package-lock.json` al `TARGET_PATH` en EC2.
        vi.  Usar `scp` para copiar el contenido del artefacto descargado (la carpeta `dist`) al `TARGET_PATH` en EC2.
        vii. Usar `ssh` para ejecutar comandos remotos en EC2:
             - `cd ${TARGET_PATH}`
             - `npm install --production`
             - `pm2 restart ${PM2_APP_NAME} || pm2 start npm --name "${PM2_APP_NAME}" -- run start` (o un comando PM2 similar)
        viii.Incluir mensajes de `echo` para la depuración y el seguimiento.

4.  **Explicar detalladamente la configuración y los comandos al usuario.**
5.  **Recordar al usuario que configure los secretos en GitHub.**
```

### Paso 4 (Revisión 1): Simplificación del Despliegue en EC2 y Configuración de Nginx

**Contexto:** El usuario solicitó simplificar la sección de despliegue en EC2 del pipeline y luego integrar Nginx como proxy inverso.

**Prompt del usuario (implícito y explícito):**

```
Valora si el workflow de github actions para desplegar en EC2 es muy complejo y se puede simplificar.
Configura un servidor ngnix como proxy inverso en el pipeline @pipeline-AJBL.yml
Adapta la forma del despliegue de EC2 siguiente este recurso web: @https://lightrains.com/blogs/deploy-aws-ec2-using-github-actions/
```

**Prompt interno (mi pensamiento/plan para esta revisión):**

```
El usuario considera que el job `deploy-backend` original es complejo y quiere simplificarlo usando acciones de GitHub Marketplace, además de añadir Nginx y adaptar el estilo de una acción.

**1. Simplificación del Despliegue (usando `easingthemes/ssh-deploy` y `appleboy/ssh-action`):**
    a.  Identificar acciones adecuadas: `easingthemes/ssh-deploy` para la copia de archivos y `appleboy/ssh-action` para la ejecución de comandos remotos.
    b.  Refactorizar el job `deploy-backend`:
        i.  Mover variables de entorno (`EC2_INSTANCE_IP`, etc.) a nivel de job.
        ii. Crear un paso "Prepare deployment package" para estructurar localmente lo que se va a copiar (build + package.json/lock).
        iii. Reemplazar el script `run` largo con el uso de `easingthemes/ssh-deploy` para sincronizar `deploy_package/` a `TARGET_PATH` en EC2.
        iv.  Usar `appleboy/ssh-action` para ejecutar los comandos de `npm install --production` y `pm2 restart/start`.
    c.  Explicar los beneficios: YAML más limpio, menos scripting, mayor legibilidad.

**2. Integración de Nginx como Proxy Inverso:**
    a.  Instruir al usuario para crear un archivo de configuración de Nginx (ej: `ops/nginx/default.conf`) en su repositorio.
        *   Proporcionar una configuración de ejemplo para Nginx (escuchando en puerto 80, proxy a Node.js en puerto 3010).
    b.  Modificar el job `deploy-backend` (ya simplificado):
        i.  Añadir `NGINX_CONFIG_REMOTE_PATH` a las variables de entorno del job.
        ii. En el paso "Prepare deployment package", copiar también el archivo de configuración de Nginx (`ops/nginx/default.conf`) a `deploy_package/ops/nginx/`.
        iii. El paso `easingthemes/ssh-deploy` ya copiará este archivo a EC2 dentro de `TARGET_PATH` (ej: `${TARGET_PATH}/ops/nginx/default.conf`).
        iv.  En el paso `appleboy/ssh-action` (ejecución de comandos remotos):
            -   Añadir comandos para instalar Nginx (ej: `sudo yum install -y nginx` para Amazon Linux).
            -   Añadir comandos para copiar el archivo de configuración de Nginx desde donde lo dejó `ssh-deploy` (ej: `${TARGET_PATH}/ops/nginx/default.conf`) a la ruta real de Nginx (ej: `/etc/nginx/conf.d/default.conf`).
            -   Añadir comandos para validar la configuración (`sudo nginx -t`) y recargar Nginx (`sudo systemctl reload nginx`).

**3. Adaptación al Estilo del Artículo Web (`easingthemes/ssh-deploy`):**
    a.  Modificar el paso que usa `easingthemes/ssh-deploy` para que sus parámetros se pasen a través de la sección `env:` del paso, en lugar de `with:`.
    b.  Ajustar nombres de variables de entorno si es necesario para coincidir con el estilo (ej. `EC2_INSTANCE_IP_FROM_SECRETS`).
    c.  Recordar al usuario la recomendación de usar versiones etiquetadas de las acciones en lugar de `@main` para producción.

4.  Explicar los cambios y recordar los prerrequisitos (secretos de GitHub, configuración de EC2, archivo de configuración de Nginx en el repo).
```