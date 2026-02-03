# Conversación: CI/CD con GitHub Actions para Node.js y Prisma

Running on: macOS
Workspace: AI4Devs-pipeline

## Prompt 1
**Usuario:**
Eres un experto en ci cd con github actions y proyectos en node y prisma.

Quiero que me expliques paso a paso cuales serían los pasos en github actions para que, cuando se abre una PR a main se ejecute lo siguiente de forma automática:
- ejecutar los tests unitarios del proyecto backend
- hacer build
- desplegar los cambios en una instacia ec2 únicamente cuando se mergea el código.
- reiniciar la aplicación 

Hazlo siguiendo las prácticas recomendadas.

No crees ningún archivo de pipeline todavía. Quiero una explicación detallada de los pasos, su objetivo y cómo hacerlo.

## Respuesta 1
**GitHub Copilot:**
¡Claro que sí! Como experto en CI/CD, Node.js y Prisma, te explicaré detalladamente cómo diseñar este flujo en GitHub Actions siguiendo las mejores prácticas.

Para mantener el proceso ordenado y seguro, lo ideal es dividir conceptualmente el trabajo en dos flujos (o "files") distintos, aunque puedan convivir en un mismo repositorio: uno para **Integración (CI)** y otro para **Despliegue (CD)**.

Aquí tienes el plan paso a paso:

### Fase 1: Integración Continua (CI)
**Objetivo:** Validar que el código nuevo no rompe nada antes de ser aceptado.
**Disparador (Trigger):** `pull_request` apuntando a la rama `main`.

Los pasos dentro de este "Job" serían:

1.  **Checkout del código**: Utilizar `actions/checkout`.
2.  **Configurar el entorno de Node.js**: Usar `actions/setup-node` (con caching).
3.  **Instalar dependencias**: Ejecutar `npm ci` para instalaciones limpias y deterministas.
4.  **Generar Cliente de Prisma**: Ejecutar `npx prisma generate`. Necesario para los tipos de TypeScript.
5.  **Ejecutar Tests Unitarios**: `npm run test` (Jest).
6.  **Construir (Build)**: `npm run build` (TypeScript check).

### Fase 2: Despliegue Continuo (CD)
**Objetivo:** Llevar los cambios a producción de forma segura.
**Disparador (Trigger):** `push` a la rama `main`.

1.  **Checkout del código**.
2.  **Conexión SSH y Despliegue**: Usar `appleboy/ssh-action`.
    *   **En el servidor:**
        1.  `git pull origin main`
        2.  `npm ci --production`
        3.  `npx prisma generate`
        4.  `npx prisma migrate deploy` (Migraciones seguras en producción).
        5.  `npm run build`
        6.  `pm2 reload backend` (Zero-downtime reload).

### Resumen de Secretos Necesarios
*   `DATABASE_URL`
*   `EC2_HOST`, `EC2_USERNAME`, `EC2_SSH_KEY`

---

## Prompt 2
**Usuario:**
si, crea el pipeline en un archivo pipeline.yml en la carpeta .github/workflows

Hazme cualquier pregunta que haga falta aclarar

## Respuesta 2
**GitHub Copilot:**
He creado el archivo `.github/workflows/pipeline.yml` con la siguiente configuración:

```yaml
name: Backend CI/CD Pipeline

on:
  push:
    branches: [ "main" ]
    paths:
      - 'backend/**'
  pull_request:
    branches: [ "main" ]
    paths:
      - 'backend/**'

jobs:
  continuous-integration:
    name: CI - Test & Build
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./backend

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: backend/package-lock.json

      - name: Install Dependencies
        run: npm ci

      - name: Generate Prisma Client
        run: npx prisma generate
        env:
          DATABASE_URL: "postgresql://user:password@localhost:5432/mydb" 

      - name: Run Unit Tests
        run: npm run test

      - name: Build Application
        run: npm run build

  continuous-deployment:
    name: CD - Deploy to EC2
    needs: continuous-integration
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    
    steps:
      - name: Deploy via SSH
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.EC2_HOST }}
          username: ${{ secrets.EC2_USERNAME }}
          key: ${{ secrets.EC2_SSH_KEY }}
          script: |
            APP_DIR="/home/ubuntu/AI4Devs-pipeline"
            BACKEND_DIR="$APP_DIR/backend"
            PM2_PROCESS_NAME="backend-api"

            echo "🚀 Iniciando despliegue..."

            if [ -d "$APP_DIR" ]; then
              cd $APP_DIR
              git pull origin main
            else
              echo "❌ Error: El directorio $APP_DIR no existe."
              exit 1
            fi

            cd $BACKEND_DIR
            npm ci --production
            npx prisma generate
            npx prisma migrate deploy
            npm run build

            if pm2 list | grep -q "$PM2_PROCESS_NAME"; then
                pm2 reload $PM2_PROCESS_NAME
            else
                pm2 start dist/index.js --name $PM2_PROCESS_NAME
            fi
```

### Instrucciones Adicionales
1.  **Secretos**: Se debe configurar `EC2_HOST`, `EC2_USERNAME`, `EC2_SSH_KEY` en el repositorio.
2.  **Servidor**: Se asume que el proyecto ya existe en `/home/ubuntu/AI4Devs-pipeline` y que tiene un archivo `.env` con la `DATABASE_URL` real.

---

