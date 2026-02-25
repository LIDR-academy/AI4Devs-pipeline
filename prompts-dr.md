# prompts-dr.md — Documentación de Prompts para el Pipeline CI/CD

> **Proyecto:** LTI — Sistema de Seguimiento de Talento  
> **Autor:** D. Ramírez  
> **Fecha:** 2026-02-24  
> **Archivo de salida:** `.github/workflows/pipeline.yml`

---

## Índice

1. [Contexto y Rol](#1-contexto-y-rol)
2. [Prompt — Fase de Análisis (Contexto)](#2-prompt--fase-de-análisis-contexto)
3. [Prompt — Job: Test](#3-prompt--job-test)
4. [Prompt — Job: Build](#4-prompt--job-build)
5. [Prompt — Job: Deploy](#5-prompt--job-deploy)
6. [Prompt — Seguridad y Secrets](#6-prompt--seguridad-y-secrets)
7. [Prompt — Consolidación Final](#7-prompt--consolidación-final)

---

## 1. Contexto y Rol

**Rol asignado al modelo:**

```
Actúa como Arquitecto DevOps Senior y Experto en Automatización de Infraestructura.
Diseña un pipeline de CI/CD completo en GitHub Actions para el proyecto LTI,
una aplicación full-stack con backend en Node.js/TypeScript (Express + Prisma)
y frontend en React. El despliegue objetivo es una instancia AWS EC2 gestionada con PM2.
```

---

## 2. Prompt — Fase de Análisis (Contexto)

**Objetivo:** Extraer del `README.md` toda la información técnica necesaria.

```
Lee el archivo README.md del proyecto LTI y extrae la siguiente información:
1. Tecnología y versión del backend (lenguaje, framework, ORM).
2. Comandos exactos de instalación de dependencias.
3. Comando para compilar/construir el artefacto de producción.
4. Comando para ejecutar las pruebas (unitarias/integración).
5. Comando para iniciar el servidor en producción.
6. Método de gestión de procesos recomendado (PM2, Docker, etc.).
7. Variables de entorno requeridas.
8. Puertos de red que debe exponer la aplicación.
9. Cualquier dependencia de infraestructura (base de datos, Docker, etc.).

Presenta el resultado como un resumen técnico estructurado que sirva como
base para diseñar el pipeline de CI/CD.
```

**Resultado extraído:**

| Campo | Valor |
|---|---|
| Lenguaje | TypeScript 4.x sobre Node.js |
| Framework | Express 4 |
| ORM | Prisma 5 |
| Instalación | `npm ci` (dentro de `./backend`) |
| Build | `npm run build` → `tsc` → genera `dist/` |
| Test | `npm test` → Jest + ts-jest |
| Start prod | `node dist/index.js` |
| Gestor de procesos | PM2 (documentado en README) |
| Puerto backend | 3010 |
| Base de datos | PostgreSQL (vía Docker Compose local / RDS en producción) |
| Variables de entorno | `DATABASE_URL`, `EC2_INSTANCE`, `AWS_ACCESS_ID`, `AWS_ACCESS_KEY` |

---

## 3. Prompt — Job: Test

**Objetivo:** Generar el job `test` del pipeline.

```
Genera el job "test" de un workflow de GitHub Actions para el backend Node.js/TypeScript
del proyecto LTI con las siguientes especificaciones:

- Runner: ubuntu-latest
- Node.js version: 18
- Directorio de trabajo: ./backend
- Pasos requeridos:
    1. Checkout del repositorio con actions/checkout@v4.
    2. Configuración de Node.js con actions/setup-node@v4 y caché de npm.
    3. Instalación de dependencias con `npm ci`.
    4. Generación del cliente Prisma con `npx prisma generate`.
    5. Ejecución de tests con `npm test -- --passWithNoTests --forceExit`.
- La variable DATABASE_URL debe consumirse desde los secrets de GitHub.
- Usa la variable de entorno NODE_VERSION: '18' definida a nivel de workflow.
- El output debe ser YAML válido con indentación de 2 espacios.
```

---

## 4. Prompt — Job: Build

**Objetivo:** Generar el job `build` que depende de `test`.

```
Genera el job "build" de un workflow de GitHub Actions para el backend TypeScript
del proyecto LTI. Requisitos:

- Debe declarar `needs: test` para ejecutarse solo si los tests pasan.
- Runner: ubuntu-latest
- Reutiliza las variables de entorno globales NODE_VERSION y WORKING_DIR.
- Pasos requeridos:
    1. Checkout del repositorio.
    2. Setup de Node.js con caché.
    3. `npm ci` para instalar dependencias.
    4. `npx prisma generate` para generar el cliente Prisma.
    5. `npm run build` que invoca `tsc` y genera la carpeta `dist/`.
    6. Subir el artefacto de build usando `actions/upload-artifact@v4`.
       El artefacto debe incluir: `backend/dist/`, `backend/package.json`,
       `backend/package-lock.json` y `backend/prisma/`.
       Retención: 5 días.
- El output debe ser YAML válido.
```

---

## 5. Prompt — Job: Deploy

**Objetivo:** Generar el job `deploy` que despliega en EC2 con PM2.

```
Genera el job "deploy" de un workflow de GitHub Actions que despliega el backend
del proyecto LTI en una instancia AWS EC2 usando SSH y PM2. Especificaciones:

- Dependencia: `needs: build` (solo corre si build es exitoso).
- Solo ejecutar en pushes a la rama `main` (usa condición `if:`).
- Runner: ubuntu-latest
- Secrets a consumir (nunca hardcodear valores):
    - EC2_SSH_KEY: clave privada PEM de AWS.
    - EC2_HOST: IP pública o DNS de la instancia.
    - EC2_USER: usuario SSH (ej. ec2-user o ubuntu).
    - DATABASE_URL: cadena de conexión a PostgreSQL.

- Pasos requeridos:
    1. Descargar el artefacto `backend-dist` con actions/download-artifact@v4.
    2. Configurar la clave SSH en ~/.ssh/deploy_key con permisos 600 y agregar
       el host a known_hosts mediante ssh-keyscan.
    3. Copiar el artefacto a EC2 usando `rsync` sobre SSH al directorio
       /home/<EC2_USER>/app/.
    4. Conectarse via SSH y ejecutar:
       a. `npm ci --omit=dev` para instalar solo dependencias de producción.
       b. `npx prisma generate` en el servidor.
       c. `pm2 reload lti-backend` si el proceso ya existe, o
          `pm2 start dist/index.js --name lti-backend` si es la primera vez.
       d. `pm2 save` para persistir la configuración.
    5. Verificar la salud del backend con `curl -sf http://localhost:3010/`.
       Si falla, mostrar los últimos 20 logs de PM2 y salir con error.

- Todo el bloque SSH debe usar heredoc y `set -e` para detención ante errores.
- El output debe ser YAML válido e indentado correctamente.
```

---

## 6. Prompt — Seguridad y Secrets

**Objetivo:** Definir la estrategia de gestión segura de credenciales.

```
Para el pipeline CI/CD del proyecto LTI en GitHub Actions, define la estrategia
de gestión de secrets siguiendo el principio de mínimo privilegio. Indica:

1. Qué secrets deben configurarse en el repositorio de GitHub
   (Settings → Secrets and variables → Actions).
2. Cómo se referencian correctamente en el YAML (${{ secrets.NOMBRE }}).
3. Por qué NO se deben incluir valores de credenciales directamente en el YAML.
4. Cómo proteger la clave SSH privada (permisos chmod 600, no logging).

Lista de secrets requeridos:
- EC2_SSH_KEY: clave privada PEM para acceso SSH a EC2.
- EC2_HOST: dirección IP pública o nombre DNS de la instancia EC2.
- EC2_USER: nombre del usuario SSH en la instancia (ec2-user / ubuntu).
- DATABASE_URL: cadena de conexión completa a PostgreSQL con credenciales.
```

**Tabla de secrets configurados:**

| Secret | Descripción | Obligatorio |
|---|---|---|
| `EC2_SSH_KEY` | Clave privada PEM para SSH a la instancia EC2 | ✅ |
| `EC2_HOST` | IP pública o DNS de EC2 | ✅ |
| `EC2_USER` | Usuario SSH (`ec2-user` o `ubuntu`) | ✅ |
| `DATABASE_URL` | Cadena de conexión PostgreSQL | ✅ |

---

## 7. Prompt — Consolidación Final

**Objetivo:** Unificar todos los jobs en un workflow cohesivo.

```
Consolida los tres jobs (test, build, deploy) en un único archivo YAML válido para
GitHub Actions llamado `pipeline.yml`. Asegúrate de que:

1. El trigger se active mediante `push` en ramas distintas a main Y mediante
   `pull_request` hacia main, para cubrir el flujo de branches con PRs abiertos.
2. Se defina `concurrency` para cancelar ejecuciones paralelas en la misma rama.
3. Las variables globales NODE_VERSION y WORKING_DIR estén en la sección `env:`
   del workflow raíz para evitar repetición (principio DRY).
4. La cadena de dependencias sea: test → build → deploy.
5. El job deploy solo se active en pushes a main (mediante condición `if:`).
6. Todas las credenciales se lean desde `secrets`, nunca hardcodeadas.
7. El YAML sea syntácticamente válido, bien indentado (2 espacios) y con
   comentarios en español explicando cada sección.

Formato esperado: YAML puro, listo para ser guardado en
`.github/workflows/pipeline.yml`.
```

---

## Notas de Implementación

> **Configuración previa requerida en GitHub:**  
> Antes de ejecutar el pipeline, configura los secrets en  
> `Repositorio → Settings → Secrets and variables → Actions → New repository secret`.

> **Requisitos en EC2:**  
> La instancia debe tener instalado: `Node.js 18+`, `npm`, `PM2` (`npm install -g pm2`)  
> y `rsync`. El usuario SSH debe tener acceso de escritura a `/home/<usuario>/app/`.

> **Primera ejecución:**  
> En el primer deploy, PM2 creará el proceso desde cero. En deploys posteriores,  
> usará `pm2 reload` para un reinicio sin downtime (zero-downtime reload).
