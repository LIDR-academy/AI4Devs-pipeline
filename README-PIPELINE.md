# 🚀 Pipeline CI/CD - Guía de Configuración

Este documento describe el pipeline de CI/CD implementado para el proyecto Node.js/TypeScript con despliegue automático en Amazon EC2.

## 📋 Descripción General

El pipeline se ejecuta automáticamente cuando se abre, actualiza o reabre un Pull Request que modifica archivos en el directorio `backend/` o en `.github/workflows/`.

### 🔄 Flujo del Pipeline

1. **🧪 Tests Backend** - Ejecuta la suite completa de tests con Jest
2. **🏗️ Build Backend** - Compila el código TypeScript y genera artefactos
3. **🚀 Despliegue EC2** - Despliega la aplicación en Amazon EC2 usando PM2
4. **🔙 Rollback** - Se ejecuta automáticamente si el despliegue falla

## ⚙️ Configuración Requerida

### 1. Secrets de GitHub

Configura los siguientes secrets en tu repositorio de GitHub (`Settings > Secrets and variables > Actions`):

| Secret | Descripción | Ejemplo |
|--------|-------------|---------|
| `EC2_HOST` | IP pública o DNS de la instancia EC2 | `ec2-xx-xx-xx-xx.compute-1.amazonaws.com` |
| `EC2_USERNAME` | Usuario SSH para EC2 | `ec2-user` (Amazon Linux) o `ubuntu` (Ubuntu) |
| `EC2_PRIVATE_KEY` | Clave privada SSH (contenido completo) | `-----BEGIN RSA PRIVATE KEY-----...` |
| `DATABASE_URL` | URL de conexión a PostgreSQL | `postgresql://user:pass@host:5432/db` |

### 2. Configuración de EC2

#### Preparación de la Instancia

```bash
# 1. Conectarse a EC2
ssh -i your-key.pem ec2-user@your-ec2-host

# 2. Instalar Node.js 18.x
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# 3. Instalar PM2 globalmente
sudo npm install -g pm2

# 4. Crear estructura de directorios
mkdir -p /home/ec2-user/app/logs
mkdir -p /home/ec2-user/app/backend

# 5. Configurar PM2 para auto-inicio
pm2 startup
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ec2-user --hp /home/ec2-user
```

#### Configuración de Seguridad

```bash
# Configurar firewall para puerto 8080
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload

# O en Ubuntu:
sudo ufw allow 8080
```

### 3. Configuración de Base de Datos

Asegúrate de que tu instancia PostgreSQL esté configurada y accesible desde EC2:

```bash
# Ejemplo de configuración de DATABASE_URL
DATABASE_URL="postgresql://username:password@your-db-host:5432/your-database"
```

## 📁 Estructura de Archivos

El pipeline crea y utiliza la siguiente estructura en EC2:

```
/home/ec2-user/app/
├── backend/
│   ├── dist/                 # Código compilado
│   ├── node_modules/         # Dependencias de producción
│   ├── prisma/              # Esquemas y migraciones
│   ├── package.json
│   ├── package-lock.json
│   └── .env                 # Variables de entorno
├── ecosystem.config.js      # Configuración PM2
├── logs/                    # Logs de la aplicación
├── backup-YYYYMMDD-HHMMSS/ # Backups automáticos
└── deploy.log              # Log del proceso de despliegue
```

## 🔧 Archivos de Configuración

### ecosystem.config.js

Configuración de PM2 para gestión de procesos:

- **Nombre de la aplicación**: `backend-app`
- **Puerto**: 8080
- **Modo**: Fork (single instance)
- **Auto-restart**: Habilitado
- **Logs**: Centralizados en `/logs/`
- **Memory limit**: 1GB

### scripts/deploy.sh

Script auxiliar para despliegues manuales con las siguientes funciones:

```bash
# Despliegue completo
./scripts/deploy.sh deploy

# Rollback al despliegue anterior
./scripts/deploy.sh rollback

# Verificar estado de la aplicación
./scripts/deploy.sh health

# Crear backup manual
./scripts/deploy.sh backup

# Limpiar backups antiguos
./scripts/deploy.sh cleanup
```

## 🚦 Triggers del Pipeline

El pipeline se ejecuta en los siguientes casos:

- **Pull Request abierto** con cambios en `backend/`
- **Push a PR existente** con cambios en `backend/`
- **Pull Request reabierto** con cambios en `backend/`
- **Cambios en workflows** (`.github/workflows/`)

## 📊 Monitoreo y Logs

### Logs de PM2

```bash
# Ver logs en tiempo real
pm2 logs backend-app

# Ver logs específicos
pm2 logs backend-app --lines 100

# Ver estado de la aplicación
pm2 status
```

### Health Check

El pipeline incluye verificaciones automáticas:

- Estado del proceso en PM2
- Respuesta HTTP en puerto 8080
- Múltiples intentos con timeout
- Logs detallados en caso de fallo

## 🔒 Seguridad

### Mejores Prácticas Implementadas

1. **Secrets Management**: Todas las credenciales en GitHub Secrets
2. **SSH Key Security**: Configuración segura de claves SSH
3. **Environment Isolation**: Variables de entorno separadas por ambiente
4. **Process Management**: PM2 con límites de memoria y reinicio automático
5. **Backup Strategy**: Backups automáticos antes de cada despliegue

### Recomendaciones Adicionales

- Rotar claves SSH regularmente
- Usar IAM roles en lugar de claves SSH cuando sea posible
- Implementar monitoreo de logs con CloudWatch
- Configurar alertas para fallos de despliegue

## 🔄 Rollback Automático

En caso de fallo durante el despliegue:

1. Se ejecuta automáticamente el job de rollback
2. Se restaura el backup más reciente
3. Se reinicia la aplicación con PM2
4. Se verifica que el servicio esté funcionando

## 📈 Optimizaciones

### Cache de Dependencias

- Cache de `node_modules` basado en `package-lock.json`
- Instalación offline cuando es posible
- Uso de `npm ci` para instalaciones reproducibles

### Paralelización

- Tests y build se ejecutan en paralelo después de tests
- Artefactos se transfieren de forma eficiente
- Múltiples verificaciones simultáneas

### Timeouts

- **Tests**: 10 minutos
- **Build**: 10 minutos  
- **Deploy**: 15 minutos
- **Rollback**: 5 minutos

## 🐛 Troubleshooting

### Problemas Comunes

1. **Error de conexión SSH**
   - Verificar que la clave privada esté correctamente configurada
   - Comprobar que el security group permita SSH (puerto 22)

2. **Aplicación no responde**
   - Verificar logs con `pm2 logs backend-app`
   - Comprobar que el puerto 8080 esté disponible
   - Verificar variables de entorno

3. **Fallo en tests**
   - Revisar logs del job de tests en GitHub Actions
   - Ejecutar tests localmente para debugging

4. **Error de build**
   - Verificar configuración de TypeScript
   - Comprobar que todas las dependencias estén instaladas

### Comandos Útiles

```bash
# En EC2 - Verificar estado
pm2 status
pm2 logs backend-app --lines 50

# En EC2 - Reiniciar manualmente
pm2 restart backend-app

# En EC2 - Ver procesos
ps aux | grep node

# En EC2 - Verificar puerto
netstat -tlnp | grep 8080
```

## 📞 Soporte

Para problemas con el pipeline:

1. Revisar logs de GitHub Actions
2. Verificar configuración de secrets
3. Comprobar estado de la instancia EC2
4. Ejecutar health check manual: `./scripts/deploy.sh health`

---

**Nota**: Este pipeline está optimizado para proyectos Node.js/TypeScript con Prisma ORM. Ajusta las configuraciones según las necesidades específicas de tu proyecto.
