# Prompts Utilizados - Pipeline GitHub Actions

**IDE Utilizado:** Cursor

## Prompts del Usuario

1. **Conexión a EC2 y comandos incorrectos:**
   ```
   me conecté a amazon con este comando:

   ssh -i "ai4devs-pipeline.pem" ubuntu@ec2-3-17-27-243.us-east-2.compute.amazonaws.com

   estoy intentando correr esto pero no funciona:

   Instala Node.js y npm:
   curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -
   sudo yum install -y nodejs
   Instala PM2 para gestionar tu aplicación:
   sudo npm install -g pm2
   Instala Nginx si lo necesitas:
   sudo yum install -y nginx
   ```

2. **Solicitud de pipeline completo:**
   ```
   eres un experto en infraestructura de despliegue en EC2, necesito que me ayudes a completar esto:

   2️⃣ Realiza el ejercicio
   Tu misión en este ejercicio es crear un pipeline en GitHub Actions que, tras el trigger "push a una rama con un Pull Request abierto", siga los siguientes pasos:

   Pase unos tests de backend.
   Genere un build del backend.
   Despliegue el backend en un EC2. 
   Para ello, debes seguir estos pasos:

   Configurar el workflow de GitHub Actions en un archivo .github/workflows/pipeline.yml.
   Documentar los prompts utilizados para generar cada paso del pipeline:
   Tests de backend.
   Generación del build del backend.
   Despliegue del backend en EC2.
   Asegúrate de que el pipeline se dispare con un push a una rama con un Pull Request abierto.

   la rama se llama pipeline-larivasd
   ```

3. **Instrucciones específicas para adaptar pipeline:**
   ```
   ahora, ten en cuenta lo siguiente:

   Start your file by defining jobs, jobs are the steps that you can define and see individual status reports when you see the logs in your Actions tab

   jobs:
     deploy:
       name: Deploy to EC2
       runs-on: ubuntu-latest
   In the above block we have defined our job with name Deploy to EC2 and enforced it to run on latest Ubuntu by runs-on: ubuntu-latest line

   Now, we need to checkout the pushed code to the runner by using a predefined action named actions/checkout@v2. The code responsible for this step should look like the following

   steps:
     - name: Checkout the files
       uses: actions/checkout@v2
   Now, we are deploying the code to the server, in order to do this we need to access the EC2 using ssh and perform rsync from the runner. For this we are going to use another GitHub action easingthemes/ssh-deploy

   - name: Deploy to Server 1
     uses: easingthemes/ssh-deploy@main
     env:
       SSH_PRIVATE_KEY: ${ { secrets.EC2_SSH_KEY }}
       REMOTE_HOST: ${ { secrets.HOST_DNS }}
       REMOTE_USER: ${ { secrets.USERNAME }}
       TARGET: ${ { secrets.TARGET_DIR }}
   Note: You need to put the double parentheses together; I had to leave a space because my code formatter refuses to print it (:facepalm)

   You need to fill in the secrets using GitHub Secrets that you can add in your repo, read GitHub Secrets

   EC2_SSH_KEY: This will be your .pem file which you will use to login to the instance
   HOST_DNS: Public DNS record of the instance, it will look something like this ec2-xx-xxx-xxx-xxx.us-west-2.compute.amazonaws.com
   USERNAME: Will be the username of the EC2 instance, usually ubuntu
   TARGET_DIR: Is where you want to deploy your code.
   Once you add all these information your repo will look like thisGitHub Secrets

   Trigger deployment only on push to master branch
   Add the following code so that your actions only run when you push to master branch.

   on:
     push:
       branches:
         - pipeline-larivasd


   ya configuré los secrets en github

   adapta el archivo que creaste en función de esas instrucciones, y antes, prueba de manera local que los test y el build de back funcionen
   ```

4. **Solicitud de reintento:**
   ```
   reintenta por favor
   ```

5. **Solicitud de simplificación:**
   ```
   solo prioriza los cambios en el pipeline, no crees scripts, bórralos por favor
   ```
