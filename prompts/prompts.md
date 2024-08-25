# Prompt 1

Eres un experto en pipelines con github actions y expressJS

Necesito llenar el archivo @ci.yml con el código necesario para que se ejecute un pipeline al haber un push a una rama con un pull request abierto, el cual va a hacer que se despliegue el código de @backend a una instancia EC2 en AWS, los pasos serían los siguientes:

- Se detecta el push a una rama con un pull request abierto
- Se ejecutan los tests del backend
- Si los tests pasan, se hace un build del backend
- Si el build es correcto, despliega el build del backend en EC2

No generes nada, hazme las preguntas que creas necesarias para completar mi solicitud

## Respuesta

Entendido. Para crear un pipeline de GitHub Actions que cumpla con los requisitos que has mencionado, necesito hacerte algunas preguntas para obtener más detalles:

1. ¿Tienes ya configuradas las credenciales de AWS en los secretos de tu repositorio de GitHub?

2. ¿Cuál es la versión de Node.js que estás utilizando en tu proyecto backend?

3. ¿Tienes un script específico para ejecutar los tests en tu archivo package.json?

4. ¿Tienes un script específico para hacer el build en tu archivo package.json?

5. ¿Cuál es la dirección IP o el nombre de dominio de tu instancia EC2?

6. ¿Tienes una clave SSH configurada para acceder a tu instancia EC2?

7. ¿En qué directorio de la instancia EC2 quieres desplegar tu aplicación?

8. ¿Necesitas ejecutar algún comando adicional en la instancia EC2 después de desplegar el código (por ejemplo, reiniciar el servidor)?

9. ¿Quieres que el pipeline se ejecute solo para ciertas ramas o para todas las ramas con pull requests abiertos?

10. ¿Hay algún archivo o directorio específico que quieras excluir del despliegue?

Con esta información, podré crear un pipeline de GitHub Actions más preciso y adaptado a tus necesidades específicas.

# Prompt 2

1. No, pero lo haré, podrías decirme cómo hacerlo?

2. NodeJS 20

3. Sí, se llama test

4. Sí, se llama build

5. ec2-44-202-190-26.compute-1.amazonaws.com

6. Sí, la pondré en los secrets de Github Actions

7. Recomiéndame alguno

8. No, solo iniciar el servidor con el script start que está en el package.json

9. Todas las ramas a las que se les haga un push y tengan un pull request abierto

10. node_modules, pero debería ejecutarse un npm ci en el build para cumplir con las dependencias y poder ejecutart el comando build

# Prompt 3

Recuerda que las dependencias y el código están bajo la carpeta @backend , por lo tanto, no habría que actualizar el archivo @ci.yml ?

# Prompt 4

Y si lo que quiero es que se ejecute el pipeline solo para un pull request abierto cuando se haga push?

# Prompt 5

Necesito que al momento de subir los archivos, es decir, la ejecución de scp, no subas el node_modules a la instancia de EC2

En la instancia de EC2 debería ejecutarse el comando npm ci

Y cada vez que se haga el mkdir, antes de él, debería ejecutarse un rm -R para limpiar

# Prompt 6

El comando npm start no está dejando finalizar el pipeline, cómo puedo solucionarlo?
