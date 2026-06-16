# Prompts utilizados para generar el Pipeline

## 1. Tests de backend

**Prompt:**
Escribe un job de GitHub Actions en YAML para un proyecto Node.js con TypeScript
que instale las dependencias y ejecute los tests con Jest.
El backend está en la carpeta ./backend del repositorio.

## 2. Build del backend

**Prompt:**
Escribe un job de GitHub Actions que, después de que pasen los tests,
instale las dependencias y compile el backend TypeScript usando `npm run build`.
El backend está en la carpeta ./backend.

## 3. Deploy en EC2

**Prompt:**
Escribe un job de GitHub Actions que se conecte por SSH a una instancia EC2 de AWS
usando los secrets EC2_HOST, EC2_USER y EC2_SSH_KEY, y que despliegue
el backend Node.js ejecutando git pull, npm install, npm run build
y reiniciando el proceso con pm2.