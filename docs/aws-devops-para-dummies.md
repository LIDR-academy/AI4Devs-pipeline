# AWS y DevOps para dummies: despliegue de staging paso a paso

## Indice

- [1. Para que sirve todo esto](#1-para-que-sirve-todo-esto)
- [2. Mapa mental de las piezas](#2-mapa-mental-de-las-piezas)
- [3. GitHub explicado facil](#3-github-explicado-facil)
- [4. GitHub Secrets explicado facil](#4-github-secrets-explicado-facil)
- [5. AWS explicado facil](#5-aws-explicado-facil)
- [6. IAM explicado para dummies](#6-iam-explicado-para-dummies)
- [7. ECR explicado para dummies](#7-ecr-explicado-para-dummies)
- [8. EC2 explicado para dummies](#8-ec2-explicado-para-dummies)
- [9. Security Group explicado para dummies](#9-security-group-explicado-para-dummies)
- [10. Instance Profile explicado para dummies](#10-instance-profile-explicado-para-dummies)
- [11. Docker explicado para dummies](#11-docker-explicado-para-dummies)
- [12. Docker Compose explicado para dummies](#12-docker-compose-explicado-para-dummies)
- [13. nginx explicado para dummies](#13-nginx-explicado-para-dummies)
- [14. Prisma explicado para dummies](#14-prisma-explicado-para-dummies)
- [15. El proceso real realizado hasta el exito](#15-el-proceso-real-realizado-hasta-el-exito)
- [16. Que mirar si algo falla](#16-que-mirar-si-algo-falla)
- [17. Que quedo pendiente o mejorable](#17-que-quedo-pendiente-o-mejorable)
- [18. Resumen ultra corto](#18-resumen-ultra-corto)

## 1. Para qué sirve todo esto

El objetivo era llevar una aplicación full-stack desde el repositorio de GitHub hasta una máquina en AWS, de forma que cada push a `main` pudiera construir la aplicación, subir sus imágenes Docker y desplegarla automáticamente.

Dicho en sencillo:

```text
Código en GitHub
  -> GitHub Actions construye Docker
  -> AWS ECR guarda las imágenes
  -> EC2 descarga las imágenes
  -> Docker Compose arranca la app
  -> El navegador entra por HTTP
```

La aplicación tiene:

- Un backend Node/Express.
- Un frontend React servido con nginx.
- Una base de datos PostgreSQL.
- Migraciones con Prisma.

Al final del proceso, staging quedó funcionando en:

```text
Frontend: http://18.100.242.22
Backend health: http://18.100.242.22/api/health
```

## 2. Mapa mental de las piezas

| Pieza | Explicación simple | Para qué la usamos |
|---|---|---|
| GitHub | Donde vive el código | Guardar el repo y lanzar pipelines |
| GitHub Actions | Robot que ejecuta tareas | Construir, subir y desplegar |
| Secrets | Caja fuerte de GitHub | Guardar claves, passwords e IPs |
| AWS | Plataforma cloud | Alojar registro, servidor y permisos |
| IAM | Sistema de usuarios/permisos AWS | Decidir quién puede hacer qué |
| ECR | Docker Hub privado de AWS | Guardar imágenes Docker |
| EC2 | Máquina virtual en AWS | Ejecutar la app |
| Security Group | Firewall de AWS | Abrir/cerrar puertos |
| Instance Profile | Rol pegado a EC2 | Permitir que EC2 lea ECR |
| Docker | Empaqueta apps en contenedores | Ejecutar backend, frontend y DB |
| Docker Compose | Orquestador sencillo de contenedores | Levantar varios servicios juntos |
| nginx | Servidor web/proxy | Servir frontend y redirigir `/api` |
| Prisma | ORM/migraciones | Crear/actualizar tablas de PostgreSQL |

## 3. GitHub explicado fácil

GitHub es donde está el código. Pero además de guardar código, GitHub puede ejecutar tareas automáticas mediante GitHub Actions.

Un workflow de GitHub Actions es como una receta:

```text
Cuando alguien haga push a main:
  1. Descarga el código.
  2. Construye Docker.
  3. Sube imágenes a AWS.
  4. Entra en EC2.
  5. Despliega.
```

En este proyecto el workflow importante es:

```text
.github/workflows/cd-staging.yml
```

## 4. GitHub Secrets explicado fácil

Los secrets son variables privadas. Sirven para no escribir claves en el código.

Ejemplo de lo que no queremos hacer:

```text
AWS_SECRET_ACCESS_KEY=mi-clave-secreta-en-el-repo
```

Eso sería peligroso porque cualquiera con acceso al repo podría verla.

En su lugar, se guardan en:

```text
GitHub -> Repo -> Settings -> Secrets and variables -> Actions
```

Secrets que usamos:

| Secret | Qué significa |
|---|---|
| `AWS_ACCESS_KEY_ID` | Identificador de la clave AWS para GitHub Actions |
| `AWS_SECRET_ACCESS_KEY` | Parte secreta de la clave AWS |
| `AWS_REGION` | Región donde está AWS trabajando |
| `AWS_ACCOUNT_ID` | Número de cuenta AWS |
| `EC2_HOST_STAGING` | IP pública de la instancia EC2 |
| `EC2_USER` | Usuario SSH, `ec2-user` |
| `EC2_SSH_KEY` | Clave privada `.pem` para entrar por SSH |
| `DB_USER` | Usuario de PostgreSQL |
| `DB_PASSWORD` | Password de PostgreSQL |
| `DB_NAME` | Nombre de la base de datos |
| `DATABASE_URL` | URL completa que usa Prisma |
| `STAGING_API_URL` | URL de la API usada por el frontend |
| `STAGING_FRONTEND_URL` | URL pública del frontend |

## 5. AWS explicado fácil

AWS es una caja enorme de servicios cloud. En este despliegue usamos solo unas pocas piezas:

- IAM para permisos.
- ECR para guardar imágenes Docker.
- EC2 para ejecutar la aplicación.
- Security Groups para controlar tráfico de red.

## 6. IAM explicado para dummies

IAM es el portero de AWS. Decide:

```text
Quién eres
Qué puedes hacer
Sobre qué recursos puedes hacerlo
```

Ejemplos:

- GitHub Actions puede subir imágenes a ECR.
- EC2 puede descargar imágenes desde ECR.
- Nadie recibe permisos de administrador global si no hace falta.

### 6.1 Usuario IAM para GitHub Actions

Creamos un usuario:

```text
github-actions-lti
```

Este usuario representa al robot de GitHub Actions dentro de AWS.

No necesita entrar en la consola web. Solo necesita claves programáticas:

```text
Access Key ID
Secret Access Key
```

Estas claves se guardan en GitHub Secrets.

### 6.2 Política IAM

Una política IAM es una lista de permisos.

La política que se creó decía, en esencia:

```text
Puedes autenticarte en ECR.
Puedes subir imágenes a lti-backend.
Puedes subir imágenes a lti-frontend.
No te doy permisos para tocar otras cosas.
```

AWS no mostró cómodamente la opción de política inline durante la creación del usuario. Por eso se hizo mediante grupo:

```text
Usuario -> Grupo -> Política
```

Esto es normal y también es una práctica razonable.

## 7. ECR explicado para dummies

ECR, Elastic Container Registry, es un almacén de imágenes Docker.

Una imagen Docker es como una caja cerrada que contiene:

- Código.
- Dependencias.
- Comando de arranque.
- Sistema base mínimo.

Creamos dos repositorios ECR:

```text
lti-backend
lti-frontend
```

El workflow sube ahí las imágenes:

```text
backend Docker image -> ECR/lti-backend
frontend Docker image -> ECR/lti-frontend
```

Luego EC2 las descarga.

## 8. EC2 explicado para dummies

EC2 es una máquina virtual en AWS. Es como alquilar un ordenador Linux en la nube.

Creamos una instancia:

```text
Nombre: lti-staging
Sistema: Amazon Linux 2023
Tipo: t3.small
Usuario: ec2-user
```

Dentro de esa máquina instalamos:

- Docker.
- Docker Compose.
- AWS CLI.

Y creamos el directorio:

```text
/opt/lti-app
```

Ese directorio contiene:

- `docker-compose.prod.yml`
- `.env` privado con variables del entorno

## 9. Security Group explicado para dummies

Un Security Group es un firewall.

Pregunta:

```text
Qué tráfico puede entrar en mi EC2?
```

Reglas finales:

| Puerto | Qué es | Quién puede entrar |
|---|---|---|
| 80 | HTTP | Todo Internet |
| 443 | HTTPS | Todo Internet |
| 22 | SSH | Solo mi IP |

El puerto 80 se abre porque queremos ver la web.

El puerto 443 se suele abrir para HTTPS, aunque en este ejercicio todavía no configuramos certificado TLS.

El puerto 22 sirve para entrar por SSH. Este es delicado. Si se abre a todo Internet, cualquier persona puede intentar atacar la máquina. Por eso se cerró de nuevo a solo la IP del usuario.

Durante un momento se abrió SSH a:

```text
0.0.0.0/0
```

Eso significa:

```text
Cualquier IP del mundo.
```

Se hizo temporalmente porque GitHub Actions necesitaba entrar por SSH y su IP no era la misma que la del usuario.

## 10. Instance Profile explicado para dummies

La instancia EC2 necesitaba descargar imágenes desde ECR.

Una forma mala sería copiar claves AWS dentro de EC2.

La forma correcta es darle a EC2 un rol:

```text
lti-ec2-ecr-pull-role
```

Ese rol se asocia como Instance Profile.

Traducción sencilla:

```text
AWS sabe que esta EC2 tiene permiso para leer ECR.
La EC2 no necesita guardar access keys.
```

Permiso usado:

```text
AmazonEC2ContainerRegistryReadOnly
```

## 11. Docker explicado para dummies

Docker permite empaquetar una aplicación y ejecutarla igual en muchos sitios.

En lugar de instalar Node, dependencias y configuración a mano en EC2, se crea una imagen:

```text
Imagen backend
Imagen frontend
Imagen postgres
```

Luego Docker ejecuta contenedores a partir de esas imágenes.

Un contenedor es una instancia en ejecución de una imagen.

### 11.1 El problema que Docker resuelve

Sin Docker, desplegar una aplicación suele implicar instalar muchas cosas en el servidor:

```text
Instala Node.
Instala npm.
Instala dependencias.
Configura variables.
Instala nginx.
Instala PostgreSQL.
Asegúrate de que las versiones coinciden.
Arranca procesos.
Cruza los dedos.
```

El problema es que el servidor de producción puede no ser igual que el ordenador del desarrollador. Una versión distinta de Node, OpenSSL, PostgreSQL o una dependencia puede romper algo.

Docker intenta solucionar esto empaquetando la aplicación con casi todo lo que necesita para ejecutarse.

La idea es:

```text
Si la imagen Docker funciona, debería funcionar igual en cualquier sitio con Docker.
```

### 11.2 Imagen Docker

Una imagen Docker es como una plantilla congelada de una aplicación.

Contiene:

- Sistema base mínimo, por ejemplo Alpine Linux.
- Runtime, por ejemplo Node.js.
- Código de la aplicación.
- Dependencias instaladas.
- Archivos compilados.
- Comando de arranque.

En este proyecto se crean dos imágenes propias:

```text
lti-backend
lti-frontend
```

Y se usa una imagen ya existente para PostgreSQL:

```text
postgres:15-alpine
```

Una imagen no es todavía una aplicación corriendo. Es más bien el molde.

### 11.3 Contenedor Docker

Un contenedor es una imagen en ejecución.

Ejemplo sencillo:

```text
Imagen: lti-backend
Contenedor: lti-app-backend-1 corriendo ahora mismo en EC2
```

La diferencia es parecida a:

```text
Receta de cocina = imagen
Plato cocinado = contenedor
```

Puedes crear varios contenedores desde la misma imagen. Cada contenedor es un proceso aislado.

En nuestro staging quedaron contenedores como:

```text
lti-app-db-1
lti-app-backend-1
lti-app-frontend-1
```

### 11.4 Dockerfile

Un `Dockerfile` es el archivo de instrucciones para construir una imagen.

Ejemplo conceptual:

```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
CMD ["node", "dist/index.js"]
```

Traducción:

```text
Empieza desde Node 20.
Crea una carpeta /app.
Copia package.json.
Instala dependencias.
Copia el código.
Compila.
Cuando arranque, ejecuta node dist/index.js.
```

En este proyecto hay dos Dockerfiles:

```text
backend/Dockerfile
frontend/Dockerfile
```

### 11.5 Build de una imagen

Construir una imagen significa ejecutar las instrucciones del Dockerfile.

Ejemplo local:

```bash
docker build -t lti-backend ./backend
```

En nuestro caso lo hace GitHub Actions, no manualmente:

```yaml
context: ./backend
push: true
```

Eso significa:

```text
Construye la imagen usando la carpeta backend.
Después súbela al registry.
```

### 11.6 Registry

Un registry es un almacén de imágenes Docker.

Ejemplos:

- Docker Hub.
- GitHub Container Registry, `ghcr.io`.
- Amazon ECR.

En este despliegue usamos Amazon ECR.

El flujo fue:

```text
GitHub Actions construye imagen
GitHub Actions sube imagen a ECR
EC2 descarga imagen desde ECR
Docker Compose arranca contenedor
```

### 11.7 Tags

Un tag es una etiqueta de versión de una imagen.

Ejemplo:

```text
297797203707.dkr.ecr.eu-south-2.amazonaws.com/lti-backend:latest
297797203707.dkr.ecr.eu-south-2.amazonaws.com/lti-backend:0cba574f10a02f77d3aff05874d68de501431f77
```

La parte antes de los dos puntos es la imagen. La parte después de los dos puntos es el tag.

```text
Imagen: 297797203707.dkr.ecr.eu-south-2.amazonaws.com/lti-backend
Tag: latest
```

En el workflow se usan tags basados en el SHA del commit:

```text
0cba574f10a02f77d3aff05874d68de501431f77
```

Esto es útil porque permite saber exactamente qué versión del código se desplegó.

También se usa:

```text
staging-latest
```

que significa "la última imagen construida para staging".

### 11.8 Pull y push

`push` significa subir una imagen a un registry.

```text
GitHub Actions -> ECR
```

`pull` significa descargar una imagen desde un registry.

```text
EC2 <- ECR
```

En el log del pipeline se vio algo como:

```text
Pulling from lti-backend
Downloaded newer image
```

Eso significa que EC2 descargó correctamente la nueva imagen desde ECR.

### 11.9 Variables de entorno en Docker

Las variables de entorno permiten configurar una app sin cambiar el código.

Ejemplos:

```text
DB_USER
DB_PASSWORD
DB_NAME
DATABASE_URL
FRONTEND_URL
PORT
```

El backend necesita saber cómo conectarse a PostgreSQL. En Docker Compose se le pasa:

```text
DATABASE_URL=postgresql://usuario:password@db:5432/base
```

El detalle importante es `db`.

En local quizá se usaría:

```text
localhost
```

Pero dentro de Docker Compose, el hostname correcto es el nombre del servicio:

```text
db
```

Por eso la URL correcta dentro de Docker es:

```text
postgresql://LTIdbUser:<password>@db:5432/LTIdb
```

### 11.10 Volúmenes

Un contenedor puede desaparecer y volver a crearse. Si la base de datos guardase sus datos solo dentro del contenedor, podríamos perderlos al recrearlo.

Para evitarlo se usa un volumen:

```yaml
volumes:
  - postgres_data:/var/lib/postgresql/data
```

Eso significa:

```text
Guarda los datos de PostgreSQL en un volumen persistente llamado postgres_data.
```

En este proyecto el volumen real quedó con nombre:

```text
lti-app_postgres_data
```

Gracias a ese volumen, si se recrea el contenedor `db`, los datos no desaparecen automáticamente.

### 11.11 Redes Docker

Docker Compose crea una red interna para que los contenedores se vean entre sí.

En este proyecto:

```yaml
networks:
  lti-network:
    driver: bridge
```

Dentro de esa red:

- El frontend puede llamar a `backend`.
- El backend puede llamar a `db`.
- PostgreSQL no necesita estar expuesto a Internet.

Esto es clave:

```text
El backend habla con db:5432.
nginx habla con backend:3010.
El usuario solo ve el puerto 80.
```

### 11.12 Puertos

En Docker hay que distinguir entre:

- Puerto dentro del contenedor.
- Puerto publicado en el host EC2.

Ejemplo:

```yaml
ports:
  - "80:80"
```

Esto significa:

```text
Puerto 80 de EC2 -> puerto 80 del contenedor frontend
```

El backend escucha en el puerto 3010, pero no se publica:

```text
No hay "3010:3010"
```

Eso es intencionado. El backend queda privado dentro de Docker y nginx lo alcanza por red interna.

### 11.13 Multi-stage build

Los Dockerfiles del proyecto usan multi-stage build.

Eso significa que la imagen se construye en fases:

```text
Fase 1: builder
  - Instala todo.
  - Compila.
  - Genera artefactos.

Fase 2: production
  - Copia solo lo necesario.
  - Instala dependencias de producción.
  - Arranca la app.
```

Ventajas:

- Imagen final más pequeña.
- Menos herramientas innecesarias en producción.
- Menor superficie de ataque.

En el backend se usó:

```dockerfile
FROM node:20-alpine AS builder
...
FROM node:20-alpine AS production
```

En el frontend:

```dockerfile
FROM node:20-alpine AS builder
...
FROM nginx:1.25-alpine AS production
```

Traducción:

```text
El frontend se compila con Node, pero en producción lo sirve nginx.
```

### 11.14 Imagen Alpine

Alpine es una distribución Linux muy pequeña. Muchas imágenes Docker la usan porque pesa poco.

Ejemplos:

```text
node:20-alpine
postgres:15-alpine
nginx:1.25-alpine
```

Ventaja:

```text
Imágenes más pequeñas.
```

Inconveniente:

```text
Algunas librerías nativas necesitan binarios específicos.
```

Esto nos afectó con Prisma. Por eso hubo que usar:

```prisma
binaryTargets = ["native", "linux-musl-openssl-3.0.x"]
```

Y añadir OpenSSL:

```dockerfile
RUN apk add --no-cache openssl
```

### 11.15 Por qué Prisma falló dentro de Docker

Prisma necesita unos binarios llamados engines. Estos dependen del sistema operativo y OpenSSL.

El error fue:

```text
Can't write to /app/node_modules/@prisma/engines
```

Qué estaba pasando:

1. La imagen final instalaba solo dependencias de producción.
2. `prisma` estaba en `devDependencies`.
3. Al ejecutar migraciones, `npx prisma` intentó preparar cosas en runtime.
4. El contenedor corría con usuario no-root.
5. No pudo escribir en `node_modules`.

Solución:

```text
Mover prisma a dependencies.
Generar binarios correctos para Alpine.
Instalar OpenSSL.
```

Este es un aprendizaje Docker importante:

```text
Todo lo que necesites en producción debe estar preparado dentro de la imagen.
No conviene depender de descargas o escrituras inesperadas en runtime.
```

### 11.16 Docker Compose frente a docker run

`docker run` sirve para arrancar un contenedor individual.

Ejemplo:

```bash
docker run postgres:15-alpine
```

Pero una aplicación real suele tener varios contenedores conectados.

Por eso usamos Docker Compose:

```bash
docker compose -f docker-compose.prod.yml up -d
```

Eso arranca todos los servicios definidos:

```text
db
backend
frontend
```

En el workflow también se usó `docker run` para una tarea puntual:

```bash
docker run --rm \
  --network lti-app_lti-network \
  -e DATABASE_URL="..." \
  <imagen-backend> \
  npx prisma migrate deploy
```

Ese contenedor se crea solo para ejecutar migraciones y luego se elimina gracias a:

```text
--rm
```

### 11.17 Comandos Docker útiles para este proyecto

En EC2 por SSH:

```bash
docker ps
```

Muestra contenedores corriendo.

```bash
docker ps -a
```

Muestra también contenedores parados.

```bash
docker logs lti-app-backend-1
```

Muestra logs del backend.

```bash
docker logs lti-app-frontend-1
```

Muestra logs del frontend/nginx.

```bash
docker logs lti-app-db-1
```

Muestra logs de PostgreSQL.

```bash
cd /opt/lti-app
docker compose -f docker-compose.prod.yml config
```

Valida cómo queda el compose final con variables resueltas.

```bash
docker compose -f docker-compose.prod.yml up -d
```

Levanta servicios en segundo plano.

```bash
docker compose -f docker-compose.prod.yml down
```

Para servicios. Ojo: no borra volúmenes salvo que se use `-v`.

```bash
docker image prune -f
```

Limpia imágenes antiguas no usadas.

### 11.18 Cómo encaja Docker con AWS y GitHub Actions

El flujo completo con Docker fue:

```text
1. GitHub Actions lee backend/Dockerfile.
2. Construye imagen del backend.
3. GitHub Actions lee frontend/Dockerfile.
4. Construye imagen del frontend.
5. Sube ambas imágenes a ECR.
6. EC2 hace docker pull desde ECR.
7. Docker Compose usa esas imágenes.
8. Se arrancan contenedores nuevos.
9. nginx expone el frontend por puerto 80.
10. nginx proxy redirige /api al backend.
```

Esta separación es potente porque EC2 no compila código. EC2 solo descarga imágenes ya construidas y las ejecuta.

Eso reduce problemas en producción:

```text
Build en GitHub Actions.
Runtime en EC2.
```

### 11.19 Resumen Docker en una frase

Docker permitió convertir backend, frontend y base de datos en piezas empaquetadas, versionadas y ejecutables de forma repetible en EC2.

## 12. Docker Compose explicado para dummies

Docker Compose permite decir:

```text
Arranca estos tres contenedores juntos:
  - db
  - backend
  - frontend
Y conéctalos en una red común.
```

El fichero usado fue:

```text
docker-compose.prod.yml
```

Servicios:

| Servicio | Imagen | Puerto público |
|---|---|---|
| `db` | `postgres:15-alpine` | Ninguno |
| `backend` | ECR `lti-backend` | Ninguno |
| `frontend` | ECR `lti-frontend` | 80 |

La base de datos no se expone al exterior. El backend tampoco. Solo el frontend/nginx recibe tráfico desde fuera.

## 13. nginx explicado para dummies

nginx hace dos trabajos:

1. Sirve la aplicación frontend React.
2. Redirige las llamadas `/api` al backend.

Ejemplo:

```text
Usuario abre:
http://18.100.242.22

nginx devuelve:
La app React
```

Y para la API:

```text
Usuario o health check llama:
http://18.100.242.22/api/health

nginx lo reenvía internamente a:
http://backend:3010/health
```

Así no necesitamos abrir el puerto 3010 al exterior.

## 14. Prisma explicado para dummies

Prisma es una herramienta que ayuda al backend a hablar con la base de datos.

También gestiona migraciones.

Una migración es una instrucción para crear o modificar tablas.

Ejemplo conceptual:

```text
Crea tabla Candidate.
Crea tabla Position.
Añade columna email.
```

En el pipeline se ejecuta:

```bash
npx prisma migrate deploy
```

Eso aplica en la base de datos las migraciones pendientes.

## 15. El proceso real realizado hasta el éxito

### 15.1 Crear permisos para GitHub Actions

Primero se creó el usuario IAM `github-actions-lti`.

Como AWS no dejaba avanzar sin permisos y no aparecía claramente la política inline, se creó un grupo y se asoció la política al grupo.

Resultado:

```text
GitHub Actions tiene permiso para subir imágenes a ECR.
```

### 15.2 Crear repositorios ECR

En Elastic Container Registry se crearon:

```text
lti-backend
lti-frontend
```

Resultado:

```text
AWS ya tiene dónde guardar las imágenes Docker.
```

### 15.3 Crear EC2

Se lanzó una instancia EC2:

```text
lti-staging
```

Con:

```text
Amazon Linux 2023
t3.small
Security Group con 80, 443 y 22
Instance Profile para pull desde ECR
```

Resultado:

```text
Ya había una máquina donde ejecutar la app.
```

### 15.4 Entrar por SSH

Desde PowerShell local:

```powershell
ssh -i "C:\Users\salonso\Downloads\lti-staging-key.pem" ec2-user@18.100.242.22
```

Al principio falló porque Windows consideraba la clave `.pem` demasiado abierta.

Se corrigió con `icacls`.

Resultado:

```text
SSH funcionando.
```

### 15.5 Instalar Docker y preparar EC2

En EC2:

```bash
sudo dnf install -y docker
sudo systemctl enable --now docker
sudo usermod -aG docker ec2-user
```

Se instaló Docker Compose y se creó:

```text
/opt/lti-app
```

Resultado:

```text
EC2 preparada para ejecutar contenedores.
```

### 15.6 Copiar docker-compose.prod.yml

Desde PowerShell local:

```powershell
scp -i "C:\Users\salonso\Downloads\lti-staging-key.pem" .\docker-compose.prod.yml ec2-user@18.100.242.22:/opt/lti-app/
```

Resultado:

```text
EC2 ya tenía la receta de Docker Compose.
```

### 15.7 Crear .env en EC2

En EC2 se creó:

```text
/opt/lti-app/.env
```

Con variables como:

```text
DB_USER
DB_PASSWORD
DB_NAME
FRONTEND_URL
DATABASE_URL
IMAGE_BACKEND
IMAGE_FRONTEND
```

Resultado:

```text
Docker Compose ya podía resolver variables.
```

### 15.8 Configurar GitHub Secrets

En GitHub se crearon los secrets para:

- AWS.
- EC2.
- Base de datos.
- URLs de staging.

Resultado:

```text
El workflow ya podía autenticarse y desplegar.
```

### 15.9 Primer fallo: GitHub no podía entrar por SSH

Error:

```text
dial tcp ***:22: i/o timeout
```

Causa:

```text
SSH solo permitía la IP del usuario, no la de GitHub Actions.
```

Solución temporal:

```text
Abrir SSH a 0.0.0.0/0.
```

Resultado:

```text
GitHub Actions pudo conectar por SSH.
```

### 15.10 Segundo fallo: Prisma no podía escribir engines

Error:

```text
Can't write to /app/node_modules/@prisma/engines
```

Causa:

```text
El CLI de Prisma no estaba bien preparado en la imagen final.
```

Solución:

- Mover `prisma` a `dependencies`.
- Instalar `openssl`.
- Ajustar `binaryTargets` a Alpine.

Resultado:

```text
Las migraciones Prisma se aplicaron correctamente.
```

### 15.11 Tercer fallo: health check contra puerto equivocado

Error:

```text
Health check fallido tras 60s
```

Causa:

```text
El workflow probaba http://localhost:3010/health,
pero el backend no expone 3010 al host.
```

Solución:

```text
Probar http://localhost/api/health.
```

Resultado:

```text
El health check pasó usando nginx.
```

### 15.12 Cuarto ajuste: frontend apuntaba a localhost

El frontend tenía llamadas a:

```text
http://localhost:3010
```

En staging eso no funciona para usuarios.

Solución:

- Crear helper `apiUrl`.
- Usar `REACT_APP_API_URL`.
- Configurar `STAGING_API_URL` como:

```text
http://18.100.242.22/api
```

Resultado:

```text
El frontend usa la URL correcta de staging.
```

### 15.13 Éxito del pipeline

Finalmente el pipeline pasó:

- Build y push a ECR.
- Deploy a EC2.
- Migraciones aplicadas.
- Contenedores arrancados.
- Health check correcto.
- Job E2E completado.

Resultado final:

```text
Staging desplegado correctamente.
```

## 16. Qué mirar si algo falla

| Síntoma | Posible causa | Dónde mirar |
|---|---|---|
| GitHub no conecta por SSH | Security Group cerrado | AWS EC2 Security Groups |
| Docker pull falla | Rol EC2 sin permisos ECR | IAM Role / Instance Profile |
| Push a ECR falla | Usuario IAM sin permisos | GitHub Actions logs / IAM |
| Migraciones fallan | Prisma o DATABASE_URL | Logs del job Deploy |
| Frontend no llama a API | URL hardcodeada o secret mal | `STAGING_API_URL` |
| Health check falla | Ruta/puerto equivocado | nginx, workflow, backend |
| App no carga | Contenedores caídos | `docker ps`, `docker logs` |

Comandos útiles en EC2:

```bash
cd /opt/lti-app
docker ps
docker logs lti-app-backend-1
docker logs lti-app-frontend-1
docker logs lti-app-db-1
docker compose -f docker-compose.prod.yml config
```

## 17. Qué quedó pendiente o mejorable

### 17.1 HTTPS real

El puerto 443 está abierto, pero haría falta configurar TLS con un certificado.

Opciones:

- nginx + Let's Encrypt.
- Application Load Balancer + ACM.
- CloudFront.

### 17.2 SSH más seguro para deploy

Abrir SSH a GitHub Actions no es ideal.

Mejoras:

- AWS SSM.
- Deploy mediante runner autoalojado dentro de AWS.
- Bastion host.
- Automatizar rangos IP de GitHub.

### 17.3 E2E reales

El job E2E pasó, pero había tests pendientes. Conviene activar tests reales que validen flujos importantes.

### 17.4 Limpieza de warnings

GitHub Actions avisó de deprecación de Node.js 20 en algunas actions. No bloquea ahora, pero conviene actualizar actions cuando haya versiones compatibles.

## 18. Resumen ultra corto

Lo que hicimos fue:

```text
1. Dar permisos a GitHub para subir imágenes a AWS.
2. Crear un registro Docker privado en AWS.
3. Crear una máquina EC2.
4. Instalar Docker en esa máquina.
5. Configurar GitHub Secrets.
6. Preparar Docker Compose.
7. Arreglar problemas de SSH, Prisma, nginx y URLs.
8. Ejecutar el pipeline hasta que pasó.
9. Cerrar SSH de nuevo.
```

El resultado:

```text
Aplicación full-stack desplegada en AWS staging con CI/CD.
```
