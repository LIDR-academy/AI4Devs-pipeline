# Prompts iniciales — DMM

Documentación de los prompts utilizados para generar el pipeline de CI/CD definido en `.github/workflows/pipeline.yml`.

El workflow se dispara con un `pull_request` sobre `main` (tipos `opened`, `synchronize`, `reopened`) y ejecuta tres jobs en cadena: `test` → `build` → `deploy`. Las pruebas mockean `@prisma/client`, así que no requieren base de datos en el runner.

## 1 · Tests de backend (job `test`)

> Necesito un job de GitHub Actions llamado `test` que ejecute los tests del backend Express/TypeScript que está en `backend/`. Stack: Node 20, npm, Jest con `ts-jest` (configurado en `backend/jest.config.js`). Las pruebas mockean `@prisma/client`, por lo que NO hace falta base de datos para correrlas. Pasos del job:
> 1. `actions/checkout@v4`.
> 2. `actions/setup-node@v4` con `node-version: '20'`, `cache: 'npm'` y `cache-dependency-path: backend/package-lock.json`.
> 3. `npm ci` con `working-directory: backend`.
> 4. `npm test` (que ejecuta `jest`).
>
> Runner: `ubuntu-latest`. El trigger del workflow es `pull_request` sobre `main` con tipos `opened`, `synchronize`, `reopened`. Usa `defaults.run.working-directory: backend` para no repetir el prefijo en cada step. Devuélveme el YAML listo para pegar en `.github/workflows/pipeline.yml`.

## 2 · Build del backend (job `build`)

> Añade un segundo job llamado `build` en el mismo workflow, con `needs: test`. Runner `ubuntu-latest`, heredando `working-directory: backend` por defecto. Pasos obligatorios:
> 1. Checkout + setup-node (Node 20, mismo cache npm que en el job de tests).
> 2. `npm ci`.
> 3. `npx prisma generate` para producir el cliente en `node_modules/.prisma/client` (necesario en producción).
> 4. `npm run build` (corre `tsc` y deja el resultado en `backend/dist/`).
> 5. `actions/upload-artifact@v4` con `name: backend-build` y `path:` en multilínea con cuatro entradas: `backend/dist`, `backend/package.json`, `backend/package-lock.json` y `backend/prisma`. El `prisma/` se incluye para que el job de deploy pueda regenerar el cliente en la EC2.
>
> Devuélveme solo el bloque YAML del job `build`, manteniendo el resto del workflow intacto.

## 3 · Deploy en EC2 (job `deploy`)

> Añade un tercer job llamado `deploy` con `needs: build`, runner `ubuntu-latest`, que despliegue el backend en una instancia EC2 Ubuntu/Amazon Linux usando SSH. El proyecto usará PM2 como process manager. Secrets requeridos en el repo: `EC2_HOST` (DNS público o IP), `EC2_USER` (típicamente `ubuntu` o `ec2-user`), `EC2_SSH_KEY` (clave privada PEM completa, con saltos de línea).
>
> Pasos del job:
> 1. `actions/download-artifact@v4` con `name: backend-build` y `path: build`. Tras esto existen en el runner `build/dist`, `build/package.json`, `build/package-lock.json` y `build/prisma`.
> 2. `appleboy/scp-action@v0.1.7` que copie esos cuatro elementos al directorio `/home/${{ secrets.EC2_USER }}/app` de la EC2 (usa `source` multilínea y `target` con la ruta absoluta).
> 3. `appleboy/ssh-action@v1.0.3` con `script:` que ejecute en la EC2:
>    ```
>    cd /home/${{ secrets.EC2_USER }}/app
>    npm ci --omit=dev
>    npx prisma generate
>    (pm2 restart backend || pm2 start npm --name backend -- start)
>    pm2 save --force
>    ```
>    La forma `(pm2 restart ... || pm2 start ...)` cubre tanto un redeploy (el proceso ya existe) como el primer deploy (aún no hay proceso).
>
> Prerrequisitos en la EC2 que NO ejecuta el workflow y deben estar hechos a mano: Node 20 LTS, PM2 global (`npm i -g pm2`), `pm2 startup` configurado, security group con el puerto `3010` abierto (puerto del backend, ver `backend/src/index.ts`) y `22` accesible desde las IPs de GitHub Actions.
>
> Devuélveme el bloque YAML del job `deploy`.
