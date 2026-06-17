# Prompt 1, Amazon Q

```
Necesito que implementes un pipeline completo de GitHub Actions en el archivo
pipeline.yml .

Objetivo:

* El workflow debe ejecutarse cuando se haga un `push` a una rama que tenga un Pull Request abierto.
* Debe seguir una estrategia CI/CD con tres fases:

  1. Ejecutar los tests del backend.
  2. Generar el build del backend.
  3. Desplegar el backend en una instancia EC2 de AWS.

Requisitos:

1. Crear el workflow en `.github/workflows/pipeline.yml`.

2. Trigger:

   * El pipeline debe ejecutarse ante eventos de `push`.
   * Debe comprobar que la rama sobre la que se hace push tiene un Pull Request abierto antes de continuar.

3. Job `test`:

   * Checkout del código.
   * Configuración del entorno necesario.
   * Instalación de dependencias.
   * Ejecución de los tests del backend.
   * Si los tests fallan, el pipeline debe detenerse.

4. Job `build`:

   * Debe ejecutarse únicamente si `test` finaliza correctamente.
   * Checkout del código.
   * Instalación de dependencias.
   * Generación del build de producción.
   * Publicación o almacenamiento del artefacto generado usando GitHub Actions Artifacts.

5. Job `deploy`:

   * Debe ejecutarse únicamente si `build` finaliza correctamente.
   * Descargar el artefacto generado.
   * Conectarse por SSH a una instancia EC2 usando secretos de GitHub:

     * `EC2_HOST`
     * `EC2_USER`
     * `EC2_SSH_KEY`
   * Copiar el artefacto al servidor.
   * Desplegar la nueva versión del backend.
   * Reiniciar el servicio correspondiente.

6. Utilizar buenas prácticas:

   * Variables mediante `secrets`.
   * Dependencias entre jobs usando `needs`.
   * Uso de acciones oficiales siempre que sea posible.
   * Comentarios explicativos en el YAML.

7. Entrega:

   * Genera el contenido completo y funcional de `pipeline.yml`.
   * No dejes pseudocódigo.
   * Incluye todos los pasos necesarios para que el workflow funcione.
   * Si necesitas asumir que el backend es Node.js, utiliza Node.js LTS y documenta claramente dónde modificar los comandos para otros stacks.

Devuélveme únicamente el contenido final del archivo `pipeline.yml` listo para copiar y pegar.

```
