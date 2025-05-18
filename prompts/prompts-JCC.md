# Lista de Prompts
> Modelo de IA utilizado: Claude-3-Sonnet

## Prompt 1: Análisis del proyecto backend

```
Como experto en desarrollo y arquitectura de software analiza el proyecto @backend  para tener contexto de el, el framework que maneja y el lenguaje que utiliza. Al finalizar dame un muy pequeño resumen de tu analisis.
```

## Prompt 2: Configuración de GitHub Actions para Pull Requests

```
Como DevOps Engineer experto quiero que me ayudes a configurar un workflow en GitHub Actions para que se ejecute solo cuando haya un push a una rama que tenga un Pull Request abierto. El nombre del archivo será `.github/workflows/pipeline.yml`. Solo quiero definir el trigger correcto de este evento.
```

## Prompt 3: Configuración de job de tests en GitHub Actions

```
Estoy construyendo un pipeline en GitHub Actions para el proyecto de backend. El primer paso del pipeline debe ejecutar los tests del backend (por ejemplo, usando `npm run test` o `yarn test`).  
Ayúdame a escribir la parte del job del workflow YAML que se encargue de este paso, asegurándome de instalar dependencias y ejecutar los tests.
```

## Prompt 4: Configuración de job de build en GitHub Actions

```
El pipeline debe generar el build del backend tras pasar los tests. Ayúdame a añadir este paso al workflow de GitHub Actions después de los tests.
```

## Prompt 5: Configuración de despliegue en EC2

```
Quiero que el último paso de mi pipeline despliegue el backend en una instancia EC2. Tengo acceso vía SSH usando una clave privada.
Quiero que este paso haga lo siguiente:  
1. Se conecte por SSH a la instancia EC2.  
2. Se ubique en la carpeta del proyecto o clone el repo si es necesario.  
3. Ejecute `git pull` y luego reinicie el servidor del backend (por ejemplo, con `pm2 restart backend` o `npm start`).

Ayúdame a escribir este paso en el archivo `pipeline.yml`.
```

## Prompt 6: Verificación del pipeline completo

```
Verifica el archivo @pipeline.yml  para revisar que cumpla con estos requisitos teniendo en cuenta el contexto del proyecto de @backend:

crear un pipeline en GitHub Actions que, tras el trigger "push a una rama con un Pull Request abierto", siga los siguientes pasos:

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
```

## Prompt 7: Corrección de trigger en GitHub Actions

```
Tengo este error en github actions:

Error
No event triggers defined in `on`

Creo que se debe cambiar la acción para que se ejecute cuando se haga push, puedes verificar esto ?
```

## Prompt 8: Corrección de errores en el despliegue EC2

```
Ahora tengo este error en github actions:

Run ssh ec2 'mkdir -p /home/***/backend && \
Warning: Permanently added '***' (ED25519) to the list of known hosts.
bash: line 3: git: command not found
bash: line 3: git: command not found
bash: line 6: pm2: command not found
Error: Process completed with exit code 127.
```

## Prompt 9: Corrección de comandos para Amazon Linux

```
Ahora me sale este nuevo error:

Run ssh ec2 'sudo apt-get update && \
Warning: Permanently added '***' (ED25519) to the list of known hosts.
sudo: apt-get: command not found
bash: line 5: git: command not found
bash: line 10: pm2: command not found
Error: Process completed with exit code 127.

El error ocurre porque la instancia EC2 está usando Amazon Linux en lugar de Ubuntu, por lo que los comandos apt-get no funcionan. Se necesita usar yum en su lugar y configurar Node.js usando NVM.
```

## Prompt 10: Optimización del despliegue y permisos

```
Necesitamos optimizar el despliegue para:
1. Usar los archivos del build en lugar de clonar el repositorio
2. Configurar correctamente los permisos en la instancia EC2
3. Asegurar que el usuario tenga los permisos necesarios para ejecutar npm y pm2
```
