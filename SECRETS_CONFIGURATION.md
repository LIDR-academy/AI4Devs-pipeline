# 🔐 Configuración de Secrets para GitHub Actions

## Secrets Requeridos

Para que el pipeline funcione correctamente, necesitas configurar los siguientes secrets en tu repositorio de GitHub:

### 1. EC2_PRIVATE_KEY
- **Descripción**: Contenido completo del archivo `AI4Devs-pipeline.pem`
- **Cómo obtenerlo**: 
  ```bash
  cat AI4Devs-pipeline.pem
  ```
- **Valor**: Copia TODO el contenido del archivo .pem (incluyendo las líneas `-----BEGIN RSA PRIVATE KEY-----` y `-----END RSA PRIVATE KEY-----`)

### 2. EC2_HOST
- **Descripción**: DNS público de la instancia EC2
- **Valor**: `ec2-18-218-63-89.us-east-2.compute.amazonaws.com`

### 3. EC2_USERNAME
- **Descripción**: Usuario para conectarse a la instancia EC2
- **Valor**: `ec2-user`

## Cómo Configurar los Secrets

1. Ve a tu repositorio en GitHub
2. Click en **Settings** (en el menú superior)
3. En el menú lateral izquierdo, click en **Secrets and variables** → **Actions**
4. Click en **New repository secret**
5. Para cada secret:
   - **Name**: Usa el nombre exacto (ej: `EC2_PRIVATE_KEY`)
   - **Secret**: Pega el valor correspondiente
   - Click **Add secret**

## Verificación

Una vez configurados los secrets, el pipeline debería funcionar automáticamente cuando hagas push a la rama `pipeline-solved-sp`.

## Troubleshooting

Si el pipeline falla:
1. Verifica que todos los secrets estén configurados correctamente
2. Verifica que la instancia EC2 esté en estado "Running"
3. Verifica que las Security Groups permitan SSH (puerto 22)
4. Revisa los logs del pipeline en la pestaña "Actions" de GitHub
