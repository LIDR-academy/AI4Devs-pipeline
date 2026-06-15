# Bitácora CI/CD — AI4Devs Pipeline

**Fecha de análisis:** 2026-06-15

---

## Análisis de Arquitectura

### Stack Tecnológico

| Capa | Tecnología | Puerto |
|------|------------|--------|
| Frontend | React 18 + CRA + TypeScript | 3000 |
| Backend | Node.js + Express + TypeScript | 3010 |
| ORM | Prisma 5 | — |
| Base de datos | PostgreSQL (Docker) | 5432 |
| Tests unitarios | Jest + ts-jest | — |
| Tests E2E | Cypress 13 | — |

---

## 🚨 Problemas Críticos que Deben Resolverse ANTES del Pipeline

### 1. Credenciales Hardcodeadas (OWASP A02 - Cryptographic Failures)

En `backend/prisma/schema.prisma`, la URL de la base de datos está hardcodeada con credenciales reales:

```prisma
// ❌ CRÍTICO: Credenciales en código fuente
url = "postgresql://LTIdbUser:D1ymf8wyQEGthFR1E9xhCq@localhost:5432/LTIdb"
```

**Corrección requerida:**
```prisma
// ✅ Correcto
url = env("DATABASE_URL")
```

### 2. CORS Hardcodeado

En `backend/src/index.ts`, el origen CORS está fijo a `localhost:3000`. En producción esto bloqueará todas las peticiones del frontend real:

```typescript
// ❌ Solo funciona en dev local
origin: 'http://localhost:3000'
```

**Corrección:**
```typescript
// ✅
origin: process.env.FRONTEND_URL || 'http://localhost:3000'
```

### 3. Puerto Hardcodeado en Backend

En `backend/src/index.ts`:
```typescript
// ❌
const port = 3010;
// ✅
const port = process.env.PORT || 3010;
```

### 4. Tests E2E Deshabilitados

En `frontend/cypress/integration/positionDetails.spec.js`, todos los tests están con `describe.skip(...)`. Esto debe resolverse antes de integrarlos en el pipeline.

### 5. Sin Dockerfiles

No existe ningún `Dockerfile` para backend ni frontend. Son necesarios para el despliegue en EC2.

### 6. Sin Health Check Endpoint

El backend no tiene un endpoint `/health` o `/healthz`. Es indispensable para load balancers y container orchestration.

---

## Lo que Necesitas Antes del Pipeline

### Checklist Pre-Pipeline

```
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

## Arquitectura del Pipeline CI/CD

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

## GitHub Secrets Necesarios

Configura estos en **Settings → Secrets and variables → Actions**:

```
# AWS
AWS_ACCESS_KEY_ID          # IAM user con permisos mínimos
AWS_SECRET_ACCESS_KEY
AWS_REGION                 # ej: eu-west-1
AWS_ACCOUNT_ID             # ID numérico de tu cuenta AWS

# ECR (se construyen dinámicamente, no son secrets)
# ECR_BACKEND_REPO=<account>.dkr.ecr.<region>.amazonaws.com/lti-backend
# ECR_FRONTEND_REPO=<account>.dkr.ecr.<region>.amazonaws.com/lti-frontend

# EC2 / SSH
EC2_HOST_STAGING           # IP o DNS de la instancia staging
EC2_HOST_PRODUCTION        # IP o DNS de la instancia producción
EC2_USER                   # ej: ec2-user o ubuntu
EC2_SSH_KEY                # Clave privada PEM completa

# Aplicación
DATABASE_URL               # postgresql://user:pass@host:5432/db
FRONTEND_URL               # https://tu-dominio.com
```

---

## GitHub Actions Workflow — Producción

### `.github/workflows/ci.yml` — CI para todos los branches

```yaml
name: CI Pipeline

on:
  push:
    branches: ['**']
  pull_request:
    branches: [main, 'release/**']

env:
  NODE_VERSION: '20'

jobs:
  backend-ci:
    name: Backend — Lint, Type Check & Tests
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: backend

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: backend/package-lock.json

      - name: Install dependencies
        run: npm ci

      # Genera el cliente Prisma sin necesitar DB real
      - name: Generate Prisma Client
        run: npx prisma generate

      - name: Type check
        run: npx tsc --noEmit

      - name: Lint
        run: npx eslint src --ext .ts

      - name: Run unit tests
        run: npm test -- --coverage --ci
        env:
          DATABASE_URL: postgresql://test:test@localhost:5432/testdb

      - name: Upload coverage
        uses: codecov/codecov-action@v4
        if: always()
        with:
          directory: backend/coverage

  frontend-ci:
    name: Frontend — Lint, Type Check & Build
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: frontend

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json

      - name: Install dependencies
        run: npm ci

      - name: Build (valida que compila sin errores)
        run: npm run build
        env:
          CI: false  # CRA falla con warnings como errores; ajustar según política
          REACT_APP_API_URL: http://localhost:3010

  security-scan:
    name: Dependency Security Audit
    runs-on: ubuntu-latest
    needs: [backend-ci, frontend-ci]

    steps:
      - uses: actions/checkout@v4

      - name: Audit backend dependencies
        run: npm audit --audit-level=high
        working-directory: backend
        continue-on-error: false

      - name: Audit frontend dependencies
        run: npm audit --audit-level=high
        working-directory: frontend
        continue-on-error: false
```

### `.github/workflows/cd-staging.yml` — Deploy automático a Staging

```yaml
name: CD — Staging

on:
  push:
    branches: [main]

env:
  AWS_REGION: ${{ secrets.AWS_REGION }}
  ECR_BACKEND: ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/lti-backend
  ECR_FRONTEND: ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/lti-frontend

jobs:
  build-and-push:
    name: Build & Push Docker Images to ECR
    runs-on: ubuntu-latest
    outputs:
      image-tag: ${{ steps.meta.outputs.version }}

    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Login to Amazon ECR
        uses: aws-actions/amazon-ecr-login@v2

      - name: Generate image tag
        id: meta
        run: echo "version=${{ github.sha }}" >> $GITHUB_OUTPUT

      - name: Build & push backend image
        uses: docker/build-push-action@v5
        with:
          context: ./backend
          push: true
          tags: |
            ${{ env.ECR_BACKEND }}:${{ steps.meta.outputs.version }}
            ${{ env.ECR_BACKEND }}:staging-latest
          cache-from: type=registry,ref=${{ env.ECR_BACKEND }}:staging-latest
          cache-to: type=inline

      - name: Build & push frontend image
        uses: docker/build-push-action@v5
        with:
          context: ./frontend
          push: true
          tags: |
            ${{ env.ECR_FRONTEND }}:${{ steps.meta.outputs.version }}
            ${{ env.ECR_FRONTEND }}:staging-latest
          build-args: |
            REACT_APP_API_URL=https://api-staging.tu-dominio.com
          cache-from: type=registry,ref=${{ env.ECR_FRONTEND }}:staging-latest
          cache-to: type=inline

      - name: Scan images with Trivy (critical vulnerabilities block deploy)
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ env.ECR_BACKEND }}:${{ steps.meta.outputs.version }}
          severity: CRITICAL
          exit-code: '1'

  deploy-staging:
    name: Deploy to Staging EC2
    runs-on: ubuntu-latest
    needs: build-and-push
    environment: staging

    steps:
      - uses: actions/checkout@v4

      - name: Deploy via SSH
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.EC2_HOST_STAGING }}
          username: ${{ secrets.EC2_USER }}
          key: ${{ secrets.EC2_SSH_KEY }}
          script: |
            set -e

            # Login a ECR desde el EC2
            aws ecr get-login-password --region ${{ secrets.AWS_REGION }} | \
              docker login --username AWS --password-stdin \
              ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com

            # Pull nuevas imágenes
            docker pull ${{ env.ECR_BACKEND }}:${{ needs.build-and-push.outputs.image-tag }}
            docker pull ${{ env.ECR_FRONTEND }}:${{ needs.build-and-push.outputs.image-tag }}

            # Actualizar y reiniciar con zero-downtime básico
            cd /opt/lti-app

            IMAGE_BACKEND=${{ env.ECR_BACKEND }}:${{ needs.build-and-push.outputs.image-tag }} \
            IMAGE_FRONTEND=${{ env.ECR_FRONTEND }}:${{ needs.build-and-push.outputs.image-tag }} \
            docker compose up -d --no-deps backend frontend

            # Health check post-deploy
            sleep 10
            curl --fail http://localhost:3010/health || exit 1

  e2e-tests:
    name: Smoke / E2E Tests
    runs-on: ubuntu-latest
    needs: deploy-staging

    steps:
      - uses: actions/checkout@v4

      - name: Run Cypress E2E tests against staging
        uses: cypress-io/github-action@v6
        with:
          working-directory: frontend
          config: baseUrl=https://staging.tu-dominio.com
        env:
          CYPRESS_API_URL: https://api-staging.tu-dominio.com
```

### `.github/workflows/cd-production.yml` — Deploy a Producción con Aprobación Manual

```yaml
name: CD — Production

on:
  push:
    tags:
      - 'v[0-9]+.[0-9]+.[0-9]+'  # Solo tags semver: v1.2.3

env:
  AWS_REGION: ${{ secrets.AWS_REGION }}
  ECR_BACKEND: ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/lti-backend
  ECR_FRONTEND: ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/lti-frontend

jobs:
  build-and-push:
    name: Build Production Images
    runs-on: ubuntu-latest
    outputs:
      image-tag: ${{ steps.tag.outputs.version }}

    steps:
      - uses: actions/checkout@v4

      - name: Get version from tag
        id: tag
        run: echo "version=${GITHUB_REF#refs/tags/}" >> $GITHUB_OUTPUT

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Login to Amazon ECR
        uses: aws-actions/amazon-ecr-login@v2

      - name: Build & push backend
        uses: docker/build-push-action@v5
        with:
          context: ./backend
          push: true
          tags: |
            ${{ env.ECR_BACKEND }}:${{ steps.tag.outputs.version }}
            ${{ env.ECR_BACKEND }}:latest
          cache-from: type=registry,ref=${{ env.ECR_BACKEND }}:latest

      - name: Build & push frontend
        uses: docker/build-push-action@v5
        with:
          context: ./frontend
          push: true
          tags: |
            ${{ env.ECR_FRONTEND }}:${{ steps.tag.outputs.version }}
            ${{ env.ECR_FRONTEND }}:latest
          build-args: |
            REACT_APP_API_URL=https://api.tu-dominio.com

  deploy-production:
    name: Deploy to Production (requires approval)
    runs-on: ubuntu-latest
    needs: build-and-push
    environment: production  # ← Configura "Required reviewers" en GitHub Environments

    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Deploy via SSH
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.EC2_HOST_PRODUCTION }}
          username: ${{ secrets.EC2_USER }}
          key: ${{ secrets.EC2_SSH_KEY }}
          script: |
            set -e

            aws ecr get-login-password --region ${{ secrets.AWS_REGION }} | \
              docker login --username AWS --password-stdin \
              ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com

            docker pull ${{ env.ECR_BACKEND }}:${{ needs.build-and-push.outputs.image-tag }}
            docker pull ${{ env.ECR_FRONTEND }}:${{ needs.build-and-push.outputs.image-tag }}

            cd /opt/lti-app

            # Backup del compose actual antes de actualizar
            cp docker-compose.yml docker-compose.yml.bak

            IMAGE_BACKEND=${{ env.ECR_BACKEND }}:${{ needs.build-and-push.outputs.image-tag }} \
            IMAGE_FRONTEND=${{ env.ECR_FRONTEND }}:${{ needs.build-and-push.outputs.image-tag }} \
            docker compose up -d --no-deps backend frontend

            # Health check
            sleep 15
            curl --fail https://api.tu-dominio.com/health || {
              echo "Health check failed, rolling back..."
              docker compose up -d --no-deps backend frontend  # usa imagen anterior
              exit 1
            }
```

---

## Dockerfiles Necesarios

### `backend/Dockerfile`

```dockerfile
# --- Build stage ---
FROM node:20-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production=false

COPY . .
RUN npx prisma generate
RUN npm run build

# --- Production stage ---
FROM node:20-alpine AS production
WORKDIR /app

# Usuario no-root (principio least privilege)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
COPY prisma ./prisma

USER appuser
EXPOSE 3010

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3010/health || exit 1

CMD ["node", "dist/index.js"]
```

### `frontend/Dockerfile`

```dockerfile
# --- Build stage ---
FROM node:20-alpine AS builder
WORKDIR /app

ARG REACT_APP_API_URL
ENV REACT_APP_API_URL=$REACT_APP_API_URL

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# --- Production stage (Nginx) ---
FROM nginx:1.25-alpine AS production

# Copia build de React
COPY --from=builder /app/build /usr/share/nginx/html

# Config Nginx con headers de seguridad
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s \
  CMD wget -qO- http://localhost:80 || exit 1
```

---

## IAM Policy Mínima para GitHub Actions (Least Privilege)

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

> El EC2 accede a ECR vía **Instance Profile** (IAM Role), no via credenciales estáticas. El GitHub Actions user solo tiene acceso de push.

---

## Consideraciones Adicionales

| Área | Problema | Recomendación |
|------|----------|---------------|
| **Migraciones DB** | Las migraciones Prisma no están en el pipeline | Añadir `prisma migrate deploy` como job separado antes del deploy, con rollback manual |
| **File uploads** (multer) | Los CVs subidos se pierden en cada deploy si están en el filesystem del container | Migrar a S3 + URL pública o presigned URL |
| **Secrets rotation** | Las credenciales actuales del schema.prisma están en git history | `git filter-repo` + rotar inmediatamente |
| **`CI: false`** en frontend build | Ignora warnings de ESLint | A largo plazo, corregir los warnings y poner `CI: true` |
| **`describe.skip`** | Los E2E de Cypress no aportan calidad al pipeline | Activarlos o eliminarlos del pipeline hasta que estén listos |
| **CORS** | Hardcodeado a localhost | Configurar via `FRONTEND_URL` env var |
| **Rate limiting** | No hay rate limiting en el backend Express | Añadir `express-rate-limit` antes de exponer a producción |
