# Prompt GitHub Actions Pipeline Implementation

Necesito crear un pipeline completo de GitHub Actions para el repositorio AI4Devs-pipeline que automatice el testing, build y deployment del backend en EC2. El proyecto es una aplicación full-stack con backend en Node.js/TypeScript/Express/Prisma y frontend en React.

## Contexto del proyecto

- Backend: Node.js + TypeScript + Express + Prisma ORM + PostgreSQL
- Estructura: Arquitectura hexagonal con capas (domain, application, infrastructure, presentation)
- Tests: Jest configurado con archivos de test en src/application/services/ y src/presentation/controllers/
- Scripts disponibles: npm run test, npm run build, npm start
- Puerto del backend: 3010
- Base de datos: PostgreSQL (configurada con Docker Compose)

## Requisitos del pipeline

1. Trigger: Se debe disparar con push a una rama que tenga un Pull Request abierto
2. Tests de Backend: Ejecutar todos los tests unitarios del backend
3. Build del Backend: Compilar el código TypeScript a JavaScript
4. Deploy en EC2: Desplegar el backend compilado en una instancia EC2

## Configuración necesaria

- Variables de entorno requeridas: AWS_ACCESS_ID, AWS_ACCESS_KEY, EC2_INSTANCE
- El backend debe ejecutarse en el puerto 3010
- Usar PM2 para gestión de procesos en EC2
- Configurar Nginx como proxy reverso (opcional pero recomendado)

## Estructura esperada

- Crear archivo .github/workflows/pipeline.yml
- Documentar cada paso del pipeline
- Incluir manejo de errores y rollback
- Configurar timeouts apropiados
- Asegurar que el pipeline falle rápido si hay errores

## Consideraciones técnicas

- El backend usa Prisma, así que necesitará npx prisma generate antes del build
- Los tests están en Jest y deben ejecutarse antes del build
- El deployment debe incluir la instalación de dependencias de producción
- Configurar variables de entorno en EC2 para la conexión a la base de datos
