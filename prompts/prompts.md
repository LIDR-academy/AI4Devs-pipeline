# Prompts

## 1.

Eres un experto en GitHub Actions, en AWS y DevSecOps.
Dame una lista detallada de pasos para generar un pipeline usando github actions para desplegar una aplicación en una instancia de AWS. El objetivo es conocer como hacerlo. El contenido es para un ingeniero de software que no sabe nada sobre el tema. Tus pautas para generar el contenido es forma de lista numerada y que incluya ejemplos. Revisa mis instrucciones ¿tienes alguna pregunta antes de ejecutar esta tarea?


## 2.

Eres un experto en Ingenieria de Prompts y en DevSecOps
# Contexto Inicial
Tengo un proyecto Backend realizado en Node.js con Typescript, Prisma como ORM y PostgresSQL en un contendor de Docker para la base de datos

# Intrucciones generales
Tu tarea es generar un prompt para el chatboot (ChatGPT 4.1) que me ayude a crear un pipeline en GitHub Actions cumpla con los siguientes Requerimientos

# Requerimientos
1. Herramientas a utilizar: Capa gratuita de AWS y Github Actions
2. El pipeline de GitHub Actions tras el trigger "push a una rama con un Pull Request abierto" siga los siguientes pasos:
    * Pase unos tests de backend.
    * Genere un build del backend.
    * Despliegue el backend en un EC2. 
3. Configurar el workflow de GitHub Actions en un archivo .github/workflows/pipeline.yml.

# Consideraciones
- Quien va realizar no es experto en DevSecOps, CI/CD, ni tampoco en AWS o GitHub Actions
- El chatbot tendrá acceso a todo el codigo de proyecto para cumplir con la tarea

# Mejores practicas
- Incluye el rol en el que debe actual el chatbot
- El chatbot tendrá que guiar al desarrollador para cumplir con el objetivo
- El chatbot tedrá que solicitar al usuario archivos del proyecto para tener contexto y cumplir con los puntos del requerimiento 2

# Pautas para generar el contenido
1. El formato de salida va ser un archivo con extensión .md y el contenido en formato Markdown

Antes de generar el prompt revisa mis Requerimientos ¿me esta faltando algo por considerar?
Realiza preguntas si necesitas mas información.