#!/bin/bash

# Script de despliegue para la aplicación en EC2
# Este script debe ejecutarse en la instancia EC2

# Variables (deben configurarse como variables de entorno en la instancia)
APP_DIR="/home/ec2-user/app"
SERVICE_NAME="backend-app"

# Crear directorio de aplicación si no existe
mkdir -p $APP_DIR

# Extraer el archivo de despliegue
tar -xzf /tmp/deployment.tar.gz -C $APP_DIR

# Navegar al directorio de la aplicación
cd $APP_DIR/deployment

# Configurar variables de entorno si no están presentes
if [ ! -f .env ]; then
  echo "DATABASE_URL=$DATABASE_URL" > .env
  echo "PORT=$PORT" >> .env
fi

# Configurar el servicio systemd si no existe
if [ ! -f /etc/systemd/system/$SERVICE_NAME.service ]; then
  echo "[Unit]
Description=Node.js Backend Application
After=network.target

[Service]
Type=simple
User=$(whoami)
WorkingDirectory=$APP_DIR/deployment
ExecStart=$(which node) dist/index.js
Restart=on-failure
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/$SERVICE_NAME.service
  
  sudo systemctl daemon-reload
  sudo systemctl enable $SERVICE_NAME.service
fi

# Reiniciar la aplicación
sudo systemctl restart $SERVICE_NAME.service

# Mostrar estado del servicio
sudo systemctl status $SERVICE_NAME.service

echo "Despliegue completado."
