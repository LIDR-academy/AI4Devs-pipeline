# 📋 Documentación del Pipeline LTI - GitHub Actions

## 🎯 Objetivo
Pipeline automatizado que ejecuta tests, build y despliegue del backend LTI en EC2 cuando se hace push a la rama `pipeline-solved-sp` con un Pull Request abierto.

## 🚀 Prompts Utilizados para Generar el Pipeline

### 1. 🧪 Tests de Backend

**Prompt utilizado:**
```
"Configura un job de GitHub Actions para ejecutar tests de backend con:
- Node.js 20
- PostgreSQL como servicio
- Instalación de dependencias con npm ci
- Configuración de base de datos de test
- Ejecución de tests con npm test
- Asegurar que el job falle si los tests fallan"
```

**Resultado implementado:**
- Job `test-backend` con PostgreSQL como servicio
- Configuración automática de base de datos de test
- Ejecución de tests con verificación de resultados

### 2. 🏗️ Generación del Build del Backend

**Prompt utilizado:**
```
"Crea un job que:
- Dependa del job de tests exitoso
- Instale dependencias del backend
- Compile el backend con npm run build
- Cree un artefacto comprimido con el build
- Suba el artefacto para uso posterior en despliegue"
```

**Resultado implementado:**
- Job `build-backend` que depende de `test-backend`
- Compilación del backend
- Creación de artefacto `backend-build.tar.gz`
- Subida del artefacto para descarga en el job de despliegue

### 3. 🚀 Despliegue del Backend en EC2

**Prompt utilizado:**
```
"Implementa un job de despliegue que:
- Solo se ejecute en push a la rama pipeline-solved-sp
- Descargue el artefacto de build
- Configure SSH para conectar a EC2
- Instale y configure PostgreSQL en el servidor
- Transfiera el build al servidor
- Configure variables de entorno
- Inicie la aplicación en producción
- Verifique que el despliegue sea exitoso"
```

**Resultado implementado:**
- Job `deploy-backend` con condición de ejecución
- Configuración automática de PostgreSQL en EC2
- Transferencia segura del build
- Configuración de entorno de producción
- Verificación del despliegue exitoso

## 🔧 Configuración de Secrets Necesarios

Para que el pipeline funcione, necesitas configurar estos secrets en GitHub:

```bash
# En GitHub: Settings → Secrets and variables → Actions
EC2_PRIVATE_KEY: Contenido del archivo AI4Devs-pipeline.pem
EC2_HOST: ec2-18-218-63-89.us-east-2.compute.amazonaws.com
```

## 📋 Estructura del Pipeline

```
Pipeline LTI Backend Deploy
├── 🧪 test-backend
│   ├── Checkout código
│   ├── Setup Node.js 20
│   ├── Instalar dependencias
│   ├── Configurar PostgreSQL
│   └── Ejecutar tests
├── 🏗️ build-backend (needs: test-backend)
│   ├── Checkout código
│   ├── Setup Node.js 20
│   ├── Instalar dependencias
│   ├── Compilar backend
│   ├── Crear artefacto
│   └── Subir artefacto
├── 🚀 deploy-backend (needs: build-backend)
│   ├── Checkout código
│   ├── Descargar artefacto
│   ├── Configurar SSH
│   ├── Configurar PostgreSQL en EC2
│   ├── Desplegar backend
│   └── Verificar despliegue
└── 📢 notify (needs: all)
    └── Notificación de resultado
```

## 🎯 Triggers del Pipeline

- **Push** a la rama `pipeline-solved-sp`
- **Pull Request** abierto o sincronizado hacia `main`

## ✅ Verificaciones del Pipeline

1. **Tests:** Todos los tests de backend deben pasar
2. **Build:** Compilación exitosa del backend
3. **Deploy:** Aplicación ejecutándose en puerto 3010
4. **Health Check:** Verificación de que el backend responda

## 🔍 Logs y Debugging

- Logs disponibles en GitHub Actions
- Logs del backend en EC2: `/home/ec2-user/lti-backend/backend.log`
- Verificación manual: `curl http://ec2-18-218-63-89.us-east-2.compute.amazonaws.com:3010/`

## 🚨 Troubleshooting

### Error de conexión SSH
- Verificar que los secrets estén configurados correctamente
- Verificar que la instancia EC2 esté ejecutándose
- Verificar Security Groups (puerto 22 abierto)

### Error de PostgreSQL
- Verificar que PostgreSQL esté instalado y ejecutándose
- Verificar configuración de usuarios y permisos
- Verificar conectividad de red

### Error de despliegue
- Verificar logs en `/home/ec2-user/lti-backend/backend.log`
- Verificar que el puerto 3010 esté disponible
- Verificar que las dependencias estén instaladas
