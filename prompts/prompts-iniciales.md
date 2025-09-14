# Prompts Iniciales - Pipeline GitHub Actions

Este documento contiene los prompts utilizados para generar cada paso del pipeline de GitHub Actions para el proyecto AI4Devs.

## 1. Tests de Backend

### Prompt utilizado:
```
Crea un workflow de GitHub Actions que ejecute los tests del backend de Node.js/TypeScript. El backend está en la carpeta ./backend y usa Jest para testing. El workflow debe:

1. Configurar Node.js 18
2. Instalar dependencias con npm ci
3. Ejecutar los tests con npm test
4. Generar reportes de cobertura
5. Subir los resultados de tests como artefactos
6. Fallar si los tests fallan

El backend tiene la siguiente estructura:
- package.json con script "test": "jest"
- jest.config.js configurado para TypeScript
- Tests en src/**/*.test.ts
```

### Resultado:
Se creó el job `test-backend` que:
- Usa `actions/setup-node@v4` para configurar Node.js 18
- Instala dependencias con `npm ci` para instalación limpia
- Ejecuta `npm test` en el directorio backend
- Sube los resultados de cobertura como artefactos
- Se ejecuta en cada push y pull request

## 2. Generación del Build del Backend

### Prompt utilizado:
```
Crea un job de GitHub Actions que genere el build de producción del backend. El backend:

1. Usa TypeScript y se compila con `npm run build`
2. Genera archivos en la carpeta `dist/`
3. Necesita incluir package.json y node_modules para producción
4. Debe crear un paquete de despliegue con todos los archivos necesarios
5. Debe subir el paquete como artefacto para el siguiente job

El job debe depender del job de tests y solo ejecutarse si los tests pasan.
```

### Resultado:
Se creó el job `build-backend` que:
- Depende del job `test-backend` (needs: test-backend)
- Compila el TypeScript con `npm run build`
- Crea un paquete de despliegue incluyendo:
  - Carpeta `dist/` compilada
  - `package.json` y `package-lock.json`
  - Carpeta `prisma/` para migraciones
- Comprime todo en `backend-deployment.tar.gz`
- Sube el paquete como artefacto para el job de despliegue

## 3. Despliegue del Backend en EC2

### Prompt utilizado:
```
Crea un job de GitHub Actions para desplegar el backend en una instancia EC2. El job debe:

1. Solo ejecutarse en push a main/develop (no en PRs)
2. Descargar el artefacto del build anterior
3. Configurar credenciales de AWS
4. Conectarse por SSH a la instancia EC2
5. Detener la aplicación anterior con PM2
6. Subir el nuevo código
7. Instalar dependencias de producción
8. Ejecutar migraciones de Prisma
9. Iniciar la aplicación con PM2
10. Verificar que el despliegue fue exitoso

Usa los siguientes secrets:
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- EC2_HOST
- EC2_USERNAME
- EC2_SSH_KEY
```

### Resultado:
Se creó el job `deploy-backend` que:
- Solo se ejecuta en push a main/develop (`if: github.event_name == 'push'`)
- Depende de los jobs de tests y build
- Configura credenciales AWS con `aws-actions/configure-aws-credentials@v4`
- Usa `appleboy/ssh-action@v1.0.3` para comandos SSH
- Usa `appleboy/scp-action@v0.1.7` para subir archivos
- Gestiona la aplicación con PM2 (stop, delete, start, save)
- Ejecuta migraciones de Prisma
- Verifica el estado del despliegue

## 4. Configuración General del Pipeline

### Prompt utilizado:
```
Crea un pipeline completo de GitHub Actions que:

1. Se dispare en push y pull requests a main/develop
2. Tenga 3 jobs principales: tests, build, deploy
3. Solo haga deploy en push (no en PRs)
4. Use nombres descriptivos con emojis
5. Tenga un job de notificación final
6. Maneje errores apropiadamente
7. Use las mejores prácticas de GitHub Actions

Incluye comentarios explicativos en español para cada paso.
```

### Resultado:
Se creó el archivo `.github/workflows/pipeline.yml` con:
- Trigger en push y pull requests a main/develop
- 4 jobs: test-backend, build-backend, deploy-backend, notify-deployment
- Nombres descriptivos con emojis para mejor visualización
- Comentarios en español explicando cada paso
- Manejo de errores y notificaciones
- Uso de las mejores prácticas de GitHub Actions

## 5. Configuración de Secrets Requeridos

Para que el pipeline funcione correctamente, se deben configurar los siguientes secrets en el repositorio:

### Secrets de AWS:
- `AWS_ACCESS_KEY_ID`: ID de la clave de acceso de AWS
- `AWS_SECRET_ACCESS_KEY`: Clave secreta de AWS

### Secrets de EC2:
- `EC2_HOST`: IP pública o DNS de la instancia EC2
- `EC2_USERNAME`: Usuario SSH (usualmente `ec2-user` o `ubuntu`)
- `EC2_SSH_KEY`: Clave privada SSH para acceder a la instancia

### Cómo configurar los secrets:
1. Ve a Settings > Secrets and variables > Actions en tu repositorio
2. Haz clic en "New repository secret"
3. Agrega cada uno de los secrets mencionados arriba

## 6. Configuración Adicional Requerida en EC2

Para que el despliegue funcione, la instancia EC2 debe tener:

1. **Node.js 18+ instalado**
2. **PM2 instalado globalmente**: `npm install -g pm2`
3. **PostgreSQL configurado** (para Prisma)
4. **Variables de entorno** configuradas (DATABASE_URL, etc.)
5. **Puerto 8080 abierto** en el security group
6. **Usuario SSH configurado** con permisos apropiados

## 7. Estructura del Pipeline

```
Push/PR → Tests → Build → Deploy (solo en push) → Notify
```

- **Tests**: Se ejecutan siempre
- **Build**: Solo si tests pasan
- **Deploy**: Solo en push a main/develop y si build es exitoso
- **Notify**: Siempre se ejecuta para reportar el estado final
