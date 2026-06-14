# Prompts — Pipeline CI/CD en GitHub Actions (Proyecto LTI)

**Alumno:** Curro Martínez Hidalgo
**Rama:** pipeline-CMH
**Módulo:** 13 — DevSecOps
**Herramienta de IA utilizada:** Claude Code (ejecución) + Claude (diseño y tutoría)

## ¿Qué encontrarás en este fichero?
Registro cronológico de los prompts utilizados para generar, paso a paso, el
pipeline de GitHub Actions del backend del proyecto LTI. Cada sección incluye el
objetivo del paso, el prompt exacto lanzado a Claude Code y la validación
realizada sobre el resultado (revisar siempre el output de la IA, no aceptarlo a
ciegas).

---

## Contexto del proyecto
- **Backend:** Node.js + TypeScript + Express + Prisma (PostgreSQL).
- **Tests:** Jest, autocontenidos (mockean Prisma, no requieren BD ni migraciones).
- **Build:** `npm run build` (`tsc` → `dist/`). `npm start` ejecuta `dist/index.js`
  y requiere build previo.
- **Puerto del backend:** 3010.
- **Trigger requerido:** push a una rama con un Pull Request abierto.

## Decisión de arquitectura — método de despliegue
Para el deploy a EC2 se valoraron dos opciones:

| Opción | Cómo | Pros | Contras |
|--------|------|------|---------|
| **A — AWS SSM Run Command** (elegida) | El runner se autentica en AWS con credenciales IAM y ordena la ejecución de comandos dentro de la EC2 vía Systems Manager | No requiere abrir el puerto 22 a internet; no hay clave SSH privada almacenada en GitHub; auditable; coste 0 (Run Command entra en free tier) | Setup inicial algo mayor (rol IAM + agente SSM en la instancia) |
| **B — SSH + S3** (solución oficial) | Sube el artefacto a S3 y se conecta por SSH/SCP a la EC2 | Más directo de montar | Expone el puerto 22; obliga a guardar una clave SSH privada como secret; mayor superficie de ataque |

**Se elige la Opción A (SSM)** por alineación con los principios *security-by-design*
del módulo DevSecOps: menor superficie de ataque, sin secretos SSH de larga vida y
sin puertos de administración expuestos. Se diverge conscientemente de la solución
oficial (que usa SSH+S3) tras analizar pros y contras.

**Secrets previstos en GitHub Actions:**
`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `EC2_INSTANCE_ID`.

---

## 0. Setup del contexto del proyecto

**Objetivo:** que Claude Code conozca el stack, la estructura y los comandos del
proyecto antes de generar el pipeline, para no repetir el contexto en cada prompt.

**Comando:**
> /init

**Resultado y validación:**
Genera `CLAUDE.md` en la raíz con las secciones Commands, Architecture y CI/CD.
Validado correctamente: detecta backend Node+TS+Prisma+Jest, build `npm run build`,
te

## 1. Trigger del workflow + Job de Tests

**Objetivo:** crear `.github/workflows/pipeline.yml` con el trigger correcto
(push a rama con PR abierto) y un job que ejecute los tests del backend, ya con
buenas prácticas de legibilidad y robustez.

**Prompt (estructura Goal / Return Format / Warnings / Requisitos de calidad / Context):**
> GOAL
> Crea un workflow de GitHub Actions en `.github/workflows/pipeline.yml` que se
> dispare al hacer push de commits a una rama con un Pull Request abierto, y que
> ejecute la suite de tests del backend.
>
> RETURN FORMAT
> Un único fichero YAML `.github/workflows/pipeline.yml` con un solo job `test`.
> No crees ni modifiques ningún otro fichero.
>
> WARNINGS
> - El fichero DEBE llamarse `pipeline.yml`, no `ci.yml` (ignora el ci.yml vacío).
> - Trigger: `pull_request` con tipos `[opened, synchronize, reopened]`
>   (synchronize = push a rama con PR abierto). No usar `on: push`.
> - Monorepo: ejecutar en `backend/` vía `defaults.run.working-directory`.
> - Usar `npm ci` (no `npm install`). Fijar versiones de las actions.
> - No añadir build ni deploy todavía.
>
> REQUISITOS DE CALIDAD
> - `name` del workflow: "Backend CI/CD".
> - Cada step con su `name` descriptivo (logs legibles).
> - `timeout-minutes: 10` en el job.
>
> CONTEXT
> - Backend Node + TS + Express + Prisma. Tests `npm test` (Jest), autocontenidos.
>   Node LTS 20. Caché npm sobre backend/package-lock.json. Ver CLAUDE.md.

**Validación:** generado correctamente en una sola pasada. Trigger, working-directory,
npm ci, caché y versiones de actions correctos; `name` del workflow descriptivo,
steps nombrados y timeout aplicados. Pendiente de validar en CI tras abrir el PR.

## 2. Job de Build del backend

**Objetivo:** añadir un job `build` que compile el backend y publique `dist/`
como artifact para el deploy, ejecutándose solo si los tests pasan.

**Prompt (Goal / Return Format / Warnings / Requisitos de calidad / Context):**
> GOAL
> Añade un segundo job `build` al workflow existente que compile el backend y
> publique el resultado como artifact para un futuro job de deploy.
> [... resto del prompt usado ...]
> WARNINGS
> - No modificar el job `test`. `build` depende de `test` vía `needs: test`.
> - VM limpia: checkout + setup Node + `npm ci` propios antes de compilar.
> - Compilar con `npm run build` (genera backend/dist/).
> - Subir backend/dist con actions/upload-artifact@v4, nombre `backend-dist`.
> REQUISITOS DE CALIDAD
> - El `path` de upload-artifact se resuelve desde la raíz: usar `backend/dist`.

**Validación:** lógica correcta — `needs: test` bien aplicado, job autónomo con
su propio npm ci, build con `npm run build`, artifact `backend-dist` con
`path: backend/dist` (gotcha de la ruta resuelto). Corrección posterior: el
fichero llegó con toda la indentación desplazada a la derecha (YAML inválido);
se reajustó la sangría a 2 espacios con las claves raíz sin indentar. Lección:
en YAML la indentación es sintaxis, validar siempre con linter (extensión YAML
de VS Code).

## 3. Job de Deploy a EC2 vía AWS SSM

**Objetivo:** añadir un job `deploy` que despliegue el backend en la EC2 usando
AWS Systems Manager (SSM) Run Command, sin SSH, ejecutándose solo si el build pasa.

**Prompt inicial (Goal / Return Format / Warnings / Context):**
> GOAL
> Añade un tercer job `deploy` al workflow que despliegue el backend en EC2 vía
> AWS SSM Run Command, sin SSH.
> [...]
> WARNINGS
> - needs: build. Autenticar con aws-actions/configure-aws-credentials@v4 leyendo
>   AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION.
> - Desplegar con `aws ssm send-command` (DocumentName AWS-RunShellScript,
>   InstanceIds = secret EC2_INSTANCE_ID) ejecutando: git pull + npm ci +
>   prisma generate + npm run build + pm2 restart lti-backend.
> - Tras enviar, ESPERAR y FALLAR si el estado final del comando SSM no es Success.
> - El job no usa working-directory backend (sobreescribir a ".").
> CONTEXT
> - La EC2 ya tiene Node 20, git, PM2 y el repo clonado en
>   /home/ssm-user/AI4Devs-pipeline; proceso PM2 = lti-backend. Región eu-north-1.

**Prompt de ajuste (desplegar la rama del PR en vez de main):**
> Ajusta solo el job deploy para que el git pull use la rama que disparó el PR
> (${{ github.head_ref }}) en lugar de main: git fetch origin →
> git checkout ${{ github.head_ref }} → git pull origin ${{ github.head_ref }}.

**Validación:** generado correctamente. `needs: build` (cadena test→build→deploy),
configure-aws-credentials@v4 con los secrets, `aws ssm send-command` bien formado,
y paso de espera con polling cada 10s (máx 5 min) que distingue Success de
Failed/Cancelled/TimedOut/Undeliverable e imprime StandardErrorContent al fallar.
Resuelto el gotcha del working-directory (sobreescrito a "." en el job deploy).

**Consideración de arquitectura (PR vs producción):**
Por requisito explícito del ejercicio, el deploy se ejecuta en el evento
`pull_request` y despliega la rama del PR (`github.head_ref`), que es coherente con
el disparador. En un escenario de producción real, el despliegue NO se acoplaría al
PR: el PR actuaría solo como *quality gate* (tests + build), y el deploy se
dispararía al mergear a `main` mediante un trigger separado
(`on: push: branches: [main]`), desplegando únicamente código ya revisado y
aprobado. Se documenta esta diferencia de forma consciente.
