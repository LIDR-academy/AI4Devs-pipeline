#!/bin/bash

# Script de deployment para EC2
set -e

echo "🔄 Iniciando deployment..."

# Detener aplicación anterior
echo "🛑 Deteniendo aplicación anterior..."
pkill -f 'node.*index.js' || echo "No hay procesos anteriores"

# Esperar
echo "⏳ Esperando..."
sleep 3

# Verificar directorio
echo "📁 Verificando directorio..."
cd /home/ec2-user/app
ls -la

# Instalar dependencias si es necesario
if [ ! -d "node_modules" ]; then
    echo "📦 Instalando dependencias..."
    npm ci --only=production
fi

# Iniciar aplicación
echo "🚀 Iniciando aplicación..."
nohup npm start > app.log 2>&1 &

# Esperar y verificar
sleep 5
if pgrep -f 'node.*index.js' > /dev/null; then
    echo "✅ Aplicación iniciada correctamente"
    echo "PID: $(pgrep -f 'node.*index.js')"
else
    echo "❌ Error: Aplicación no se inició"
    cat app.log
    exit 1
fi

echo "🎉 Deployment completado!"