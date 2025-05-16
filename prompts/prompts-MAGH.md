# Prompt 1

Estoy trabajando en un proyecto con esta estructura:

backend/: Node.js con tests en Jest.

frontend/: React con tests en Cypress.

Quiero que generes un archivo .github/workflows/pipeline.yml para GitHub Actions que haga lo siguiente:

🔁 Trigger
Se dispare cuando se haga push a una rama con un Pull Request abierto.

⚙️ Pasos del workflow
Ejecutar tests del backend (npm install && npm test en backend/).

Ejecutar tests del frontend (npm install && npm run test o npx cypress run en frontend/).

Build del backend (npm run build en backend/).

Build del frontend (npm run build en frontend/).

Desplegar ambos en una instancia EC2 usando SSH, con los secretos:

AWS_ACCESS_ID, AWS_ACCESS_KEY, EC2_INSTANCE, EC2_SSH_PRIVATE_KEY, EC2_USER.

El workflow debe:

Fallar si los tests o builds fallan.

Solo desplegar si todo lo anterior tuvo éxito.