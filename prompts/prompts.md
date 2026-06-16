# Prompts

Registro de los prompts utilizados durante el desarrollo de este ejercicio.

---

## Prompt 1

> Luego de este prompt, por favor guarda todos los prompt en prompts.md

## Prompt 2

> Estoy haciendo un ejercicio en clase para estudiar generación de pipelines automatizados mediante IA. Tengo cuenta en AWS (aunque nunca he usado AWS, solo Azure). En el sitio de github voy a crear el archivo .github/workflows/pipelines.ylm necesito tu ayuda para su contenido.

## Prompt 3

> Me faltó darte la instrucción que me dieron, presioné enter por accidente. Te faltan muchos detalles.

## Prompt 4

> Realiza el ejercicio
> Tu misión en este ejercicio es crear un pipeline en GitHub Actions que, tras el trigger "push a una rama con un Pull Request abierto", siga los siguientes pasos:
>
> Pase unos tests de backend.
>
> Genere un build del backend.
>
> Despliegue el backend en un EC2.
>
> Para ello, debes seguir estos pasos:
>
> Configurar el workflow de GitHub Actions en un archivo .github/workflows/pipeline.yml.
>
> Documentar los prompts utilizados para generar cada paso del pipeline:
>
> Tests de backend.
>
> Generación del build del backend.
>
> Despliegue del backend en EC2.
>
> Asegúrate de que el pipeline se dispare con un push a una rama con un Pull Request abierto.

---

# Documentación de prompts por paso del pipeline

A continuación se documentan los prompts (reutilizables) empleados para generar cada
paso del workflow `.github/workflows/pipeline.yml`. Cada uno asume el contexto del
repositorio: backend Node + Express + TypeScript + Prisma, con `npm run build` (tsc),
`npm test` (Jest) y despliegue en una instancia EC2 gestionada con PM2.

## Trigger del pipeline

> Crea un workflow de GitHub Actions que se dispare con "push a una rama que tiene un
> Pull Request abierto". Usa el evento `pull_request` con los tipos `opened`,
> `synchronize` y `reopened` (el tipo `synchronize` es el que se dispara al hacer push
> de nuevos commits a la rama de un PR ya abierto). Añade `concurrency` para cancelar
> ejecuciones anteriores de la misma rama.

## Paso 1 — Tests del backend

> Genera un job de GitHub Actions llamado `test` que ejecute los tests del backend.
> El backend está en la carpeta `backend/`, usa Node 18 y Jest (`npm test`). Pasos:
> hacer checkout, configurar Node con caché de npm apuntando a
> `backend/package-lock.json`, instalar dependencias con `npm ci`, generar el cliente
> de Prisma con `npx prisma generate` (los tests importan `@prisma/client` pero lo
> mockean, así que no hace falta una base de datos real) y finalmente ejecutar
> `npm test`. Usa `defaults.run.working-directory: backend`.

## Paso 2 — Build del backend

> Añade un job `build` que dependa de `test` (`needs: test`) y compile el backend.
> Reutiliza checkout + setup-node + `npm ci` + `npx prisma generate`, y luego ejecuta
> `npm run build` (que lanza `tsc` y genera la carpeta `dist/`). Empaqueta lo necesario
> para producción (`dist/`, `package.json`, `package-lock.json`, `prisma/`) y súbelo
> como artefacto con `actions/upload-artifact` para que el job de despliegue lo
> reutilice sin recompilar.

## Paso 3 — Despliegue del backend en EC2

> Añade un job `deploy` que dependa de `build` (`needs: build`) y despliegue el backend
> en una instancia EC2 por SSH. Descarga el artefacto del build, cópialo a la instancia
> con `appleboy/scp-action` (usando `strip_components: 1` para dejar los archivos en
> `~/lti-backend`) y luego conéctate con `appleboy/ssh-action` para ejecutar en el
> servidor: `npm ci`, `npx prisma generate`, `npx prisma migrate deploy` y reiniciar la
> app con PM2 (`pm2 restart lti-backend || pm2 start dist/index.js --name lti-backend`).
> Usa los secrets `EC2_HOST`, `EC2_USER` y `EC2_SSH_KEY` del repositorio.

## Prompt 5

> Antes de hacer el commit ¿Cómo obtengo el key del C2 y dónde debo guardarlo?

## Prompt 6

> Ya hice todos los pasos. Ahora sí puedes hacer el commmit y el push
