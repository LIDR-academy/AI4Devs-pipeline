
# Prompt 1

@workspace Crea una pipeline de Github Actions que después del trigger "push a una rama con una pull request abierta" ejecute los tests de backend


# Prompt 2

Realiza un ejemplo para asegurar que se lanza la pr y el pipeline

```sh
git checkout -b test-pipeline && git commit --allow-empty -m "Test pipeline trigger" && git push origin test-pipeline
```


# Prompt 3

Añade ahora la generación del build del backend

< ¿Quieres que abramos la página para crear la PR ahora?

> Sí


# Prompt 4

Ahora necesito desplegar el backend en EC2

< Para completar la configuración necesitas:
Configurar los secrets en GitHub:

Ve a Settings > Secrets and variables > Actions
Añade estos secrets:
EC2_HOST: IP de tu instancia EC2
EC2_USER: usuario SSH (ej: ubuntu, ec2-user)
EC2_SSH_KEY: clave privada SSH (contenido completo del archivo .pem)
Preparar tu instancia EC2:

Instalar Node.js 18
Instalar PM2: npm install -g pm2
Clonar el repositorio en /home/usuario/AI4Devs-pipeline
¿Quieres que te ayude a configurar alguno de estos pasos o necesitas documentación específica para la configuración de EC2?

> Sí

