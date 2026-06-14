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
