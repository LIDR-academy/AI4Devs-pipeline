# Pipeline de CI/CD para Backend

Este documento describe el pipeline de CI/CD implementado para el backend de la aplicación.

## Visión General

El pipeline realiza las siguientes tareas:
1. **Pruebas**: Ejecuta tests unitarios y de integración en el código del backend
2. **Build**: Compila el código TypeScript y prepara un paquete de despliegue
3. **Despliegue**: Despliega el código en una instancia EC2 de AWS

## Flujo de Trabajo

El pipeline se activa en dos escenarios:
- Cuando se hace un push a una rama con un Pull Request abierto hacia `main`
- Cuando se hace un push directo a la rama `main`

### Etapa de Pruebas

En esta etapa:
- Se configura un entorno de pruebas con PostgreSQL
- Se instalan las dependencias del proyecto
- Se genera el cliente Prisma
- Se ejecutan las pruebas con Jest

### Etapa de Build

Solo se ejecuta si las pruebas pasan y el evento es un push a `main`:
- Instala dependencias
- Genera el cliente Prisma
- Compila el código TypeScript
- Prepara un paquete de despliegue con los archivos necesarios
- Almacena el paquete como un artefacto

### Etapa de Despliegue

Solo se ejecuta si el build es exitoso y el evento es un push a `main`:
- Descarga el artefacto generado en la etapa anterior
- Configura credenciales de AWS
- Transfiere el paquete a la instancia EC2
- Ejecuta comandos de despliegue en la instancia
- Configura y reinicia el servicio

## Secretos Requeridos

El pipeline utiliza los siguientes secretos que deben configurarse en GitHub:
- `AWS_ACCESS_KEY_ID`: ID de clave de acceso de AWS
- `AWS_SECRET_ACCESS_KEY`: Clave de acceso secreta de AWS
- `AWS_REGION`: Región de AWS donde se encuentra la instancia EC2
- `EC2_SSH_KEY`: Clave SSH privada para conectar a la instancia
- `EC2_HOST`: Dirección DNS o IP de la instancia EC2
- `EC2_USERNAME`: Nombre de usuario para conectar a la instancia (ej. ec2-user)
- `DATABASE_URL`: URL de conexión a la base de datos PostgreSQL

## Configuración de EC2

La instancia EC2 debe tener:
- Node.js 18+ instalado
- PostgreSQL accesible (local o remoto)
- Usuario con permisos sudo para configurar servicios systemd
