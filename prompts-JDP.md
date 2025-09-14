# Prompts para Pipeline CI/CD - GitHub Actions

## Información del Proyecto
- **Proyecto**: AI4Devs-pipeline
- **Repositorio**: Joshoperez/AI4Devs-pipeline
- **Tecnologías**: TypeScript/Node.js (Backend), React (Frontend)
- **Fecha**: Septiembre 14, 2025

## Objetivo del Pipeline
Crear un pipeline de GitHub Actions que se dispare con push a una rama con Pull Request abierto y ejecute:
1. Tests de backend
2. Build del backend
3. Despliegue del backend en EC2

---

## 1. Prompt para Configuración del Workflow Base

### Contexto
Necesito crear un archivo `.github/workflows/pipeline.yml` que se dispare cuando se hace push a una rama que tiene un Pull Request abierto.

### Prompt Utilizado
```
Crea un workflow de GitHub Actions que:
- Se nombre "Backend CI/CD Pipeline"
- Se dispare en push a cualquier rama excepto main
- Se dispare también cuando se abre o sincroniza un Pull Request
- Use Ubuntu latest como runner
- Incluya permisos para leer contenido del repositorio
- Tenga una estructura base con jobs separados para test, build y deploy
```

### Salida Esperada
- Archivo `.github/workflows/pipeline.yml` con triggers correctos
- Estructura base con jobs definidos
- Configuración de permisos apropiados

---

## 2. Prompt para Tests de Backend

### Contexto
El backend usa TypeScript, Jest para testing, y tiene los siguientes scripts en package.json:
- `test`: jest
- Scripts de test existentes en: candidateService.test.ts, candidateController.test.ts, positionService.test.ts, positionController.test.ts

### Prompt Utilizado
```
Configura un job de testing para GitHub Actions que:
- Use Node.js versión 18
- Haga checkout del código
- Configure la cache de npm para optimizar builds
- Navegue al directorio backend
- Instale dependencias con npm ci
- Ejecute los tests con npm test
- Falle el pipeline si algún test falla
- Genere reportes de cobertura si están configurados
```

### Salida Esperada
- Job `test` que ejecute todos los tests del backend
- Configuración de Node.js y cache
- Manejo de errores apropiado

---

## 3. Prompt para Build del Backend

### Contexto
El backend usa TypeScript y se compila con `tsc`. El script de build está configurado como:
- `build`: tsc
- Output directory: `./dist`
- Main file: `dist/index.js`

### Prompt Utilizado
```
Configura un job de build para GitHub Actions que:
- Dependa del job de tests (no ejecute si tests fallan)
- Use Node.js versión 18
- Haga checkout del código
- Configure cache de npm
- Navegue al directorio backend
- Instale dependencias con npm ci
- Ejecute el build con npm run build
- Suba los artefactos del build (carpeta dist) para uso posterior
- Verifique que el build se completó correctamente
```

### Salida Esperada
- Job `build` que compile TypeScript a JavaScript
- Dependencia correcta del job de tests
- Artefactos subidos para despliegue

---

## 4. Prompt para Despliegue en EC2

### Contexto
Se necesita desplegar el backend compilado en una instancia EC2 usando SSH. Se requieren secretos de GitHub para:
- SSH_PRIVATE_KEY: Clave privada para conectar a EC2
- EC2_HOST: IP o hostname del servidor EC2
- EC2_USER: Usuario para SSH (típicamente ec2-user o ubuntu)

### Prompt Utilizado
```
Configura un job de deploy para GitHub Actions que:
- Dependa del job de build exitoso
- Use Ubuntu latest
- Descargue los artefactos del build
- Configure SSH con la clave privada desde GitHub Secrets
- Se conecte al servidor EC2 usando SSH
- Copie los archivos del build al servidor
- Instale/actualice dependencias en el servidor
- Reinicie el servicio de la aplicación
- Verifique que el despliegue fue exitoso
- Use los siguientes secretos: SSH_PRIVATE_KEY, EC2_HOST, EC2_USER
- Maneje errores de conexión y despliegue apropiadamente
```

### Salida Esperada
- Job `deploy` que despliegue a EC2
- Configuración segura de SSH
- Copia de archivos y reinicio de servicios
- Verificación de despliegue exitoso

---

## 5. Prompt para Optimizaciones y Mejores Prácticas

### Contexto
Aplicar mejores prácticas de CI/CD para mejorar seguridad, performance y mantenibilidad.

### Prompt Utilizado
```
Optimiza el pipeline de GitHub Actions aplicando mejores prácticas:
- Usa versiones específicas de actions en lugar de @latest
- Implementa timeouts apropiados para cada job
- Agrega steps de validación de seguridad
- Configura notificaciones de estado
- Implementa rollback automático en caso de fallo de deploy
- Agrega logs detallados para debugging
- Optimiza el uso de cache para reducir tiempos de build
- Implementa variables de entorno apropiadas
```

### Salida Esperada
- Pipeline optimizado con mejores prácticas
- Configuración de seguridad mejorada
- Tiempos de ejecución optimizados

---

## Secretos de GitHub Requeridos

Para el funcionamiento del pipeline, configurar los siguientes secretos en el repositorio:

1. **SSH_PRIVATE_KEY**: Clave privada SSH para conectar a EC2
2. **EC2_HOST**: IP pública o hostname del servidor EC2
3. **EC2_USER**: Usuario SSH (ej: ec2-user, ubuntu)
4. **EC2_APP_PATH**: Ruta en el servidor donde está la aplicación (ej: /home/ec2-user/app)

## Variables de Entorno

- **NODE_VERSION**: 18 (versión de Node.js a usar)
- **BACKEND_DIR**: backend (directorio del backend)
- **BUILD_DIR**: dist (directorio de salida del build)

---

## Notas Adicionales

### Consideraciones de Seguridad
- Usar GitHub Secrets para información sensible
- No exponer credenciales en logs
- Validar inputs y sanitizar comandos
- Usar permisos mínimos necesarios

### Monitoreo y Debugging
- Logs detallados en cada step
- Notificaciones de Slack/email en caso de fallo
- Métricas de tiempo de ejecución
- Rollback automático si es posible

### Mantenimiento
- Actualizar regularmente las versions de actions
- Revisar y optimizar el pipeline periódicamente
- Documentar cambios importantes
- Probar cambios en branches de desarrollo