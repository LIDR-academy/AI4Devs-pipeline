# CI/CD – Backend (tests, build, deploy EC2)

## 1. Secrets requeridos (GitHub)

Configurar en **Settings → Secrets and variables → Actions**:

| Secret        | Descripción                                      | Ejemplo           |
|---------------|---------------------------------------------------|-------------------|
| `EC2_SSH_KEY` | Clave privada SSH para conectar a la instancia   | Contenido de `.pem` |
| `HOST_DNS`    | Hostname o IP pública de la instancia EC2        | `ec2-xx-xx-xx-xx.compute.amazonaws.com` |
| `USERNAME`    | Usuario SSH en la instancia                      | `ec2-user`        |
| `TARGET_DIR`  | Directorio en EC2 donde se despliega el backend   | `/home/ec2-user/app` |

### Cómo configurarlos

1. Repo → **Settings** → **Secrets and variables** → **Actions**.
2. **New repository secret** para cada uno: nombre exacto y valor (sin espacios extra).
3. `EC2_SSH_KEY`: pegar todo el contenido del archivo `.pem`, incluyendo `-----BEGIN ... -----` y `-----END ... -----`.

## 2. Preparación de la instancia EC2

- Node.js 20 instalado (o el que use el backend).
- Usuario `USERNAME` con acceso SSH por clave.
- Directorio `TARGET_DIR` existente y con permisos para ese usuario.
- (Opcional) Unit systemd: copiar `backend/scripts/lti-backend.service` a `/etc/systemd/system/`, ajustar `WorkingDirectory` a `TARGET_DIR` y usuario, luego:

  ```bash
  sudo systemctl daemon-reload
  sudo systemctl enable lti-backend
  sudo systemctl start lti-backend
  ```

- Base de datos PostgreSQL accesible y `DATABASE_URL` (o URL en `backend/prisma`/env) configurado en el entorno del servicio o en `.env` en `TARGET_DIR`.

## 3. Cómo correr tests localmente

```bash
cd backend
npm install
npx prisma generate
npm test
```

Build y arranque:

```bash
npm run build
npm start
# Health: curl http://localhost:3010/health
```

## 4. Workflow (`.github/workflows/ci.yml`)

- **pull_request** (ramas hacia `main`, eventos `opened` y `synchronize`): ejecuta **test-backend** y **build-backend**. No despliega.
- **push** a **main**: ejecuta test, build y **deploy-ec2** (subida con `easingthemes/ssh-deploy`, instalación de deps en EC2, reinicio de `lti-backend`, healthcheck por SSH).

El pipeline **falla** si:

- Fallan los tests.
- Fallan el build o la subida del artefacto.
- Fallan la instalación en EC2, el reinicio del servicio o el healthcheck (`/health`).

## 5. Checklist de validación end-to-end

- [ ] Secrets `EC2_SSH_KEY`, `HOST_DNS`, `USERNAME`, `TARGET_DIR` configurados en el repo.
- [ ] EC2 con Node 20, directorio `TARGET_DIR` y (opcional) unit `lti-backend` instalado.
- [ ] Base de datos accesible desde EC2 y variables de entorno (o `.env`) configuradas.
- [ ] Abrir un PR a `main` y hacer push: en **Actions** se ven **test-backend** y **build-backend** en verde.
- [ ] Hacer merge a `main` (o push directo a `main`): en **Actions** se ejecuta **deploy-ec2** y el healthcheck por SSH termina en éxito.
- [ ] En EC2: `curl http://localhost:3010/health` devuelve `{"status":"ok"}` (o comprobar desde el navegador si el puerto está expuesto).
