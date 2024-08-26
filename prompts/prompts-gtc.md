**Prompt 1**

```plaintext
Eres un experto devops y tienes más de 5 años de experiencia en configuraciones de pipelines en GitHub Actions para despliegues en la nube de AWS. Vamos a trabajar en la creación de un pipeline en GitHub Actions que nos permitirá pasar unos tests de backend, generar un build y desplegar el backend en un EC2. El pipeline se disparará con un push a una rama con un Pull Request abierto.  La descripción del repositorio la encuentras en el archivo README.md que te acabo de cargar. Si lo estimas necesario, por favor primero hazme todas las preguntas que estimes necesarias para adelantar esta tarea de manera correcta.
```

**Chat-GPT4o:**

```plaintext
Voy a revisar el contenido del archivo README.md para entender mejor el contexto del repositorio y así poder diseñar un pipeline en GitHub Actions que cumpla con tus requerimientos. Un momento mientras lo hago.

El repositorio es un proyecto full-stack llamado "LTI - Sistema de Seguimiento de Talento", que tiene un frontend en React y un backend en Express usando TypeScript y Prisma como ORM. El backend tiene una estructura bien organizada con directorios para la lógica de aplicación, dominio, infraestructura, presentación, rutas y pruebas.

Antes de proceder a la creación del pipeline, tengo algunas preguntas para asegurarme de que el pipeline cumpla con tus expectativas:

Tests: ¿Qué tipo de tests se ejecutan en el backend? ¿Son pruebas unitarias, de integración, o ambas? ¿Hay algún comando específico que se deba ejecutar para correr los tests?

Build: ¿El backend requiere algún proceso de build adicional aparte de la compilación de TypeScript? ¿Se necesita empaquetar el código o generar algún artefacto específico?

Deployment: ¿Tienes configurado un script de despliegue o comandos específicos para realizar el despliegue en el EC2? ¿El despliegue se realiza mediante SSH, y si es así, qué tipo de autenticación prefieres (por ejemplo, clave SSH, agente de SSH)?

Configuraciones de AWS: ¿Ya tienes configurado un rol de IAM con los permisos necesarios para realizar el despliegue? ¿Se utiliza algún servicio adicional de AWS como S3, RDS, o algún otro que debamos tener en cuenta en el pipeline?

Con esta información, podré ajustar el pipeline para que se adapte perfectamente a tus necesidades. ​

```
**Prompt 2**

```plaintext
1. Son pruebas unitarias. No hay un comando específico para ejecutar las pruebas
2. No se requiere proceso de build adicional. No es necesario empaquetar el código
3. No tengo configurado un script de despliegue o comandos específicos para realizar el despliegue en el EC2. El despliegue se realiza mediante SSH con clave SSH.
4. No tengo configurado un rol de IAM con los permisos necesarios para realizar el despliegue. No se utiliza ningún servicio adicional de AWS como S3.

Por favor entrégame primero el paso del pipeline correspondiente al test de backend
```
**Chat-GPT4o:**
```plaintext
Entendido. Dado que no hay un comando específico para ejecutar las pruebas y que son pruebas unitarias, podemos asumir que el pipeline debería ejecutar las pruebas utilizando un comando como npm test o yarn test, dependiendo de la configuración del proyecto. A continuación, te presento el paso del pipeline correspondiente al test de backend:

name: CI - Test Backend

on:
  push:
    branches:
      - '**'
  pull_request:
    branches:
      - '**'

jobs:
  test-backend:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Set up Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18' # Ajusta esta versión según la que uses en tu proyecto

    - name: Install dependencies
      run: npm install
      working-directory: backend

    - name: Run tests
      run: npm test
      working-directory: backend

Explicación:
trigger (on): El pipeline se dispara tanto en push como en la apertura de pull requests en cualquier rama.
jobs.test-backend: Define el trabajo que se ejecutará en un contenedor ubuntu-latest.
actions/checkout@v3: Clona el código del repositorio.
actions/setup-node@v3: Configura Node.js en la versión especificada (puedes ajustar la versión según lo que uses en tu proyecto).
npm install: Instala las dependencias del backend (asumiendo que usas npm).
npm test: Ejecuta las pruebas unitarias.
Este paso asegurará que el código del backend se teste antes de proceder con los siguientes pasos del pipeline. Si tienes alguna modificación o necesitas otro paso adicional, por favor, indícalo.
```

**Prompt 3**

```plaintext
Perfecto. Ahora por favor integra en tu respuesta anterior la generación del build del backend

```
**Chat-GPT4o:**
```plaintext
Aquí tienes el pipeline actualizado que incluye tanto la ejecución de los tests como la generación del build para el backend:

name: CI - Test and Build Backend

on:
  push:
    branches:
      - '**'
  pull_request:
    branches:
      - '**'

jobs:
  test-and-build-backend:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Set up Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18' # Ajusta esta versión según la que uses en tu proyecto

    - name: Install dependencies
      run: npm install
      working-directory: backend

    - name: Run tests
      run: npm test
      working-directory: backend

    - name: Build backend
      run: npm run build
      working-directory: backend

Explicación adicional:
npm run build: Este comando genera el build del backend. Asumo que tienes configurado un script build en el archivo package.json que realiza la compilación del código TypeScript a JavaScript (o cualquier otro proceso de build que necesites).
Este pipeline realizará primero los tests unitarios, y si estos pasan correctamente, procederá a generar el build del backend. Si necesitas algún ajuste adicional o tienes alguna otra pregunta, estaré aquí para ayudarte.

```
**Prompt 4**
```plaintext
Perfecto. Ahora por favor integra en tu respuesta el despliegue del backend en EC2
```
**Chat-GPT4o:**
```plaintext
A continuación te presento el pipeline completo que incluye los pasos para ejecutar los tests, generar el build del backend y finalmente desplegarlo en una instancia EC2 mediante SSH:

name: CI/CD - Test, Build, and Deploy Backend

on:
  push:
    branches:
      - '**'
  pull_request:
    branches:
      - '**'

jobs:
  test-build-and-deploy-backend:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Set up Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18' # Ajusta esta versión según la que uses en tu proyecto

    - name: Install dependencies
      run: npm install
      working-directory: backend

    - name: Run tests
      run: npm test
      working-directory: backend

    - name: Build backend
      run: npm run build
      working-directory: backend

    - name: Deploy to EC2
      env:
        SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
        EC2_HOST: ${{ secrets.EC2_HOST }}
        EC2_USER: ${{ secrets.EC2_USER }}
      run: |
        echo "$SSH_PRIVATE_KEY" > private_key.pem
        chmod 600 private_key.pem
        scp -i private_key.pem -r backend/* $EC2_USER@$EC2_HOST:/path/to/deploy/
        ssh -i private_key.pem $EC2_USER@$EC2_HOST 'cd /path/to/deploy && npm install --production && pm2 restart all'
      working-directory: backend


Explicación adicional:
env Variables:

SSH_PRIVATE_KEY: La clave privada SSH que se utiliza para autenticarse en el servidor EC2. Debe ser almacenada en los secrets de GitHub Actions (Settings > Secrets).
EC2_HOST: La dirección IP o el nombre del host de la instancia EC2, también almacenada como un secret.
EC2_USER: El nombre de usuario SSH para la conexión, como ec2-user o ubuntu, dependiendo de la AMI usada en tu instancia EC2.
echo "$SSH_PRIVATE_KEY" > private_key.pem: Guarda la clave privada en un archivo temporal private_key.pem.

chmod 600 private_key.pem: Cambia los permisos del archivo de clave privada para que solo el propietario tenga acceso (requisito de SSH).

scp: Copia los archivos del backend a la instancia EC2 en la ruta especificada (/path/to/deploy/).

ssh: Conéctate a la instancia EC2 y ejecuta comandos para instalar las dependencias en modo producción (npm install --production) y reiniciar la aplicación usando pm2. Ajusta este comando según cómo se maneje el proceso en tu servidor.

Este pipeline realiza un despliegue continuo, asegurando que el código probado y compilado se despliegue automáticamente en la instancia EC2 cuando se realiza un push o se abre un pull request.

Si necesitas algún ajuste o aclaración adicional, no dudes en pedirlo.



