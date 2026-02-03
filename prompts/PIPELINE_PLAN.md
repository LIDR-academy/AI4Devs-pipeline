# Pipeline CI/CD: GitHub Actions + AWS EC2

## 1. Vision General del Pipeline

### 1.1 Diagrama Logico del Flujo

```mermaid
flowchart LR
    subgraph trigger [Trigger]
        A[Push a rama]
        B{PR abierto?}
        A --> B
        B -->|No| C[Pipeline NO se ejecuta]
        B -->|Si| D[Pipeline INICIA]
    end

    subgraph pipeline [Pipeline Jobs]
        D --> E[Job: Test]
        E --> F[Job: Build]
        F --> G[Job: Deploy]
    end

    subgraph testJob [Job Test]
        E1[Checkout codigo]
        E2[Setup Node.js 20]
        E3[Instalar dependencias]
        E4[Generar Prisma Client]
        E5[Ejecutar Jest]
        E1 --> E2 --> E3 --> E4 --> E5
    end

    subgraph buildJob [Job Build]
        F1[Checkout codigo]
        F2[Setup Node.js 20]
        F3[Instalar dependencias]
        F4[Compilar TypeScript]
        F5[Upload artifact]
        F1 --> F2 --> F3 --> F4 --> F5
    end

    subgraph deployJob [Job Deploy]
        G1[Download artifact]
        G2[Configurar SSH]
        G3[Conectar EC2 via SSH]
        G4[Transferir archivos]
        G5[Reiniciar servicio]
        G1 --> G2 --> G3 --> G4 --> G5
    end

    E -.-> testJob
    F -.-> buildJob
    G -.-> deployJob
```

### 1.2 Justificacion Tecnica del Trigger "Push + PR Abierto"

**Problema a resolver**: GitHub Actions no tiene un trigger nativo que combine "push" con "PR existente". Las opciones disponibles son:

| Trigger        | Comportamiento                    | Problema                                  |
| -------------- | --------------------------------- | ----------------------------------------- |
| `push`         | Se ejecuta en TODO push           | Ejecutaria en ramas sin PR                |
| `pull_request` | Se ejecuta al abrir/actualizar PR | Solo sincroniza HEAD del PR, no cada push |

**Solucion tecnica**: Usar trigger `push` con una **condicion de verificacion** que consulte la API de GitHub para confirmar si existe un PR abierto para esa rama.

```yaml
on:
    push:
        branches-ignore:
            - main
            - master

jobs:
    check-pr:
        runs-on: ubuntu-latest
        outputs:
            has_pr: ${{ steps.check.outputs.has_pr }}
        steps:
            - name: Check if branch has open PR
              id: check
              env:
                  GH_TOKEN: ${{ github.token }}
              run: |
                  PR_COUNT=$(gh pr list --repo ${{ github.repository }} --head ${{ github.ref_name }} --state open --json number --jq 'length')
                  if [ "$PR_COUNT" -gt 0 ]; then
                    echo "has_pr=true" >> $GITHUB_OUTPUT
                  else
                    echo "has_pr=false" >> $GITHUB_OUTPUT
                  fi
```

Los jobs posteriores dependeran de `check-pr` y solo se ejecutaran si `has_pr == 'true'`.

### 1.3 Suposiciones Explicitas

| Aspecto               | Valor Asumido                   | Justificacion                     |
| --------------------- | ------------------------------- | --------------------------------- |
| Lenguaje backend      | Node.js 20 LTS con TypeScript   | Detectado en `package.json`       |
| Framework             | Express.js 4.19.2               | Detectado en dependencias         |
| Build output          | `./dist` (JavaScript compilado) | Configurado en `tsconfig.json`    |
| Test framework        | Jest 29.7.0 con ts-jest         | Detectado en `jest.config.js`     |
| Base de datos         | PostgreSQL                      | Detectado en Prisma schema        |
| Sistema operativo EC2 | Amazon Linux 2023               | AMI oficial AWS, usuario ec2-user |
| Proceso manager       | PM2 o systemd                   | Para mantener el proceso activo   |
| Puerto aplicacion     | 3000 (por defecto Express)      | Asumido, verificar en `index.ts`  |

---

## 2. Planificacion por Fases

### Fase 0: Prerrequisitos

**Objetivo**: Verificar que todos los elementos necesarios estan disponibles antes de comenzar.

**Que se verifica**:

-   Cuenta AWS con permisos para EC2, Security Groups, Key Pairs
-   Repositorio GitHub con permisos de administracion (para Secrets)
-   Backend funcional localmente (`npm test` y `npm run build` exitosos)
-   Clave SSH generada o disponible para EC2

**Herramientas**:

-   AWS Console o AWS CLI
-   GitHub CLI (`gh`) o interfaz web
-   Terminal local para pruebas

**Riesgos habituales**:

-   Permisos IAM insuficientes en AWS
-   Tests fallando localmente (el pipeline fallara igual)
-   `prisma generate` no ejecutado antes de tests

**Checklist Fase 0**:

-   `cd backend && npm install` exitoso
-   `cd backend && npx prisma generate` exitoso
-   `cd backend && npm test` exitoso (todos los tests pasan)
-   `cd backend && npm run build` genera `./dist` correctamente
-   Acceso a AWS Console con permisos EC2
-   Acceso a GitHub repo con permisos Settings > Secrets

---

### Fase 1: Preparacion de AWS (EC2)

**Objetivo**: Crear y configurar la instancia EC2 que recibira el despliegue.

**Que se configura**:

#### 1.1 Crear Key Pair SSH

```bash
# En AWS Console: EC2 > Key Pairs > Create key pair
# Nombre: lti-backend-deploy-key
# Tipo: RSA
# Formato: .pem (para Linux/Mac) o .ppk (para PuTTY)
```

**Guardar el archivo `.pem` de forma segura** - se usara en GitHub Secrets.

#### 1.2 Crear Security Group

```
Nombre: lti-backend-sg
VPC: Default VPC

Reglas Inbound:
| Tipo  | Protocolo | Puerto | Origen         | Descripcion                          |
|-------|-----------|--------|----------------|--------------------------------------|
| SSH   | TCP       | 22     | 0.0.0.0/0      | Acceso SSH (solo autenticacion clave)|
| HTTP  | TCP       | 80     | 0.0.0.0/0      | Trafico web (proxy nginx opcional)   |
| Custom| TCP       | 3000   | 0.0.0.0/0      | API Express directa                  |

Reglas Outbound:
| Tipo     | Protocolo | Puerto | Destino   |
|----------|-----------|--------|-----------|
| All      | All       | All    | 0.0.0.0/0 |
```

**Nota de seguridad sobre SSH abierto (0.0.0.0/0)**:
Se permite SSH desde cualquier IP para facilitar:

1. Conexiones desde VPN con IP dinamica
2. Despliegues desde GitHub Actions (IPs variables de runners)

**Mitigaciones de seguridad**:

-   **Solo autenticacion por clave SSH**: Deshabilitado login por password (`PasswordAuthentication no`)
-   **Usuario no-root**: Conexion como `ec2-user`, no como `root`
-   **PermitRootLogin deshabilitado**: Impide acceso directo como root

**Nota**: fail2ban no esta disponible facilmente en Amazon Linux 2023 (requiere EPEL incompatible). La autenticacion solo por clave SSH es suficientemente segura para este ejercicio.

#### 1.3 Lanzar Instancia EC2

```
AMI: Amazon Linux 2023 AMI (HVM), SSD Volume Type
     amazon/al2023-ami-2023.x.x-kernel-6.1-x86_64 o buscar "Amazon Linux 2023"

Tipo instancia: t2.micro (Free Tier) o t3.small (recomendado)
  - t2.micro: 1 vCPU, 1 GB RAM - suficiente para desarrollo/staging
  - t3.small: 2 vCPU, 2 GB RAM - recomendado para produccion ligera

Key pair: lti-backend-deploy-key (creado en paso 1.1)
Security Group: lti-backend-sg (creado en paso 1.2)
Storage: 20 GB gp3 (suficiente para aplicacion Node.js)

Tags:
  - Name: lti-backend-server
  - Environment: staging
  - Project: AI4Devs-pipeline

IMPORTANTE: Amazon Linux 2023 usa usuario `ec2-user` (NO `ubuntu`)
```

#### 1.4 Configurar Elastic IP (Opcional pero recomendado)

```bash
# Asociar Elastic IP para IP estatica
# EC2 > Elastic IPs > Allocate > Associate con la instancia
```

#### 1.5 Instalar Dependencias en EC2

Conectar via SSH:

```bash
ssh -i "lti-backend-deploy-key.pem" ec2-user@<IP_PUBLICA>
```

Ejecutar los siguientes comandos:

```bash
# Actualizar sistema (Amazon Linux 2023 usa dnf)
sudo dnf update -y

# Instalar Node.js 20 LTS desde los repos de Amazon Linux
sudo dnf install -y nodejs20 nodejs20-npm

# Verificar instalacion
node --version  # v20.x.x
npm --version   # 10.x.x

# Instalar PM2 globalmente (gestor de procesos)
sudo npm install -g pm2

# Crear directorio para la aplicacion
sudo mkdir -p /var/www/lti-backend
sudo chown -R ec2-user:ec2-user /var/www/lti-backend

# Crear archivo de variables de entorno
nano /var/www/lti-backend/.env
# Contenido (ajustar valores para produccion):
# DB_PASSWORD=<password_produccion>
# DB_USER=<usuario_produccion>
# DB_NAME=LTIdb
# DB_PORT=5433
# DATABASE_URL="postgresql://${DB_USER}:${DB_PASSWORD}@<RDS_ENDPOINT>:5433/${DB_NAME}"
# NODE_ENV=production
# PORT=3000
```

**Nota**: En Amazon Linux 2023, Node.js 20 LTS esta disponible en los repositorios oficiales.

#### 1.6 Verificar Seguridad SSH (OBLIGATORIO)

**Nota sobre fail2ban**: fail2ban no esta disponible facilmente en Amazon Linux 2023 (EPEL 9 no es compatible). Sin embargo, con autenticacion solo por clave SSH, los ataques de fuerza bruta no son efectivos ya que no hay passwords que adivinar.

```bash
# Editar configuracion SSH
sudo nano /etc/ssh/sshd_config
```

**Verificar/modificar estas lineas**:

```
PasswordAuthentication no
PermitRootLogin no
PubkeyAuthentication yes
```

```bash
# Reiniciar servicio SSH
sudo systemctl restart sshd

# IMPORTANTE: Mantener la sesion SSH actual abierta
# y probar conexion en otra terminal antes de cerrar
```

**Herramientas que intervienen**:

-   AWS Console / AWS CLI
-   SSH client
-   dnf (gestor de paquetes de Amazon Linux 2023)
-   PM2 (process manager)

**Riesgos habituales**:

-   Olvidar abrir puerto 22 en Security Group → no se puede conectar
-   Key pair perdido → instancia inaccesible
-   Permisos de directorio incorrectos → deploy falla
-   Base de datos no accesible desde EC2 (si usa RDS, verificar Security Groups)
-   Deshabilitar PasswordAuthentication sin verificar que la clave funciona → bloqueado del servidor
-   PM2 no encontrado → crear symlink correcto a `/usr/lib/nodejs20/lib/node_modules/pm2/bin/pm2`

---

### Fase 2: Preparacion del Repositorio GitHub

**Objetivo**: Configurar los secretos y permisos necesarios en GitHub.

**Que se configura**:

#### 2.1 GitHub Secrets Necesarios

Navegar a: `Settings > Secrets and variables > Actions > New repository secret`

| Nombre del Secret | Valor                                          | Descripcion                 |
| ----------------- | ---------------------------------------------- | --------------------------- |
| `EC2_HOST`        | `54.xx.xx.xx` o `ec2-xx.compute.amazonaws.com` | IP publica o DNS de EC2     |
| `EC2_USER`        | `ec2-user`                                     | Usuario SSH de Amazon Linux |
| `EC2_SSH_KEY`     | Contenido completo del archivo `.pem`          | Clave privada SSH           |
| `EC2_DEPLOY_PATH` | `/var/www/lti-backend`                         | Ruta destino en EC2         |

**Como obtener el contenido de la clave SSH**:

```bash
# Linux/Mac
cat lti-backend-deploy-key.pem

# Windows PowerShell
Get-Content lti-backend-deploy-key.pem -Raw

# Copiar TODO el contenido, incluyendo:
# -----BEGIN RSA PRIVATE KEY-----
# ...
# -----END RSA PRIVATE KEY-----
```

#### 2.2 Variables de Entorno (Opcionales)

Para valores no sensibles, usar Variables en lugar de Secrets:
`Settings > Secrets and variables > Actions > Variables`

| Nombre         | Valor  |
| -------------- | ------ |
| `NODE_VERSION` | `20`   |
| `APP_PORT`     | `3000` |

#### 2.3 Permisos del GITHUB_TOKEN

El token automatico `${{ github.token }}` necesita permiso para consultar PRs:

```yaml
permissions:
    contents: read
    pull-requests: read
```

**Herramientas que intervienen**:

-   GitHub Web UI
-   GitHub CLI (`gh secret set`)

**Riesgos habituales**:

-   Clave SSH con formato incorrecto (espacios extra, saltos de linea)
-   Secret names con typos → workflow falla silenciosamente
-   IP de EC2 cambia si no hay Elastic IP → actualizar secret

---

### Fase 3: Diseno del Workflow de GitHub Actions

**Objetivo**: Crear el archivo `pipeline.yml` con la logica completa del CI/CD.

#### 3.1 Estructura del Archivo

Ruta: `.github/workflows/pipeline.yml`

```yaml
name: CI/CD Pipeline Backend

on:
  push:
    branches-ignore:
      - main
      - master

permissions:
  contents: read
  pull-requests: read

jobs:
  # Job 1: Verificar si existe PR abierto
  check-pr:
    ...

  # Job 2: Ejecutar tests
  test:
    needs: check-pr
    if: needs.check-pr.outputs.has_pr == 'true'
    ...

  # Job 3: Compilar TypeScript
  build:
    needs: test
    ...

  # Job 4: Desplegar en EC2
  deploy:
    needs: build
    ...
```

#### 3.2 Detalle de cada Job

**Job: check-pr**

-   **Runner**: `ubuntu-latest`
-   **Proposito**: Consultar API de GitHub para verificar PRs abiertos
-   **Output**: `has_pr` (boolean como string)
-   **Duracion estimada**: <10 segundos

**Job: test**

-   **Runner**: `ubuntu-latest`
-   **Depende de**: `check-pr` (solo si `has_pr == 'true'`)
-   **Steps**:
    1. `actions/checkout@v4`
    2. `actions/setup-node@v4` con Node 20
    3. `npm ci` en directorio backend
    4. `npx prisma generate`
    5. `npm test`
-   **Duracion estimada**: 1-3 minutos

**Job: build**

-   **Runner**: `ubuntu-latest`
-   **Depende de**: `test` (solo si test exitoso)
-   **Steps**:
    1. `actions/checkout@v4`
    2. `actions/setup-node@v4`
    3. `npm ci`
    4. `npx prisma generate`
    5. `npm run build`
    6. `actions/upload-artifact@v4` para `dist/`, `package.json`, `prisma/`
-   **Duracion estimada**: 1-2 minutos

**Job: deploy**

-   **Runner**: `ubuntu-latest`
-   **Depende de**: `build`
-   **Steps**:
    1. `actions/download-artifact@v4`
    2. Configurar SSH key desde secrets
    3. Transferir archivos via `rsync` o `scp`
    4. Ejecutar comandos remotos: `npm ci --production`, `npx prisma generate`, `pm2 restart`
-   **Duracion estimada**: 1-3 minutos

#### 3.3 Diagrama de Dependencias entre Jobs

```mermaid
flowchart TD
    A[check-pr] --> B{has_pr?}
    B -->|true| C[test]
    B -->|false| D[Pipeline termina sin ejecutar]
    C -->|success| E[build]
    C -->|failure| F[Pipeline falla]
    E -->|success| G[deploy]
    E -->|failure| F
    G -->|success| H[Despliegue exitoso]
    G -->|failure| F
```

**Herramientas que intervienen**:

-   GitHub Actions
-   Actions del marketplace: checkout, setup-node, upload-artifact, download-artifact
-   `gh` CLI (para verificar PRs)
-   rsync/scp/ssh

**Riesgos habituales**:

-   `npm ci` falla por `package-lock.json` desactualizado
-   Prisma generate olvidado → tests fallan
-   Artifact no incluye archivos necesarios
-   SSH timeout por Security Group mal configurado

---

### Fase 4: Testing, Validacion y Hardening

**Objetivo**: Validar el pipeline completo y aplicar mejoras de seguridad.

**Que se valida**:

#### 4.1 Test del Trigger

1. Crear rama de prueba: `git checkout -b test/pipeline-validation`
2. Hacer push SIN PR abierto → Pipeline no debe ejecutar jobs principales
3. Crear PR para la rama
4. Hacer otro push → Pipeline DEBE ejecutar todos los jobs

#### 4.2 Test de cada Job

-   **check-pr**: Verificar output `has_pr` en logs
-   **test**: Verificar que todos los tests pasen
-   **build**: Verificar que artifact contiene `dist/`, `package.json`, `prisma/`
-   **deploy**: Verificar que la aplicacion responde en EC2

#### 4.3 Hardening de Seguridad

**En EC2 (ya configurado en Fase 1)**:

-   PasswordAuthentication deshabilitado en `/etc/ssh/sshd_config`
-   PermitRootLogin deshabilitado
-   Solo autenticacion por clave publica
-   PM2 instalado y funcionando

**En GitHub Actions**:

-   No usar `sudo` en comandos remotos salvo estrictamente necesario
-   Restringir permisos SSH: `chmod 600` para la clave
-   Usar `npm ci` en lugar de `npm install` para builds reproducibles
-   Limpiar archivos temporales despues del deploy
-   Considerar usar `CODEOWNERS` para proteger `pipeline.yml`

**Verificacion de seguridad SSH**:

```bash
# Verificar que PasswordAuthentication esta deshabilitado
sudo grep -E "PasswordAuthentication|PermitRootLogin" /etc/ssh/sshd_config

# Output esperado:
# PasswordAuthentication no
# PermitRootLogin no (o #PermitRootLogin prohibit-password)
```

#### 4.4 Monitoreo Post-Deploy

```bash
# En EC2, verificar que PM2 mantiene el proceso
pm2 status
pm2 logs lti-backend

# Verificar respuesta de la API
curl http://localhost:3000/health  # Si existe endpoint
```

**Herramientas que intervienen**:

-   GitHub Actions UI (logs)
-   SSH a EC2
-   curl/Postman para verificar API

**Riesgos habituales**:

-   Pipeline funciona en PR inicial pero falla en siguientes pushes
-   Deploy exitoso pero aplicacion no arranca (error de configuracion)
-   PM2 no reinicia la app correctamente
