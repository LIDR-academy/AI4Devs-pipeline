# Prompts ESP

### Notas

No pude correr el ejercicio por que los test fallaban, de echo los solucione pero por error use el repo 
original y ahi no puedo hacer push, entonces pues perdi los cambios echos en los archivos de test
pero conserve los prompts(solo los relevantes al ejercicio del pipeline), lo que si pude hacer fue todo 
el video "Dudas DevSecOps"

---

# Prompt 1
utiliza el archivo @pipeline.yml  para generar un workflow de github actions 

Este debe ejecutarse al realizar un push a una rama con un pull request abierto, debera ejecutar lo siguiente

- Pasar los test del backend
- Generar un build del backend
- Desplegar el backend en una instancia EC2

Si necesitas aclarar algo primero pregunta antes de continuar

# Respuesta 

Entiendo que necesitas crear un workflow de GitHub Actions para automatizar el proceso de CI/CD. Antes de proceder con la implementación, necesito aclarar algunos puntos importantes:

1. ¿Cuál es el lenguaje de programación utilizado en el backend?
2. ¿Tienes ya configuradas las credenciales de AWS como secretos en GitHub Actions?
3. ¿Ya tienes una instancia EC2 configurada o necesitas crear una nueva como parte del workflow?
4. ¿Tienes un archivo de configuración específico para los tests (como jest.config.js, pytest.ini, etc.)?
5. ¿Hay algún requisito específico para el proceso de build (como variables de entorno, dependencias especiales, etc.)?

Estas aclaraciones me ayudarán a crear un workflow más preciso y adaptado a tus necesidades específicas. Una vez que tenga esta información, podré generar un pipeline que:
- Se active con pushes en PRs abiertos
- Ejecute los tests del backend
- Realice el build
- Despliegue en EC2

¿Podrías proporcionarme esta información para proceder con la implementación del workflow?

---

# Prompt 2

1. El backend utiliza Typescript puedes encontrar mas información en la carpeta @backend 
2. Tengo credenciales de una instancia que use recientemente, y pienso usar las mismas para este proyecto, en esa instancia hice un ejercicio similar, hazme saber si tengo que hacer algun tipo de reinicio o si es mejor que cree una instancia nueva para obtener nuevas credenciales
3. Ya tengo una instancia EC2
4. Si, tengo test los cuales puedes ejecutar dentro de la carpeta del backend ejecutando npm test, adjuto una conversación donde fueron solucionados ye ejecutados @Errores en pruebas de backend y frontend
5. El requisito del build seria seguir las instruciones del backend incluidas en el readme @README.md , es decir, ejecutar las migraciones de prisma para que entonces los test puedan hacer uso de la estructura 

# Respuesta

Gracias por proporcionar toda esta información. Basado en tus respuestas, puedo proceder a crear el workflow. Sin embargo, tengo algunas preguntas adicionales sobre la instancia EC2 existente:

1. ¿La instancia EC2 existente ya tiene Node.js, PM2 y las demás dependencias necesarias instaladas?
2. ¿Tienes las credenciales de AWS (AWS_ACCESS_KEY_ID y AWS_SECRET_ACCESS_KEY) ya configuradas como secretos en GitHub?
3. ¿Tienes la IP o DNS de la instancia EC2 también configurada como secreto en GitHub?

Mientras tanto, te explico lo que voy a hacer:

Voy a crear un workflow que:
1. Se ejecutará cuando se haga push a una rama con un PR abierto
2. Configurará Node.js y las dependencias necesarias
3. Ejecutará las migraciones de Prisma
4. Ejecutará los tests
5. Realizará el build
6. Desplegará en tu instancia EC2 existente

Sin embargo, antes de proceder con la implementación del workflow, necesito confirmar estos detalles sobre los secretos y la configuración de GitHub para asegurar un despliegue exitoso. ¿Podrías confirmarme estos puntos?

También, respecto a tu instancia EC2 existente, te recomendaría:
1. Hacer un respaldo de cualquier dato importante en la instancia actual
2. Verificar que tienes suficiente espacio en disco para el nuevo despliegue
3. Considerar detener cualquier aplicación que esté corriendo en los mismos puertos que usará esta aplicación

¿Te gustaría que proceda con la creación del workflow una vez que confirmes estos detalles?

---

# Prompt 3
1. La instancia no cuenta con las dependecias 
2.Si, tengo, AWS_ACCESS_KEY_ID, AWS_CRECRET_ACCESS_KEY, AWS_REGION, EC2_INSTANCE EC2_SSH_PRIVATE_KEY y EC2_USER

Porfavor dame las instrucciones para reniciar y dejar limpia mi instancia de EC2, para que esta pueda ser usada para este nuevo proyecto

# Respuesta 
Perfecto, te ayudaré a preparar tu instancia EC2 para el nuevo proyecto. Primero, vamos a limpiar y reiniciar la instancia.

Voy a crear un comando para conectarnos a tu instancia y realizar la limpieza:

```bash
ssh -i ~/.ssh/id_rsa ${EC2_USER}@${EC2_INSTANCE} 'sudo systemctl stop nginx; pm2 kill; sudo rm -rf /home/ec2-user/app/*; sudo yum remove -y nodejs npm; sudo yum clean all'
```

---

# Prompt 4
ejecute el comando  ```sudo systemctl stop nginx; pm2 kill; sudo rm -rf /home/ec2-user/app/*; sudo yum remove -y nodejs npm; sudo yum clean all``` directamente en la conexión ssh de aws 

# Respuesta

Excelente, ahora que has limpiado la instancia, vamos a proceder a crear el workflow de GitHub Actions. Primero, crearé el archivo pipeline.yml:


He creado el workflow de GitHub Actions. Aquí te explico lo que hace cada parte:

1. **Triggers**:
   - Se ejecuta cuando se abre o actualiza un PR
   - Solo se activa cuando hay cambios en la carpeta `backend/`

2. **Jobs**:
   - Usa Ubuntu como sistema operativo
   - Configura Node.js 18
   - Instala las dependencias del proyecto
   - Ejecuta las migraciones de Prisma
   - Corre los tests
   - Hace el build
   - Configura las credenciales de AWS
   - Configura el acceso SSH
   - Despliega en EC2

3. **Despliegue en EC2**:
   - Instala Node.js, PM2 y Nginx en la instancia
   - Transfiere los archivos necesarios
   - Configura y arranca la aplicación con PM2

Para que esto funcione, necesitas agregar un secreto más en GitHub:
- `DATABASE_URL`: La URL de conexión a tu base de datos PostgreSQL

¿Necesitas ayuda para configurar este secreto adicional o tienes alguna pregunta sobre el workflow?

También, para asegurarnos de que todo funcione correctamente, deberías:

1. Verificar que todos los secretos estén correctamente configurados en GitHub:
   - AWS_ACCESS_KEY_ID
   - AWS_SECRET_ACCESS_KEY
   - AWS_REGION
   - EC2_INSTANCE
   - EC2_SSH_PRIVATE_KEY
   - EC2_USER
   - DATABASE_URL

2. Asegurarte de que la instancia EC2 tenga:
   - Los puertos necesarios abiertos (80, 3000, etc.)
   - Suficiente espacio en disco
   - Los permisos necesarios en el grupo de seguridad

¿Quieres que verifique alguno de estos aspectos o necesitas ayuda con alguna configuración específica?
git