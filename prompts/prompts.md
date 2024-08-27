### PROMPT
Eres un experto desarrollador fullstack de NodeJS. Este proyecto @Codebase   contiene un backend y un frontend. Genera un workflow en @ci.yml  usando Github Actions de manera que:
- éste se lance cuando se detecte un push commit en una rama que tenga un "pull request" abierto
- ejecute los tests existentes en el @backend 
- ejecute un build de la parte @backend 
- despliegue el backend en una instancia EC2 (teniendo en cuenta que mi entorno Github ya contiene las variables secretas "EC2_SSH_KEY", "HOST_DNS", "TARGET_DIR" y "USERNAME". 
Por favor, ignora cualquier etapa relacionada con el frontend.

Si necesitas cualquier aclaración para generar el código que haga que todo funcione como descrito más arriba, no dudes en consultarme

### PROMPT
No estoy seguro de qué valor debería de tener TARGET_DIR en los secretos de Github Actions?


### PROMPT
He puesto en mis secretos el valor de texto del archivo pem, envuelto con el encabezado
-----BEGIN RSA PRIVATE KEY-----
y terminando con
-----END RSA PRIVATE KEY-----

Es esta una buena práctica en cuanto a seguridad? Quiero almacenar el archivo o su contenido en Github Secret Manager, cómo puedo usarlo mientras me conecto a la instancia EC2 por SSH?

### PROMPT
  la etapa de despliegue en EC2 falla, extrañamente: 

#########
  ssh -i ec2_key.pem $USERNAME@$HOST_DNS "mkdir -p $TARGET_DIR"
  scp -i ec2_key.pem -r backend/dist/* $USERNAME@$HOST_DNS:$TARGET_DIR
  ssh -i ec2_key.pem $USERNAME@$HOST_DNS "pm2 restart all"
  shell: /usr/bin/bash -e {0}
  env:
    EC2_SSH_KEY: ***
    HOST_DNS: ***
    TARGET_DIR: ***
    USERNAME: ***
Host key verification failed.
#########

Sin embargo, ese mismo comando funciona en local. Dudo que sea un problema sino más bien un warning que hay que aceptar. En local, me salta lo siguiente (a lo cual hay que contestar yes):
#########
This host key is known by the following other names/addresses:
    ~/.ssh/known_hosts:1: 16.171.238.147
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
#########