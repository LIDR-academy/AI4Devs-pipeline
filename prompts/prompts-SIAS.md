# Prompts — Sesión CI/CD Pipeline (AI4Devs)

**Proyecto:** LTI — Sistema de Seguimiento de Talento
**Sesión:** 2026-06-15
**Modelo LLM:** Claude Sonnet 4.6

## Herramientas utilizadas

- **VSCode + Claude Code** — modificaciones en el repositorio (edición de ficheros, generación de Dockerfiles, workflows, correcciones de seguridad)
- **OpenAI Codex** — lanzamiento del prompt inicial de análisis y para resolver dudas al iterar con GitHub Actions y AWS
- **GitHub** — repositorio remoto, configuración de Secrets y GitHub Environments
- **AWS Console** — configuración de IAM, ECR y EC2

---

## 1. Prompt inicial — Análisis de arquitectura y diseño del pipeline

**Modo:** Ask
**Modelo:** Claude Sonnet 4.6

```text
Eres un ingeniero DevOps senior con 10+ años de experiencia en CI/CD, infraestructura cloud (AWS),
contenedores y automatización. Dominas GitHub Actions, Terraform, Docker, y despliegues en EC2.
Cuando respondas:
- Analiza la arquitectura del proyecto
- Indica qué es lo que se necesita antes de proceder con el pipeline
- Proporciona configuraciones listas para producción con buenas prácticas de seguridad
- Explica cada decisión técnica brevemente
- Señala posibles problemas o consideraciones adicionales
- Usa variables de entorno y GitHub Secrets en lugar de valores hardcodeados

Contexto del proyecto: pipeline de CI/CD para una aplicación backend con frontend.
```

**Resultado:** Exploración completa del proyecto con subagente (Explore). Identificación del stack:
React 18 + Node.js/Express/TypeScript + Prisma + PostgreSQL. Detección de `.github/workflows/ci.yml`
vacío y ausencia de Dockerfiles.

---

## 2. Planificación — Análisis previo de Codex como base del plan

**Modo:** Plan
**Modelo:** Claude Sonnet 4.6
**Herramienta:** OpenAI Codex → VSCode + Claude Code

> El prompt del apartado anterior fue lanzado en **Codex**. Su respuesta incluyó un análisis
> detallado de la arquitectura, problemas críticos pre-pipeline y una propuesta de workflows,
> que se utilizó como contexto de entrada para planificar la implementación en Claude Code.

**Resultado:** Incorporación al plan de todos los puntos identificados por Codex en su análisis inicial.
A continuación se recoge dicho análisis:

---

### Análisis previo generado por Codex

#### Análisis de Arquitectura

##### Stack Tecnológico

| Capa           | Tecnología                    | Puerto |
| -------------- | ----------------------------- | ------ |
| Frontend       | React 18 + CRA + TypeScript   | 3000   |
| Backend        | Node.js + Express + TypeScript| 3010   |
| ORM            | Prisma 5                      | —      |
| Base de datos  | PostgreSQL (Docker)           | 5432   |
| Tests unitarios| Jest + ts-jest                | —      |
| Tests E2E      | Cypress 13                    | —      |

---

#### Problemas Críticos que Deben Resolverse ANTES del Pipeline

##### 1. Credenciales Hardcodeadas (OWASP A02 - Cryptographic Failures)

En `backend/prisma/schema.prisma`, la URL de la base de datos está hardcodeada con credenciales reales:

```prisma
// ❌ CRÍTICO: Credenciales en código fuente
url = "postgresql://LTIdbUser:D1ymf8wyQEGthFR1E9xhCq@localhost:5432/LTIdb"
```

Corrección requerida:

```prisma
// ✅ Correcto
url = env("DATABASE_URL")
```

##### 2. CORS Hardcodeado

En `backend/src/index.ts`, el origen CORS está fijo a `localhost:3000`. En producción esto bloqueará todas las peticiones del frontend real:

```typescript
// ❌ Solo funciona en dev local
origin: 'http://localhost:3000'

// ✅ Corrección
origin: process.env.FRONTEND_URL || 'http://localhost:3000'
```

##### 3. Puerto Hardcodeado en Backend

```typescript
// ❌
const port = 3010;
// ✅
const port = process.env.PORT || 3010;
```

##### 4. Tests E2E Deshabilitados

En `frontend/cypress/integration/positionDetails.spec.js`, todos los tests están con `describe.skip(...)`.
Debe resolverse antes de integrarlos en el pipeline.

##### 5. Sin Dockerfiles

No existe ningún `Dockerfile` para backend ni frontend. Son necesarios para el despliegue en EC2.

##### 6. Sin Health Check Endpoint

El backend no tiene un endpoint `/health` o `/healthz`. Es indispensable para load balancers y container orchestration.

---

#### Checklist Pre-Pipeline

```text
☐ 1. Rotar credenciales de DB (las actuales están comprometidas en git)
☐ 2. Mover DATABASE_URL a variable de entorno en schema.prisma
☐ 3. Crear .env.example con todas las variables necesarias
☐ 4. Crear Dockerfile para backend
☐ 5. Crear Dockerfile para frontend
☐ 6. Añadir health check endpoint (/health) al backend
☐ 7. Configurar CORS dinámico desde env
☐ 8. Añadir .dockerignore a cada servicio
☐ 9. Habilitar/arreglar tests E2E de Cypress o documentar que son opcionales
☐ 10. Añadir .gitignore que excluya .env si no existe ya
```

---

#### Arquitectura del Pipeline CI/CD

```mermaid
flowchart TD
    A[git push / PR] --> B{Branch?}
    B -->|feature/*| C[CI Only]
    B -->|main| D[CI + CD Staging]
    B -->|release/*| E[CI + CD Production]

    C --> F[Lint & Type Check]
    F --> G[Unit Tests Backend]
    G --> H[Unit Tests Frontend]
    H --> I[Build Docker Images]
    I --> J[Security Scan - Trivy]

    D --> F
    J --> K[Push to ECR]
    K --> L[Deploy Staging EC2]
    L --> M[Smoke Tests / E2E]

    E --> F
    M --> N[Manual Approval]
    N --> O[Deploy Production EC2]
    O --> P[Health Check]
```

---

#### GitHub Secrets Necesarios

```text
# AWS
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
AWS_ACCOUNT_ID

# EC2 / SSH
EC2_HOST_STAGING
EC2_HOST_PRODUCTION
EC2_USER
EC2_SSH_KEY

# Aplicación
DATABASE_URL
FRONTEND_URL
```

---

#### IAM Policy Mínima para GitHub Actions (Least Privilege)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ECRAuth",
      "Effect": "Allow",
      "Action": ["ecr:GetAuthorizationToken"],
      "Resource": "*"
    },
    {
      "Sid": "ECROperations",
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": [
        "arn:aws:ecr:<region>:<account-id>:repository/lti-backend",
        "arn:aws:ecr:<region>:<account-id>:repository/lti-frontend"
      ]
    }
  ]
}
```

#### Consideraciones Adicionales

| Área                  | Problema                                               | Recomendación                                            |
| --------------------- | ------------------------------------------------------ | -------------------------------------------------------- |
| **Migraciones DB**    | Las migraciones Prisma no están en el pipeline         | Añadir `prisma migrate deploy` antes del deploy          |
| **File uploads**      | Los CVs subidos se pierden en cada deploy              | Migrar a S3 + presigned URL                              |
| **Secrets rotation**  | Credenciales del schema.prisma en git history          | `git filter-repo` + rotar inmediatamente                 |
| **`CI: false`**       | Ignora warnings de ESLint en build frontend            | A largo plazo corregir warnings y poner `CI: true`       |
| **`describe.skip`**   | Los E2E de Cypress no aportan calidad al pipeline      | Activarlos o marcarlos opcionales hasta que estén listos |
| **CORS**              | Hardcodeado a localhost                                | Configurar via `FRONTEND_URL` env var                    |
| **Rate limiting**     | No hay rate limiting en el backend Express             | Añadir `express-rate-limit` antes de exponer a producción|

---

## 3. Implementación — Fase 0: Correcciones de seguridad pre-pipeline

**Modo:** Agent (implementación directa)
**Modelo:** Claude Sonnet 4.6
**Herramienta:** VSCode + Claude Code

Iteración sobre los archivos críticos con problemas de seguridad identificados en el análisis previo:

- `backend/prisma/schema.prisma` → eliminadas credenciales hardcodeadas, sustituidas por `env("DATABASE_URL")`
- `backend/src/index.ts` → PORT dinámico (`process.env.PORT || 3010`), CORS dinámico (`process.env.FRONTEND_URL`), añadido endpoint `/health`

---

## 4. Implementación — Fase 1: Infraestructura Docker

**Modo:** Agent (implementación directa)
**Modelo:** Claude Sonnet 4.6
**Herramienta:** VSCode + Claude Code

Creación en paralelo de los archivos de infraestructura:

- `backend/Dockerfile` — multi-stage (builder + production), usuario non-root, `HEALTHCHECK`
- `frontend/Dockerfile` — multi-stage (CRA build + nginx:alpine), `HEALTHCHECK`
- `frontend/nginx.conf` — SPA routing, proxy `/api/` → backend, headers de seguridad (CSP, X-Frame-Options, etc.)
- `backend/.dockerignore` y `frontend/.dockerignore`
- `docker-compose.prod.yml` — 3 servicios (db, backend, frontend), red interna, volumen persistente
- `.env.example` — template documentado de todas las variables

---

## 5. Implementación — Fase 2: GitHub Actions (3 workflows)

**Modo:** Agent (implementación directa)
**Modelo:** Claude Sonnet 4.6
**Herramienta:** VSCode + Claude Code

Creación de los 3 workflows con la siguiente estrategia de branches:

| Workflow            | Trigger       | Jobs                                                                                 |
| ------------------- | ------------- | ------------------------------------------------------------------------------------ |
| `ci.yml`            | Todo push/PRs | type check → lint → tests → build → `npm audit`                                      |
| `cd-staging.yml`    | Push a `main` | build+push ECR → Trivy scan → SSH deploy → health check → E2E (optional)             |
| `cd-production.yml` | Tag `v*.*.*`  | build+push ECR → Trivy → **aprobación manual** → migrations → deploy → health check  |

Decisiones técnicas destacadas:

- Amazon ECR como registry (Instance Profile en EC2, sin credenciales estáticas en el host)
- `prisma migrate deploy` como step previo al restart del backend
- `continue-on-error: true` en E2E hasta que salgan del `describe.skip`
- Rollback implícito: la imagen anterior permanece en ECR disponible

---

## 6. Fix puntual — .gitignore con .env comentado

**Modo:** Ask
**Modelo:** Claude Sonnet 4.6
**Herramienta:** VSCode + Claude Code

```text
el 10 si
```

Referencia al punto 10 de la checklist de la bitácora: "Añadir .gitignore que excluya .env".

**Resultado:** Descomentada la línea `#**/.env` → `**/.env` en `.gitignore`.
Las credenciales reales no se commitearán en el futuro.

---

## 7. Consulta operacional — Cómo rotar credenciales de DB

**Modo:** Ask
**Modelo:** Claude Sonnet 4.6
**Herramienta:** Codex (consulta de procedimiento)

```text
como lo hago
```

**Resultado:** Guía paso a paso: `ALTER USER` en psql dentro del contenedor Docker,
actualización de `.env` locales, GitHub Secrets y limpieza de historial con `git filter-repo`.
Se decidió asumir el riesgo para este proyecto de curso y continuar.

---

## 8. Verificación de estado previo al primer push

**Modo:** Ask
**Modelo:** Claude Sonnet 4.6
**Herramienta:** VSCode + Claude Code / Codex (dudas sobre configuración AWS y GitHub)

```text
si, dime en este punto lo que tengo que configurar ya que voy a usar AWS EC2
[...]
creo que ya están los puntos 1 al 6. Chequea lo que puedas del proyecto para saber si puedo comenzar
```

**Resultado:** Verificación local de los 13 archivos creados/modificados vía `git status`.
Confirmación de que el código local está listo. Lista de los 6 puntos que solo el usuario
puede verificar en AWS/GitHub (Secrets, ECR repos, EC2 con Docker, Instance Profile, Security Group, `/opt/lti-app`).

---

## 9. Prompt mejorado — Plantilla para proyectos similares

**Modo:** Ask / Plan
**Modelo:** Claude Sonnet 4.6 (o superior)
**Herramienta:** Codex, Claude Code o cualquier LLM con acceso al repositorio

> Este prompt es una versión refinada del prompt inicial, elaborada una vez completada toda la
> tarea. Incorpora las lecciones aprendidas durante la implementación real: problemas con Prisma
> en Alpine, hardcoding de `localhost` en el frontend, separación de permisos IAM, auditoría de
> dependencias runtime vs devDependencies, y la necesidad de auditar el repo antes de generar
> cualquier configuración. Puede usarse como plantilla de partida para proyectos full-stack
> similares con la misma arquitectura (Node.js + React + PostgreSQL + Docker + AWS EC2).

```text
Quiero desplegar el proyecto AI4Devs-pipeline en AWS staging usando GitHub Actions, ECR, EC2,
Docker Compose y GitHub Secrets.

Antes de tocar nada, audita el repositorio:
- Estructura de carpetas.
- Dockerfiles de backend y frontend.
- docker-compose.prod.yml.
- Workflows existentes en .github/workflows.
- Variables de entorno necesarias.
- Uso de Prisma, PostgreSQL, nginx y frontend API URLs.

Después propón y ejecuta un plan paso a paso, explicando cada decisión:

1. AWS IAM
- Crear o validar un usuario IAM para GitHub Actions sin acceso a consola.
- Darle solo permisos mínimos para hacer push a ECR.
- Indicar exactamente qué Access Key hay que guardar en GitHub Secrets.

2. AWS ECR
- Crear o validar repositorios privados:
  - lti-backend
  - lti-frontend
- Confirmar región y account ID.

3. AWS EC2
- Crear o validar una instancia EC2 para staging.
- Recomendar AMI, tipo de instancia y storage.
- Configurar Security Group con:
  - 80 abierto a Internet.
  - 443 abierto a Internet.
  - 22 restringido de forma segura.
- Crear o validar un IAM Role / Instance Profile con permisos de pull desde ECR.

4. Preparación de EC2
- Conectar por SSH.
- Instalar Docker, Docker Compose y AWS CLI.
- Crear /opt/lti-app.
- Copiar docker-compose.prod.yml.
- Crear .env en EC2 sin exponer secretos en el repo.

5. GitHub Secrets
- Dar una tabla exacta de secrets necesarios:
  - AWS_ACCESS_KEY_ID
  - AWS_SECRET_ACCESS_KEY
  - AWS_REGION
  - AWS_ACCOUNT_ID
  - EC2_HOST_STAGING
  - EC2_USER
  - EC2_SSH_KEY
  - DB_USER
  - DB_PASSWORD
  - DB_NAME
  - DATABASE_URL
  - STAGING_API_URL
  - STAGING_FRONTEND_URL
- Explicar el valor esperado de cada uno sin revelar credenciales.

6. Revisión de código y configuración
- Ajustar Dockerfile del backend si Prisma necesita dependencias de producción.
- Verificar schema.prisma y binaryTargets para la imagen Docker usada.
- Verificar que el frontend no hardcodea localhost.
- Usar REACT_APP_API_URL.
- Usar nginx como proxy /api hacia backend.
- Revisar docker-compose.prod.yml para no exponer puertos innecesarios.

7. GitHub Actions
- Crear o corregir el workflow de staging para:
  - Build backend.
  - Build frontend con REACT_APP_API_URL.
  - Push a ECR.
  - SSH a EC2.
  - Login a ECR desde EC2 usando Instance Profile.
  - Pull de imágenes.
  - Levantar DB.
  - Ejecutar prisma migrate deploy.
  - Levantar backend y frontend.
  - Ejecutar health check.
  - Ejecutar E2E si existen.

8. Troubleshooting
- Si falla, analizar logs por capas:
  - IAM.
  - ECR.
  - SSH.
  - Docker.
  - Prisma.
  - nginx.
  - frontend.
  - health check.
- Proponer correcciones mínimas y volver a probar.

9. Seguridad final
- Cerrar SSH si se abrió temporalmente.
- Recomendar SSM o alternativa segura para futuros deploys.
- No guardar secretos en el repo.

10. Validación final
- Confirmar que el pipeline pasa.
- Confirmar que ECR tiene imágenes.
- Confirmar que EC2 tiene contenedores corriendo.
- Confirmar que frontend responde.
- Confirmar que /api/health responde.
- Documentar todo lo realizado en docs/despliegue-staging-aws-github-actions.md.

Explícame todo en español, de forma didáctica, para una persona técnica que no controla mucho de
DevOps. Usa tablas y comandos, indicando siempre si se ejecutan en PowerShell local, en EC2 por
SSH, en AWS Console o en GitHub UI.
```

---

## Resumen de archivos generados

| Archivo                               | Tipo de cambio          |
| ------------------------------------- | ----------------------- |
| `backend/prisma/schema.prisma`        | Modificado              |
| `backend/src/index.ts`                | Modificado              |
| `.gitignore`                          | Modificado              |
| `backend/Dockerfile`                  | Nuevo                   |
| `backend/.dockerignore`               | Nuevo                   |
| `frontend/Dockerfile`                 | Nuevo                   |
| `frontend/nginx.conf`                 | Nuevo                   |
| `frontend/.dockerignore`              | Nuevo                   |
| `docker-compose.prod.yml`             | Nuevo                   |
| `.env.example`                        | Nuevo                   |
| `.github/workflows/ci.yml`            | Nuevo (reemplaza vacío) |
| `.github/workflows/cd-staging.yml`    | Nuevo                   |
| `.github/workflows/cd-production.yml` | Nuevo                   |
