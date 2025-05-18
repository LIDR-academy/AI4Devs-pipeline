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
