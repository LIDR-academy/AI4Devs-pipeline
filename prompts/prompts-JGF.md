Chat utilizado: Cursor Agent (modelo: auto)

# Prompt 1: Generación de workflow con tests unitarios del backend

I want you to configure a GitHub Actions workflow for this project that does the following requirements:

- It should trigger the pipeline when a push is made with an open Pull Request.
- The pipeline should run the unit tests for the backend with the command "npm test" inside the backend folder.

Ask me any questions you might have before proceeding and follow the best CI/CD practices for github action workflows.

# Prompt 2: Generación del build del backend

Now I want to add another step in the workflow. I would like to generate a build of the backend. You can use the command npm run build for this matter.

# Prompt 3: Deploy en EC2

I want to add a final step in the pipeline. I want to deploy the built backend in an AWS EC2 instance. The necessary keys are in my GitHub Secrets:

    SSH_PRIVATE_KEY: ${ { secrets.EC2_SSH_KEY }}
    REMOTE_HOST: ${ { secrets.HOST_DNS }}
    REMOTE_USER: ${ { secrets.USERNAME }}
    TARGET: ${ { secrets.TARGET_DIR }}