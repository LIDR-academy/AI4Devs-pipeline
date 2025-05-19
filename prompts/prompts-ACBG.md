# Prompts utilizados para la generación del Pipeline de CI/CD

## Prompt1:  para Fase de Pruebas  <Cursor Agent Cloud 3.7 sonet>

```
Necesito configurar un job en GitHub Actions para ejecutar pruebas en un backend Node.js con TypeScript que usa Prisma ORM y PostgreSQL. El job debe:
1. Ejecutarse en ubuntu-latest
2. Configurar un servicio de PostgreSQL para las pruebas
3. Configurar Node.js 18
4. Instalar dependencias en el directorio backend
5. Configurar las variables de entorno para pruebas
6. Ejecutar migraciones de Prisma
7. Ejecutar los tests
```

## Prompt2:  para Fase de Build  <Cursor Agent Cloud 3.7 sonet>

```
Necesito configurar un job en GitHub Actions que genere el build de un backend Node.js con TypeScript, después de que las pruebas hayan pasado correctamente. El job debe:
1. Ejecutarse en ubuntu-latest
2. Configurar Node.js 18
3. Instalar dependencias en el directorio backend
4. Ejecutar el comando de build
5. Comprimir los artefactos generados (dist, node_modules, package.json, prisma)
6. Subir los artefactos para que estén disponibles para el job de despliegue
```

## Prompt3: para Fase de Despliegue en EC2  <Cursor Agent Cloud 3.7 sonet>

```
Necesito configurar un job en GitHub Actions para desplegar un backend Node.js en una instancia EC2 de AWS, después de que el job de build haya completado. El job debe:
1. Ejecutarse solo cuando hay un push a una rama con un PR abierto
2. Descargar los artefactos del job de build
3. Configurar una clave SSH para conectarse a la instancia EC2 usando secretos
4. Transferir los archivos a la instancia EC2
5. Ejecutar comandos remotos en la instancia para:
   - Detener cualquier servicio previo
   - Limpiar directorios antiguos
   - Extraer los archivos nuevos
   - Configurar variables de entorno
   - Iniciar la aplicación con PM2
```

## Prompt4: para Configuración del Trigger  <Cursor Agent Cloud 3.7 sonet>

```
Necesito configurar el trigger de un workflow de GitHub Actions para que se ejecute en dos situaciones:
1. Cuando se crea, sincroniza o reabre un Pull Request
2. Cuando se hace push a cualquier rama

Además, necesito asegurar que el job de despliegue solo se ejecute cuando se hace push a una rama que tiene un PR abierto.
``` 

## Prompt5: para Instalación Automática de PM2  <Cursor Agent Cloud 3.7 sonet>

```
Necesito modificar el script de despliegue para que verifique si PM2 está instalado en la instancia EC2 y lo instale si no lo está. El script debe:
1. Verificar si PM2 está disponible
2. Instalar PM2 globalmente si no está presente
3. Mantener el resto de la funcionalidad de despliegue
```

## Prompt6: para Credenciales Secretas  <Cursor Agent Cloud 3.7 sonet>
```
Por ejemplo:
Yo tengo que "EC2_USER" == ec2-user
Y ya lo subí al "Settings" → "Secrets and variables" → "Actions" cada secreto de las otras credenciales:
en el actual código @pipeline.yml  debo modificar algo?
```

## Prompt7: para Documentación del PR  <Cursor Agent Cloud 3.7 sonet>
```
Ayúdame con el mensaje para el PR de entrega que incluya:
1. Objetivo del pipeline
2. Flujo y steps implementados
3. Configuración de seguridad
4. Mejoras realizadas
5. Instrucciones de uso
6. Estado de validación
```

## Prompt8: para Verificación Final  <Cursor Agent Cloud 3.7 sonet>
```
No, ahora verifiquemos que estamos cumpliendo con la **misión** @tarea.md
```