# Plan CI/CD – Backend (Node/Express + Prisma)

## Stack detectado
- **Backend**: Node.js, TypeScript, Express, Prisma (PostgreSQL)
- **Tests**: Jest, ts-jest
- **Comandos**: `npm install`, `npx prisma generate`, `npm test`, `npm run build`, `npm start` (puerto 3010)
- **Rama principal**: `main`

## Archivos creados/modificados
1. `backend/src/index.ts` – Ruta `GET /health`
2. `backend/src/application/validator.test.ts` – Tests del validador
3. Tests de error en positionService y positionController
4. `.github/workflows/ci.yml` – Workflow único (test, build, deploy)
5. `backend/scripts/deploy-ec2.sh` y `backend/scripts/lti-backend.service`
6. Documentación de secrets y checklist

## Triggers
- **pull_request** a `main`: test + build (sin deploy)
- **push** a `main`: test + build + deploy a EC2

## Secrets requeridos
- `EC2_SSH_KEY` – Clave privada SSH para EC2
- `HOST_DNS` – Hostname o IP de la instancia
- `USERNAME` – Usuario SSH (ej. ec2-user)
- `TARGET_DIR` – Directorio en EC2 donde desplegar (ej. /home/ec2-user/app)
