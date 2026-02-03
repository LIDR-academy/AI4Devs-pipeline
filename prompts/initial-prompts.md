You are a senior software developer knowledgeable in DevSecOps practices, TypeScript and Reaxctjs. You are currently working on an ATS application. 
The frontend is built using Reactjs meanwhile the backend is built using Nodejs and Typescript.

This application is currently operational on a local development environment. 

**GOAL**
Your main goal is now to design the pipeline that will allow to deploy the application to a production environment (personal VPS) using best DevSecOps practices. The codebase will be stored on a GitHub repository. Hence you will need to design a CI/CD pipeline using GitHub Actions.

**CONSTRAINTS**
0. The CI/CD ppeline will trigger on every push to the main branch.
1. Only the backend application will be deployed to the production environment. 
2. The production environment is a personal VPS running Ubuntu 22.04 LTS.
3. The backend application will be containerized using Docker.
4. The deployment process must be automated using GitHub Actions.
5. The unit tests for the backend application must be executed as part of the CI/CD pipeline before deploying to production.
6. Before anything you will need to create a bash script that will serve to create the docker image and push it to Docker Hub.

**REQUIREMENTS**
1. A docker image of the backend application must be built and pushed to Docker Hub.
2. The backend application must be deployed to the production environment using Docker Compose command. The docker-compose.yml file is already available on the production server. The deployment consists in pulling the latest docker image and restarting the container.

**STAGES FOR GitHub Actions CI/CD**
1. **Checkout Code**: Use the `actions/checkout` action to checkout the code from the repository.
2. Get secrets from GitHub repository settings: Docker Hub credentials, SSH private key for the VPS, VPS IP address, and SSH username.
3. **Set up Node.js**: Use the `actions/setup-node` action to set up the Node.js environment.
4. **Install Dependencies**: Install the necessary dependencies for the backend application.
5. Run the linting process to ensure code quality.
6. **Run Unit Tests**: Execute the unit tests for the backend application using a testing framework like Jest or Mocha.
7. **Build Docker Image**: Build the Docker image for the backend application.
8. **Log in to Docker Hub**: Use the `docker/login-action` to log in to Docker Hub using the credentials stored in GitHub secrets.
9. **Push Docker Image**: Push the built Docker image to Docker Hub.
10. **Deploy to Production**: Use SSH to connect to the VPS and execute the necessary Docker Compose commands to pull the latest image and restart the container.

**BASH SCRIPT**
Create a bash script named `build_and_push_docker.sh` which will be a CLI tool that allow to do the following actions:
1. List allthe existing Docker images on Docker Hub for the backend application.
2. Build the Docker image for the backend application.
3. define a tag for the Docker image using the format `username/repository:tag`, where `username` is your Docker Hub username, `repository` is the name of your Docker repository, and `tag` is the version or identifier for the image (e.g., `latest` or a specific version number).
4. Push the Docker image to Docker Hub.

Should you have any doubts or need further clarifications, feel free to ask!