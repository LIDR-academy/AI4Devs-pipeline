# Prompts Preliminares

## Preparando el entorno
## Chatbot: ChatGPT

---
Hazme un resumen de la siguiente url:
https://docs.github.com/en/actions/writing-workflows/quickstart

---
Necesito emepzar a crear workflows de github actions

---
en el ejemplo cuando se ejecuta el workflow?

---
Analiza la siguiente URL
[https://lightrains.com/blogs/deploy-aws-ec2-using-github-actions/](https://lightrains.com/blogs/deploy-aws-ec2-using-github-actions/)

---
De momento necesito rellenar la parte de los secretos

---
De donde obtengo esa info en AWS, es necesario tener creada ya una EC2?

---
para la EC2\_SSH\_KEY, hay que rellenar el secreto con el contenido del fichero entiendo.


# Prompts Desarrollo Workflow
## Chatbot: Cursor (Sonnet 3.5)


# Prompts Inferidos


[2024-03-19 - Claude-3-Sonnet] Chequea los archivos del proyecto y haz un resumen del contexto

---

[2024-03-19 - Claude-3-Sonnet] Puedes indicarme si hay tests definidos?

---

[2024-03-19 - Claude-3-Sonnet] muestrame donde estan los archivos de test del backend

---

[2024-03-19 - Claude-3-Sonnet] Como DevOPS engineer, se tiene que realizar un workflow en github Actions que realice lo siguiente:

- Pase unos tests de backend.
- Genere un build del backend.
- Despliegue el backend en un EC2. 

El trigger que desencadena el workflow es cuando se haga un push a una rama con un Pull Request abierto
No escribas código todavia
Pregunta las dudas que tengas antes de proseguir
Empieza a sincronizar el prompts-CNV a partir de este prompt, no escribas los anteriores

---

[2024-03-19 - Claude-3-Sonnet] Puntos 1 y 2: Analiza la esctructura del proyecto. Alli esta todo indicado. Lo que no encuentres preguntalo.
Punto 3: 
La instancia esta configurada
El sistema es Ubuntu
El despliegue será en Docker
No es necesario mantener versiones anteriores del backend
Punto 4:
Estan configurados los secretos necesarios, verifica si fala alguno para la conexion con la EC2
No se necesita un permiso especial
Punto 5:
No hay ramas que deban ser ignoradas
Por validacion adicional a que te refieres, Que hayan pasado los tests por ejemplo?

Implementa la propuesta del archivo yml pero aun no escribas código

---

[2024-03-19 - Claude-3-Sonnet] No, para docker no se usa registro privado.
Procede con la creacion del workflow en YML. Hazlo sobre el archivo ci.yml
No modifiques ninguna otra parte del código

---

[2024-03-19 - Claude-3-Sonnet] Para los nombres de los secretos para conectar con EC2, basate en el archivo de prueba @github-actions-ec2.example.yml

---

[2024-03-19 - Claude-3-Sonnet] Describe detalladamente los pasos que hace el archivo de workflow generado

---

[2024-03-19 - Claude-3-Sonnet] En el deployment da error en el paso Deploy to EC2. Tiene problemas al cambiar a la ruta de Target _DIR

---

[2024-03-19 - Claude-3-Sonnet] Si estamos en el proceso de hacer un workflow en el momento que se hace una pull request, cual de las 2 opciones crees que es la mas adecuada? Solo dila, no la implementes

---

[2024-03-19 - Claude-3-Sonnet] En el último paso de Deploy to EC2, ¿qué simbolizan las \\ y los ;? Recuerda que en ese momento estamos en Linux

---

