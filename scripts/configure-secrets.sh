#!/bin/bash

# Script para ayudar a configurar los secrets de GitHub
# Este script te guía paso a paso para configurar los secrets necesarios

echo "🔐 Configuración de GitHub Secrets para EC2 Deployment"
echo "====================================================="
echo ""

echo "📋 Necesitas configurar estos 3 secrets en GitHub:"
echo "   1. EC2_HOST"
echo "   2. EC2_USER" 
echo "   3. EC2_SSH_KEY"
echo ""

echo "🔗 Ve a: https://github.com/xescuder/AI4Devs-pipeline/settings/secrets/actions"
echo ""

# EC2_HOST
echo "1️⃣ EC2_HOST:"
echo "   - Nombre del secret: EC2_HOST"
echo "   - Valor: La IP pública de tu instancia EC2"
if command -v aws &> /dev/null; then
    echo "   💡 Si tienes AWS CLI configurado, puedes obtener IPs con:"
    echo "      aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,PublicIpAddress,State.Name]' --output table"
fi
echo ""

# EC2_USER
echo "2️⃣ EC2_USER:"
echo "   - Nombre del secret: EC2_USER"
echo "   - Valor depende de tu AMI:"
echo "     • Ubuntu: ubuntu"
echo "     • Amazon Linux: ec2-user"
echo "     • CentOS: centos"
echo "     • Debian: admin"
echo ""

# EC2_SSH_KEY
echo "3️⃣ EC2_SSH_KEY:"
echo "   - Nombre del secret: EC2_SSH_KEY"
echo "   - Valor: Contenido completo de tu archivo .pem"
echo ""
echo "   Para obtener el contenido de tu clave:"
echo "   cat tu-archivo.pem"
echo ""
echo "   Copia TODO el contenido, incluyendo las líneas:"
echo "   -----BEGIN RSA PRIVATE KEY-----"
echo "   ...contenido..."
echo "   -----END RSA PRIVATE KEY-----"
echo ""

echo "⚠️  IMPORTANTE:"
echo "   - Los secrets son sensibles y no se pueden ver una vez guardados"
echo "   - Asegúrate de copiar correctamente sin espacios extra"
echo "   - La clave SSH debe tener permisos 600: chmod 600 tu-archivo.pem"
echo ""

echo "✅ Una vez configurados los secrets, el despliegue será automático"
echo "   cuando hagas push a la rama 'main'"
echo ""

echo "🔍 Para verificar la configuración:"
echo "   1. Haz push a main"
echo "   2. Ve a: https://github.com/xescuder/AI4Devs-pipeline/actions"
echo "   3. Observa la ejecución del pipeline"
echo ""

read -p "¿Has configurado todos los secrets? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✅ Perfecto! Ya puedes hacer push a main para probar el despliegue"
else
    echo "📝 Configura los secrets y vuelve a ejecutar este script"
fi
