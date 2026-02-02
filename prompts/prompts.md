# REGISTRO DE PROMPTS UTILIZADOS
**Autor**: Pedro Cortes
**Proyecto**: LTI - Talent Tracking System
**Descripción**: Bitácora de prompts para trazabilidad del proyecto.
---

## 001 - Inicialización del Memory Bank
**Fecha:** 2026-02-02 06:08
**Prompt Original:**
> Eres una instancia experta de Gemini 3 operando como Architect Agent dentro de Google Antigravity.
> Debido a la naturaleza asíncrona y multi-agente de este IDE, tu responsabilidad es crear y mantener un Memory Bank (Estado Compartido). Esto asegura que si un agente edita el frontend y otro los tests, ambos compartan el mismo contexto sin pisarse.
>
> # Objetivo
> Generar la estructura de archivos de documentación y las Reglas de Agente (.agent/rules) para obligar a cualquier instancia de Gemini a leer el contexto antes de trabajar.
>
> ## 1. Estructura de Archivos a Generar
> Analiza el repositorio (@workspace) y genera el contenido para estos archivos. Si no puedes crearlos directamente, dame el código Markdown de cada uno:
>
> /memory-bank/
> projectbrief.md (Visión general del proyecto)
> productContext.md (Contexto de negocio y usuarios)
> systemPatterns.md (Arquitectura y diseño técnico)
> techContext.md (Stack, herramientas y comandos)
> activeContext.md (El estado actual "en vivo" del desarrollo)
> progress.md (Historial de cambios y deuda técnica)
>
> /.agent/rules/
> 00-memory-bank.md (Regla maestra de lectura obligatoria)
>
> ## 2. Definición del Contenido (Archivos Core)
>
> ### memory-bank/projectbrief.md
> Resumen ejecutivo.
> Objetivos clave.
>
> ### memory-bank/activeContext.md
> Crítico: Este archivo actúa como semáforo.
> Debe contener: "¿En qué estamos trabajando AHORA MISMO?"
> Lista de tareas activas.
> Próximos pasos inmediatos.
>
> ### memory-bank/systemPatterns.md
> Arquitectura del sistema.
> Mapa de carpetas clave.
> Relaciones entre módulos (quién depende de quién).
>
> ## 3. Configuración de la Regla (.agent/rules)
>
> Genera el archivo .agent/rules/00-memory-bank.md con el siguiente contenido EXACTO. Esto es lo que forzará a los agentes a comportarse correctamente:
>
> ---
> description: "Mandatory Memory Bank Workflow"
> globs: ["**/*"]
> alwaysApply: true
> priority: critical
> ---
>
> # AGENT MANDATE: Shared Memory Access
>
> You are working in a multi-agent environment (Antigravity). You must rely on the Memory Bank for the single source of truth.
>
> ## 1. Context Loading (READ FIRST)
> Before planning or executing ANY task, you MUST read:
> - memory-bank/activeContext.md -> To understand current focus.
> - memory-bank/systemPatterns.md -> To respect architecture.
> - memory-bank/techContext.md -> To use correct tools/commands.
>
> ## 2. Atomic Updates (WRITE BACK)
> After completing a task:
> 1. Update memory-bank/activeContext.md: Remove your finished task, add the result.
> 2. Update memory-bank/progress.md: Mark features as completed.
> 3. Self-Correction: If you find projectbrief.md or systemPatterns.md outdated, update them immediately.
>
> ## 3. Forbidden Actions
> - Do not invent commands not listed in techContext.md.
> - Do not modify core architecture without updating systemPatterns.md first.
>
> ## 4. Procedimiento de Inicialización
> 1. Ejecuta un escaneo profundo del repositorio.
> 2. Redacta el contenido de todos los archivos de /memory-bank/ basándote en el código existente.
> 3. Crea la carpeta .agent/rules/ y el archivo de reglas.
> 4. Confírmame cuando el "Cerebro del Proyecto" esté activo.

**Resumen de la Respuesta/Acción:**
Se ha generado la estructura completa del Memory Bank en `/memory-bank/` y se ha creado la regla obligatoria en `.agent/rules/00-memory-bank.md` para asegurar la consistencia del contexto entre agentes.
---

## 002 - Recuperación de Log de Prompts
**Fecha:** 2026-02-02 06:24
**Prompt Original:**
> Se te ha olvidado el registro del prompt en un archivo `prompts-log.md`. recuerda que todos los prompts deben ser almacenados

**Resumen de la Respuesta/Acción:**
Se ha identificado que el archivo de logs oficial es `prompts/prompts.md` (aunque se solicitó `prompts-log.md`). Se han registrado retroactivamente los prompts de la sesión actual.
---

## 003 - Configuración Pipeline CI/CD con GitHub Actions
**Fecha:** 2026-02-02 06:26
**Prompt Original:**
> # Objetivo
> Configurar un pipeline de CI/CD en GitHub Actions para este repositorio siguiendo requisitos específicos.
>
> # Instrucciones para el Agente
> Analiza el código base en @workspace y crea el archivo `.github/workflows/pipeline.yml`. El flujo debe cumplir con los siguientes puntos:
>
> 1. **Trigger Específico:**
>    - El pipeline debe dispararse únicamente cuando se haga un push a una rama que tenga un Pull Request abierto (evento `synchronize`).
>
> 2. **Steps del Job:**
>    - **Tests de Backend:** Identifica el lenguaje y framework del proyecto y configura la ejecución de los tests unitarios.
>    - **Build del Backend:** Genera el build o artefacto necesario según la tecnología detectada.
>    - **Despliegue en EC2:** Configura un paso de despliegue mediante SSH a una instancia de AWS EC2. 
>      - Utiliza la acción `appleboy/ssh-action`.
>      - Usa secretos de GitHub para: `EC2_HOST`, `EC2_USER` y `EC2_SSH_KEY`.
>      - El script de despliegue debe actualizar el código en el servidor y reiniciar el servicio.
>
> # Formato de Salida
> - Genera el código completo del archivo YAML.
> - Documenta brevemente los comandos utilizados en cada paso basándote en la tecnología que detectes en el repositorio.

**Resumen de la Respuesta/Acción:**
Se ha configurado el workflow `.github/workflows/pipeline.yml` para CI/CD con trigger `pull_request` (synchronize), tests de backend (Jest/Node), build (tsc) y despliegue a EC2 usando secretos.
---

## 004 - Implementación Autenticación OIDC
**Fecha:** 2026-02-02 07:00
**Prompt Original:**
> # Objetivo: Implementar Autenticación Segura OIDC para CI/CD
> Quiero eliminar el uso de AWS Access Keys permanentes y configurar el estándar de la industria: OIDC (OpenID Connect) con Roles de IAM para que GitHub Actions se comunique con AWS de forma segura.
>
> # Instrucciones para el Agente (@workspace)
> Basándote en el repositorio actual, genera una guía completa y el código necesario:
>
> 1. **Configuración de Infraestructura (CloudFormation o AWS CLI):**
>    - Proporciona los comandos o el template para crear el `Identity Provider` de GitHub en mi cuenta de AWS.
>    - Crea un `IAM Role` con una "Trust Policy" que solo permita el acceso desde este repositorio específico (`{{tu-usuario-o-organizacion}}/{{tu-repo}}`).
>    - Define una política de "Privilegio Mínimo" para este rol que solo permita realizar el despliegue en mi instancia EC2.
>
> 2. **Actualización del Pipeline (.github/workflows/pipeline.yml):**
>    - Configura los `permissions` del job (necesarios para OIDC): `id-token: write` y `contents: read`.
>    - Reemplaza cualquier login manual por la acción oficial `aws-actions/configure-aws-credentials@v4`.
>    - Utiliza el `role-to-assume` apuntando al ARN del rol creado.
>    - Mantén los pasos de Test, Build y el despliegue mediante SSH a la EC2.
>
> # Formato de Salida
> - Comandos de AWS CLI para la configuración inicial.
> - Código YAML completo y actualizado para el workflow de GitHub Actions.

**Resumen de la Respuesta/Acción:**
Se ha implementado OIDC en el pipeline y se han proporcionado comandos manuales para la configuración de AWS.
---

## 005 - Solicitud Script Configuración AWS
**Fecha:** 2026-02-02 07:11
**Prompt Original:**
> I need specific details about running the AWS CLI tool and configuring all this params

**Resumen de la Respuesta/Acción:**
Se ha creado un script automatizado `setup-oidc.sh` para facilitar la configuración del entorno AWS y eliminar la ambigüedad en la ejecución de comandos.
---

## 006 - Creación de Instancia EC2
**Fecha:** 2026-02-02 07:39
**Prompt Original:**
> Necesitaria tambien que me at¡yudaras a crear la EC2 instance en AWS. Revisa el codigo y dame los pasos para ello

**Resumen de la Respuesta/Acción:**
Se ha creado el script `setup-ec2.sh` para aprovisionar la instancia EC2, Security Group y Key Pair, facilitando el despliegue.
---

## 007 - Auditoría y Documentación
**Fecha:** 2026-02-02 08:23
**Prompt Original:**
> # Objetivo: Organización, Seguridad y Documentación del Repositorio
> Como Architect Agent, necesito que realices una auditoría y limpieza del repositorio antes de finalizar la implementación del pipeline.
>
> # Instrucciones para el Agente (@workspace)
>
> ## 1. Auditoría de Seguridad y Limpieza
> - Escanea el repositorio en busca de archivos sensibles que NO deban estar en el control de versiones (ej. archivos `.pem`, `.env`, archivos de logs o carpetas `node_modules`).
> - Si encuentras secretos o llaves expuestas, indícame cuáles son para eliminarlos y asegúrate de agregarlos al archivo `.gitignore`.
> - Organiza la estructura de carpetas si detectas desorden en los archivos de configuración.
>
> ## 2. Documentación (README.md)
> Crea o actualiza el archivo `README.md` incluyendo una sección específica para el Pipeline de CI/CD que contenga:
> - **Descripción:** Qué hace el pipeline (Tests, Build, Deploy a EC2 vía OIDC).
> - **Requisitos previos:** Menciona los Secrets de GitHub necesarios (`AWS_ROLE_ARN`, `EC2_HOST`, `EC2_USER`, `EC2_SSH_KEY`).
> - **Instrucciones de Testeo:** Pasos exactos para disparar el pipeline (crear rama, push y abrir PR).
> - **Guía de mantenimiento:** Cómo actualizar el comando de reinicio en la EC2 si el backend cambia.
>
> ## 3. Verificación de Estado
> - Revisa si el archivo `.github/workflows/pipeline.yml` está correctamente configurado con los permisos de OIDC.
> - Si falta algún paso técnico o configuración en AWS por realizar, lístalo al final de tu respuesta.

**Resumen de la Respuesta/Acción:**
(En progreso) Auditoría de seguridad (gitignore), actualización de README.md con documentación de CI/CD y verificación final de configuraciones.
---
