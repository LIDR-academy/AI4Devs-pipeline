#!/bin/bash

# Script de configuración automática para EC2
# Ejecutar como: chmod +x setup-ec2.sh && ./setup-ec2.sh

set -e

echo "🚀 Configurando instancia EC2 para AI4Devs Backend..."

# Actualizar sistema
echo "📦 Actualizando sistema..."
sudo apt update && sudo apt upgrade -y

# Instalar Node.js 18
echo "📦 Instalando Node.js 18..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Instalar PM2
echo "📦 Instalando PM2..."
sudo npm install -g pm2

# Instalar Git si no está
echo "📦 Instalando Git..."
sudo apt install git -y

# Verificar instalaciones
echo "✅ Verificando instalaciones..."
echo "Node.js version: $(node --version)"
echo "NPM version: $(npm --version)"
echo "PM2 version: $(pm2 --version)"

# Clonar repositorio si no existe
if [ ! -d "/home/ubuntu/AI4Devs-pipeline" ]; then
    echo "📥 Clonando repositorio..."
    cd /home/ubuntu
    git clone https://github.com/xescuder/AI4Devs-pipeline.git
else
    echo "📥 Actualizando repositorio..."
    cd /home/ubuntu/AI4Devs-pipeline
    git pull origin main
fi

# Configurar backend
echo "⚙️ Configurando backend..."
cd /home/ubuntu/AI4Devs-pipeline/backend

# Instalar dependencias
npm install

# Crear archivo de configuración PM2
cat > ecosystem.config.js << 'EOF'
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

# Build del proyecto
echo "🔨 Compilando TypeScript..."
npm run build

# Configurar PM2 para que inicie automáticamente
echo "⚙️ Configurando PM2 para inicio automático..."
pm2 startup | grep "sudo" | bash || true

# Añadir GitHub a known_hosts para evitar problemas de SSH
echo "🔐 Configurando GitHub en known_hosts..."
ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null || true

echo "✅ Configuración completada!"
echo ""
echo "🚀 Para iniciar la aplicación:"
echo "   cd /home/ubuntu/AI4Devs-pipeline/backend"
echo "   pm2 start ecosystem.config.js"
echo "   pm2 save"
echo ""
echo "📊 Para monitorear:"
echo "   pm2 status"
echo "   pm2 logs backend"
echo "   pm2 monit"
echo ""
echo "🌐 La aplicación estará disponible en: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):3000"
