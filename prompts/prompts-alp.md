# Prompts utilizados para generar el pipeline CI/CD

Este fichero documenta los prompts empleados para generar cada etapa del workflow `.github/workflows/pipeline.yml`.

---

## Prompt 1 – Tests del backend

**Objetivo:** Generar el job `test` del workflow que ejecuta los tests de Jest del backend TypeScript.

**Prompt:**

> Eres un ingeniero DevOps senior especializado en GitHub Actions y Node.js/TypeScript.
>
> Genera el job `test` para un workflow de GitHub Actions que ejecute los tests Jest de un
> backend TypeScript (Express + Prisma). El job debe:
>
> - Correr en `ubuntu-latest`.
> - Usar `actions/checkout@v4` y `actions/setup-node@v4` con Node.js 20 y caché npm
>   apuntando a `backend/package-lock.json`.
> - Fijar el `working-directory` a `backend/` para todos los pasos.
> - Ejecutar `npm ci` para instalar dependencias.
> - Ejecutar `npx prisma generate` antes de los tests (los tests mockean Prisma pero el
>   compilador TypeScript necesita los tipos generados).
> - Ejecutar `npm test` para lanzar Jest.
> - Añadir comentarios autoexplicativos en YAML.
> - No requerir una base de datos real (los tests usan `jest.mock('@prisma/client')`).
>
> Restricciones: versiones fijas en todas las actions; ningún secreto impreso en consola.

**Resultado:** Job `test` en `.github/workflows/pipeline.yml`.

---

## Prompt 2 – Generación del build del backend

**Objetivo:** Generar el job `build` que compila TypeScript a JavaScript y depende del job de tests.

**Prompt:**

> Basándote en el job `test` anterior, genera el job `build` para el mismo workflow.
> El job debe:
>
> - Declarar `needs: test` para que solo se ejecute si los tests pasan.
> - Repetir el setup de Node.js 20 con caché npm (los jobs de GitHub Actions son
>   independientes y no comparten filesystem).
> - Ejecutar `npm ci`, `npx prisma generate` y `npm run build` (que internamente llama a `tsc`).
> - El resultado del build se escribe en `backend/dist/` según el `outDir` del `tsconfig.json`.
> - Añadir un comentario explicando qué hace `npm run build`.
>
> Restricciones: mismas versiones de actions que el job anterior; working-directory heredado
> del `defaults` del workflow.

**Resultado:** Job `build` en `.github/workflows/pipeline.yml`.

---

## Prompt 3 – Despliegue del backend en EC2

**Objetivo:** Generar el job `deploy` que despliega el backend en una instancia EC2 vía SSH.

**Prompt:**

> Genera el job `deploy` para el workflow GitHub Actions que:
>
> - Declare `needs: build` para ejecutarse solo si el build pasa.
> - Use `appleboy/ssh-action@v1.0.3` (versión fija) para conectarse por SSH al EC2.
> - Lea el host, usuario y clave privada de los secretos:
>   `EC2_INSTANCE`, `EC2_USER`, `EC2_SSH_PRIVATE_KEY`.
> - Ejecute en el servidor remoto (estrategia git pull):
>   1. `cd` al directorio de la app (marcar con `# TODO` la ruta real).
>   2. `git pull` para obtener el último código.
>   3. `npm ci --omit=dev` para instalar solo dependencias de producción.
>   4. `npx prisma generate` para regenerar el cliente ORM.
>   5. `npx prisma migrate deploy` para aplicar migraciones pendientes.
>   6. `npm run build` para recompilar TypeScript.
>   7. `pm2 reload backend --update-env || pm2 restart backend` para reiniciar el servicio
>      (marcar con `# SUPUESTO` el nombre del proceso PM2).
> - Añadir las variables `AWS_ACCESS_KEY_ID` y `AWS_SECRET_ACCESS_KEY` como `env` del step
>   (mapeadas desde `AWS_ACCESS_ID` y `AWS_ACCESS_KEY` respectivamente) por si se necesita
>   interacción con AWS CLI, aunque no son estrictamente necesarias para SSH.
> - Explicar en un comentario por qué `StrictHostKeyChecking=no` y su alternativa más segura.
>
> Restricciones: `set -e` al inicio del script remoto para abortar ante cualquier error;
> ningún secreto visible en los logs del runner.

**Resultado:** Job `deploy` en `.github/workflows/pipeline.yml`.