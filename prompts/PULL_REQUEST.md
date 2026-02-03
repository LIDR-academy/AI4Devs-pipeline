# CI/CD Pipeline con GitHub Actions y AWS EC2

## Resumen

Este PR implementa un pipeline de CI/CD completo utilizando GitHub Actions para automatizar el proceso de testing, build y despliegue del backend en una instancia EC2 de AWS.

## Cambios Realizados

-   Creado archivo `.github/workflows/pipeline.yml` con el workflow completo

## Arquitectura del Pipeline

```
Push a rama → ¿Tiene PR? → Tests → Build → Deploy EC2
                  ↓
              (No PR)
                  ↓
               STOP
```

### Jobs del Pipeline

| Job        | Descripción                                | Duración estimada |
| ---------- | ------------------------------------------ | ----------------- |
| `check-pr` | Verifica si existe PR abierto para la rama | ~10s              |
| `test`     | Ejecuta `npm test` con Jest                | 1-3 min           |
| `build`    | Compila TypeScript y genera artifact       | 1-2 min           |
| `deploy`   | Transfiere archivos y reinicia con PM2     | 1-3 min           |

## Trigger del Pipeline

El pipeline se ejecuta **únicamente** cuando:

1. Se hace push a una rama (excepto `main`/`master`)
2. Esa rama tiene un **Pull Request abierto**

Esto evita ejecuciones innecesarias en ramas de desarrollo sin PR.

## Configuración Requerida

### Secrets de GitHub (ya configurados)

| Secret            | Descripción                                 |
| ----------------- | ------------------------------------------- |
| `EC2_HOST`        | IP pública de la instancia EC2              |
| `EC2_USER`        | Usuario SSH (`ec2-user`)                    |
| `EC2_SSH_KEY`     | Clave privada SSH (.pem)                    |
| `EC2_DEPLOY_PATH` | Ruta de despliegue (`/var/www/lti-backend`) |

### Instancia EC2 (ya configurada)

-   **OS**: Amazon Linux 2023
-   **Node.js**: v20 LTS
-   **Process Manager**: PM2
-   **Seguridad**: Solo autenticación por clave SSH

## Flujo de Despliegue

1. **Build en GitHub Actions**: Compila TypeScript → `dist/`
2. **Artifact**: Empaqueta `dist/`, `package.json`, `prisma/`
3. **Transfer**: rsync via SSH a EC2
4. **Install**: `npm ci --production` en EC2
5. **Prisma**: `npx prisma generate`
6. **Restart**: `pm2 reload lti-backend`

## Test Plan

-   [ ] Verificar que push SIN PR abierto no ejecuta el pipeline
-   [ ] Verificar que push CON PR abierto ejecuta todos los jobs
-   [ ] Verificar que tests pasan correctamente
-   [ ] Verificar que build genera artifact válido
-   [ ] Verificar que deploy conecta a EC2
-   [ ] Verificar que la aplicación responde después del deploy

## Notas Adicionales

-   El pipeline usa Node.js 20 LTS
-   Los artifacts se retienen por 7 días
-   La clave SSH se limpia automáticamente después del deploy (paso `always()`)
