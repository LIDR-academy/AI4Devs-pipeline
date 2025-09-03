# 🔐 Configuración de Secrets para GitHub Actions

Esta guía te ayudará a configurar todos los secrets necesarios para que el pipeline de CI/CD funcione correctamente.

## 📋 Lista de Secrets Requeridos

| Secret Name | Descripción | Ejemplo |
|-------------|-------------|---------|
| `EC2_HOST` | IP pública o DNS de tu instancia EC2 | `ec2-3-15-123-45.us-east-2.compute.amazonaws.com` |
| `EC2_USERNAME` | Usuario SSH para conectarse a EC2 | `ec2-user` o `ubuntu` |
| `EC2_PRIVATE_KEY` | Clave privada SSH completa | `-----BEGIN RSA PRIVATE KEY-----\n...` |
| `DATABASE_URL` | URL de conexión a PostgreSQL | `postgresql://user:pass@host:5432/dbname` |

## 🔧 Cómo Configurar los Secrets

### 1. Acceder a la Configuración de Secrets

1. Ve a tu repositorio en GitHub
2. Haz clic en **Settings** (Configuración)
3. En el menú lateral, selecciona **Secrets and variables** > **Actions**
4. Haz clic en **New repository secret**

### 2. Configurar EC2_HOST

```
Name: EC2_HOST
Value: tu-instancia-ec2.amazonaws.com
```

**Cómo obtener el valor:**
- Ve a la consola de AWS EC2
- Selecciona tu instancia
- Copia el "Public IPv4 DNS" o "Public IPv4 address"

### 3. Configurar EC2_USERNAME

```
Name: EC2_USERNAME
Value: ec2-user
```

**Valores comunes:**
- Amazon Linux 2: `ec2-user`
- Ubuntu: `ubuntu`
- CentOS: `centos`
- Red Hat: `ec2-user`

### 4. Configurar EC2_PRIVATE_KEY

```
Name: EC2_PRIVATE_KEY
Value: -----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA...
[contenido completo de la clave privada]
...
-----END RSA PRIVATE KEY-----
```

**Cómo obtener el valor:**

#### Opción A: Si ya tienes el archivo .pem
```bash
# Mostrar el contenido de tu clave privada
cat ~/.ssh/tu-clave.pem
```

#### Opción B: Crear nueva clave SSH
```bash
# 1. Generar nueva clave SSH
ssh-keygen -t rsa -b 4096 -f ~/.ssh/ec2-deploy-key

# 2. Mostrar la clave privada (para el secret)
cat ~/.ssh/ec2-deploy-key

# 3. Mostrar la clave pública (para agregar a EC2)
cat ~/.ssh/ec2-deploy-key.pub
```

**Agregar clave pública a EC2:**
```bash
# Conectarse a EC2 con tu clave actual
ssh -i tu-clave-actual.pem ec2-user@tu-ec2-host

# Agregar la nueva clave pública
echo "tu-clave-publica-aqui" >> ~/.ssh/authorized_keys
```

### 5. Configurar DATABASE_URL

```
Name: DATABASE_URL
Value: postgresql://username:password@host:port/database
```

**Formato de la URL:**
```
postgresql://[usuario]:[contraseña]@[host]:[puerto]/[nombre_base_datos]
```

**Ejemplos:**
```bash
# Base de datos local
postgresql://myuser:mypassword@localhost:5432/myapp

# RDS de AWS
postgresql://admin:secretpass@mydb.cluster-xyz.us-east-1.rds.amazonaws.com:5432/production

# Base de datos con SSL
postgresql://user:pass@host:5432/db?sslmode=require
```

## 🔍 Verificación de Secrets

### Script de Verificación

Crea este script para verificar que los secrets funcionen:

```bash
#!/bin/bash
# verify-secrets.sh

echo "🔍 Verificando conexión SSH..."
ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no $EC2_USERNAME@$EC2_HOST "echo 'SSH OK'"

echo "🔍 Verificando base de datos..."
# Instalar psql si no está disponible
# psql $DATABASE_URL -c "SELECT 1;"

echo "✅ Verificación completada"
```

### Comandos de Prueba Manual

```bash
# Probar conexión SSH
ssh -i tu-clave.pem ec2-user@tu-ec2-host "uptime"

# Probar conexión a base de datos
psql "postgresql://user:pass@host:5432/db" -c "SELECT version();"
```

## 🚨 Troubleshooting

### Error: "Permission denied (publickey)"

**Causa:** Clave SSH incorrecta o no autorizada

**Solución:**
1. Verificar que la clave privada sea correcta
2. Asegurar que la clave pública esté en `~/.ssh/authorized_keys` en EC2
3. Verificar permisos:
   ```bash
   chmod 600 ~/.ssh/authorized_keys
   chmod 700 ~/.ssh
   ```

### Error: "Host key verification failed"

**Causa:** Host no está en known_hosts

**Solución:**
```bash
# Agregar host a known_hosts
ssh-keyscan -H tu-ec2-host >> ~/.ssh/known_hosts
```

### Error: "Connection refused"

**Causa:** Security Group o firewall bloqueando SSH

**Solución:**
1. Verificar Security Group permite puerto 22 desde tu IP
2. Verificar que la instancia esté ejecutándose
3. Verificar que el servicio SSH esté activo:
   ```bash
   sudo systemctl status sshd
   ```

### Error de Base de Datos

**Causa:** URL de conexión incorrecta o base de datos inaccesible

**Solución:**
1. Verificar formato de DATABASE_URL
2. Comprobar que la base de datos esté ejecutándose
3. Verificar permisos de usuario
4. Verificar configuración de red (Security Groups, VPC)

## 🔒 Mejores Prácticas de Seguridad

### 1. Rotación de Claves
```bash
# Rotar claves SSH cada 90 días
# 1. Generar nueva clave
ssh-keygen -t rsa -b 4096 -f ~/.ssh/ec2-new-key

# 2. Agregar nueva clave a EC2
# 3. Actualizar secret en GitHub
# 4. Eliminar clave antigua después de verificar
```

### 2. Principio de Menor Privilegio
- Usar usuario específico para despliegues (no root)
- Configurar permisos mínimos necesarios
- Usar IAM roles cuando sea posible

### 3. Monitoreo
- Habilitar CloudTrail para auditoría
- Monitorear intentos de conexión SSH
- Configurar alertas para fallos de autenticación

### 4. Backup de Secrets
- Mantener backup seguro de claves SSH
- Documentar configuración de secrets
- Tener plan de recuperación

## 📝 Checklist de Configuración

- [ ] EC2_HOST configurado y verificado
- [ ] EC2_USERNAME correcto para tu AMI
- [ ] EC2_PRIVATE_KEY copiada completamente (incluyendo headers)
- [ ] Clave pública agregada a EC2 authorized_keys
- [ ] DATABASE_URL con formato correcto
- [ ] Conexión SSH probada manualmente
- [ ] Conexión a base de datos probada
- [ ] Security Groups configurados (SSH puerto 22, App puerto 8080)
- [ ] Instancia EC2 ejecutándose
- [ ] Node.js y PM2 instalados en EC2

## 🆘 Soporte

Si tienes problemas con la configuración:

1. **Verifica los logs** del pipeline en GitHub Actions
2. **Prueba manualmente** cada conexión
3. **Revisa la documentación** de AWS para tu tipo de instancia
4. **Consulta los logs** de sistema en EC2: `/var/log/secure` (SSH logs)

---

**⚠️ Importante:** Nunca compartas tus claves privadas o secrets en código, issues, o documentación pública.
