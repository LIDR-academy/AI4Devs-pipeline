# Prompt 1
Eres un DevOps Engineer Senior con experiencia en generación de scripts de despliegues de infraestructura como código (IaC).

Genera en formato YAML, en un nuevo fichero '.github/workflows/pipeline.yml', un pipeline de GitHub Actions que se ejecute cuando haya un push a una rama con un Pull Request abierto y que haga lo siguiente:
 - Construya y pase los test de backend, tal como se indica en el fichero @README.md 
 - Construya la aplicación usando Docker.
 - Despliegue la aplicación backend en un servidor EC2.
___
# Prompt 2
¿Qué buenas prácticas recomiendas para mejorar este pipeline? ¿Debería configurar un proxy inverso?
___
# Prompt 3
Tras configurar Nginx como proxy inverso en un nuevo paso del job de deployment, realiza las siguientes optimizaciones:
1. Cachea las dependencias de npm para reducir tiempos de build. Cachea también los builds de docker entre ejecuciones
2. Incluye los tests de integración además de los unitarios y añade cobertura de código para medir la calidad
___
# Prompt 4
Elimina del pipeline todo lo relacionado con el frontend y también con Docker Hub. No te he pedido nada al respecto
___
# Prompt 5
Una vez definido el @pipeline.yml, confirma si:
1. El backend quedará ejecutándose en segundo plano
2. Sólo se despliega si los todos los tests pasan
___
# Prompt 6
Durante la ejecución del pipeline, tengo el siguiente error:

Construir imagen Docker
buildx failed with: ERROR: failed to solve: failed to read dockerfile: open Dockerfile: no such file or directory
___
# Prompt 7
Elimina el paso de construcción Docker
___
# Prompt 8
En la nueva ejecución del pipeline obtengo el siguiente warning:

build-and-test
No files were found with the provided path: backend/coverage/. No artifacts will be uploaded.

Además, veo que no se ha ejecutado el job 'deploy-to-ec2'. Debería haberlo hecho, porque se ha producido un push a una rama con un pull request abierto