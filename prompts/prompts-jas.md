## Prompt 1

Ayudame a crear un pipeline de github actions en el archivo pipeline.yml para un proyecto en nodeJS, que a la hora de hacer el trigger "push a una rama con un Pull Request abierto" ejecute los siguientes pasos:

1. Instale las dependencias del proyecto backend
2. Ejecute las pruebas unitarias del proyecto backend
3. Si las pruebas pasan, construya la aplicación del backend
4. Despliegue el backend en un servidor de EC2