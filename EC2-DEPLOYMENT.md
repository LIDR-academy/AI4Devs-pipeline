# Configuración de Despliegue en EC2

## 🚀 Configuración de la Instancia EC2

### 1. Crear y configurar la instancia EC2
```bash
# Conectarse a la instancia EC2
ssh -i tu-clave.pem ubuntu@tu-ip-ec2

# Actualizar el sistema
sudo apt update && sudo apt upgrade -y

# Instalar Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verificar instalación
node --version
npm --version

# Instalar PM2 globalmente
sudo npm install -g pm2

# Instalar Git si no está instalado
sudo apt install git -y
```

### 2. Clonar el repositorio
```bash
# Clonar el repositorio en el directorio home
cd /home/ubuntu
git clone https://github.com/xescuder/AI4Devs-pipeline.git
cd AI4Devs-pipeline/backend

# Instalar dependencias
npm install

# Generar Prisma Client (si usas base de datos)
npx prisma generate

# Crear archivo de configuración de PM2
cat > ecosystem.config.js << EOF
module.exports = {
  apps: [{
    name: 'backend',
    script: 'dist/index.js',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    }
  }]
}
EOF
```

### 3. Configurar el Security Group
En AWS Console > EC2 > Security Groups:
- **Puerto 22** (SSH): Tu IP o 0.0.0.0/0
- **Puerto 3000** (API): 0.0.0.0/0 o tu rango de IPs
- **Puerto 80/443** (HTTP/HTTPS): 0.0.0.0/0 si usas reverse proxy

## 🔐 Configuración de GitHub Secrets

Ve a tu repositorio en GitHub > Settings > Secrets and variables > Actions

### Secrets necesarios:

1. **EC2_HOST**
   ```
   Valor: IP pública de tu instancia EC2
   Ejemplo: 3.15.123.456
   ```

2. **EC2_USER**
   ```
   Valor: usuario SSH de tu instancia
   Para Ubuntu: ubuntu
   Para Amazon Linux: ec2-user
   ```

3. **EC2_SSH_KEY**
   ```
   Valor: Contenido completo de tu archivo .pem
   ```
   Para obtener el contenido:
   ```bash
   cat tu-clave.pem
   ```
   Copia todo el contenido incluyendo:
   ```
   -----BEGIN RSA PRIVATE KEY-----
   ...contenido de la clave...
   -----END RSA PRIVATE KEY-----
   ```

## 🔄 Flujo de Despliegue

### Automático (mediante pipeline):
1. Push a la rama `main`
2. GitHub Actions ejecuta tests
3. Si los tests pasan, se conecta a EC2
4. Hace pull del código actualizado
5. Instala dependencias y builda
6. Reinicia la aplicación con PM2

### Manual (para primera configuración):
```bash
# En la instancia EC2
cd /home/ubuntu/AI4Devs-pipeline/backend
npm run build
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

## 🔧 Comandos útiles de PM2

```bash
# Ver estado de las aplicaciones
pm2 status

# Ver logs
pm2 logs backend

# Reiniciar aplicación
pm2 restart backend

# Parar aplicación
pm2 stop backend

# Eliminar aplicación
pm2 delete backend

# Monitorear en tiempo real
pm2 monit
```

## 🌐 Configuración opcional de Nginx (Reverse Proxy)

```bash
# Instalar Nginx
sudo apt install nginx -y

# Configurar Nginx
sudo tee /etc/nginx/sites-available/backend << EOF
server {
    listen 80;
    server_name tu-dominio.com;  # o la IP de tu EC2

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Habilitar el sitio
sudo ln -s /etc/nginx/sites-available/backend /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## 🔍 Verificación del Despliegue

1. **Verificar que el servicio está ejecutándose:**
   ```bash
   pm2 status
   curl http://localhost:3000/health  # si tienes endpoint de health
   ```

2. **Verificar desde el exterior:**
   ```bash
   curl http://TU-IP-EC2:3000
   ```

3. **Verificar logs si hay problemas:**
   ```bash
   pm2 logs backend
   ```

## 🚨 Troubleshooting

### Problema: "Host key verification failed"
```bash
# En la instancia EC2, añadir github.com a known_hosts
ssh-keyscan github.com >> ~/.ssh/known_hosts
```

### Problema: Permisos de la clave SSH
```bash
# En tu máquina local
chmod 600 tu-clave.pem
```

### Problema: Puerto ya en uso
```bash
# Verificar qué proceso usa el puerto 3000
sudo lsof -i :3000
# Matar el proceso si es necesario
sudo kill -9 PID
```
