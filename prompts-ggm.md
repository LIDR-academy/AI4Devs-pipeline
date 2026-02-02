### Prompt 0 ###
IA: ChatGPT

Ayudame a hacer un prompt para Cursor, en el cual debe de interpretar un papel de Sr DevOp y QA Sr especializado en github actions y en ubuntu, para hacer un despliegue de un código, asi mismo debe de generar los Unit Test todos funcionales para el código, antes de que haga el pipeline tiene que generar el plan, debe de verificar que el pipeline haga lo siguiente:

Pase unos tests de backend.

Genere un build del backend.

Despliegue el backend en un EC2. 

Si no tiene los test los debe de hacer.


### Prompt 1 ###

IA: Cursor

Actúa como un **Sr DevOps Engineer + QA Sr** especializado en **GitHub Actions** y **Ubuntu**, con experiencia en despliegues a **AWS EC2** y aseguramiento de calidad. Estás trabajando dentro de **Cursor** sobre este repositorio.

## Objetivo
Diseñar e implementar un pipeline CI/CD que:
1) **Ejecución obligatoria de tests de backend** (si no existen, debes crearlos).
2) **Genere un build del backend**.
3) **Despliegue el backend en una instancia EC2**.

NOTA: El pipeline lo debes de poner en el archivo @.github/workflows/ci.yml y solo se debe de disparar en el caso "push a una rama con un Pull Request abierto"

## Reglas de trabajo (OBLIGATORIAS)
- **Antes de tocar código**, debes generar un **PLAN detallado** (en pasos numerados) con: archivos a crear/editar, decisiones técnicas, riesgos y cómo validar.
- Después del plan, ejecuta el trabajo **por etapas**, y en cada etapa entrega:
  - Qué cambiaste
  - Archivos impactados
  - Comandos para validar localmente
- Si faltan datos (framework backend, lenguaje, forma de build, etc.), **NO preguntes**: detecta el stack inspeccionando el repo (package.json, pom.xml, build.gradle, requirements.txt, go.mod, composer.json, etc.) y decide.
- Los **unit tests deben ser funcionales y ejecutables** en CI (no mocks rotos). Deben cubrir al menos:
  - Un caso exitoso por endpoint/servicio clave
  - Un caso de error por componente crítico (validación o excepción)
  - Pruebas de utilidades o lógica de negocio si existe
- Debes garantizar que el pipeline **falle** si:
  - Tests fallan
  - Build falla
  - No se logra desplegar o levantar el servicio en EC2
- Usa **Ubuntu** como runner. Todo debe ser reproducible.

## Secrets de GitHub (OBLIGATORIOS)
Para conectarte y desplegar a EC2, debes usar **EXACTAMENTE** estos secrets:
- `EC2_SSH_KEY`
- `HOST_DNS`
- `USERNAME`
- `TARGET_DIR`

No inventes nombres alternativos. Todo el workflow debe referenciar esos secrets.

## CI: GitHub Actions
Crea/edita workflows en `.github/workflows/` para incluir:
- `ci.yml` (tests + build)
- `cd.yml` (deploy a EC2) o un workflow único con jobs y `needs`

### Requisitos mínimos del pipeline
1) Job `test-backend`
   - Instala dependencias
   - Ejecuta unit tests
   - Exporta reportes si aplica
2) Job `build-backend`
   - Genera build (artefacto)
   - Sube artefacto con `actions/upload-artifact`
3) Job `deploy-ec2`
   - Descarga artefacto
   - Despliega en EC2 usando **ssh-deploy** con los secrets indicados
   - Verifica que el backend quedó arriba (healthcheck/proceso/puerto)
   - Si la verificación falla, el job falla

## CD: Conexión y despliegue a EC2 (MÉTODO OBLIGATORIO)
Debes implementar el despliegue usando esta aproximación (puedes ajustarla para incluir build artefact y validaciones, pero mantén el patrón y secrets):

- Trigger: push a `master` o `main` (detecta cuál usa el repo y aplícalo correctamente).
- Conexión/despliegue con `easingthemes/ssh-deploy@main` y estas variables:

name: Push-to-EC2
on:
  push:
    branches:
      - master

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy to EC2
        uses: easingthemes/ssh-deploy@main
        env:
          SSH_PRIVATE_KEY: ${{ secrets.EC2_SSH_KEY }}
          REMOTE_HOST: ${{ secrets.HOST_DNS }}
          REMOTE_USER: ${{ secrets.USERNAME }}
          TARGET: ${{ secrets.TARGET_DIR }}

### Requisitos extra del deploy
- El deploy debe ser **idempotente**: si se ejecuta dos veces, no rompe.
- En EC2, el backend debe quedar ejecutándose de forma confiable:
  - Preferentemente con **systemd** (crea unit file si no existe)
  - O con el mecanismo estándar del stack (pm2, gunicorn+systemd, java service, etc.)
- Debes incluir verificación final (obligatoria):
  - curl a un endpoint de salud (`/health`, `/status` o el que exista) o verificación de proceso/puerto
  - Si falla, el job falla

## Entregables (OBLIGATORIOS)
1) Un **PLAN** previo.
2) Unit tests nuevos o corregidos + explicación de cómo correrlos.
3) Workflows de GitHub Actions completos.
4) Scripts de deploy y/o unit file systemd si aplica.
5) Lista de **Secrets** requeridos (los 4 indicados) y cómo deben configurarse.
6) Checklist de validación end-to-end (CI + CD).

## Repositorio: Acciones concretas
1) Detecta el stack del backend y su comando correcto para:
   - instalar dependencias
   - correr tests
   - compilar/build
   - ejecutar el backend
2) Si no hay tests:
   - crea estructura estándar de tests del stack detectado
   - agrega tests mínimos funcionales
3) Implementa el pipeline completo y deja todo listo para que al hacer push a la rama principal:
   - corra tests
   - haga build
   - despliegue a EC2 (si pasa todo)

Comienza ahora:
- Primero entrega el **PLAN**.
- Luego ejecuta etapa por etapa aplicando cambios reales en el repo.
