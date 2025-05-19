**Prompt 1:**
I want you to analyze this project and give me an overview.

- Techstack
- architecture
- standards
- etc

**Prompt 2:**
Now I need you to be an expert DevOps specialized in configuring pipelines in github and AWS

**Prompt 3:**
with this in mind I need you to focus on:

# Initial Prompts for GitHub Actions Pipeline

## 1. Workflow Configuration Prompt

Create a GitHub Actions workflow file that:

- Triggers on push events to branches with open pull requests
- Runs on Ubuntu latest runner
- Contains three sequential jobs: backend-tests, build-backend, and deploy-to-ec2
- Ensures jobs run in order where deployment only happens if previous steps succeed
- File should be located at `.github/workflows/pipeline.yml`

**Prompt 4:**
Create a GitHub Actions job that:

- Name: backend-tests
- Runs after checkout step
- Sets up Node.js environment (version 18.x)
- Installs dependencies with `npm ci`
- Executes test command `npm test`
- Add proper caching for node_modules
- Include step to fail fast if tests don't pass

**Prompt 5:**
Now, let's continue with the step number 2 (there will be more)

# 2. Backend Tests Job Prompt

Create a GitHub Actions job that:

- Name: backend-tests
- Runs after checkout step
- Sets up Node.js environment (version 18.x)
- Installs dependencies with `npm ci`
- Executes test command `npm test`
- Add proper caching for node_modules
- Include step to fail fast if tests don't pass

**Prompt 6:**
Let's continue with the step number 3

# 3. Build Backend Job Prompt

Create a GitHub Actions job that:

- Name: build-backend
- Depends on successful completion of backend-tests job
- Uses Node.js environment
- Runs build command `npm run build`
- Generates build artifacts in dist/ directory
- Uploads artifacts using actions/upload-artifact@v3
- Ensure proper path configuration for build output

**Prompt 7:**
EC2 Deployment Job Prompt
Create a GitHub Actions deployment job that:

- Name: deploy-to-ec2
- Depends on successful build-backend job
- Uses SSH to connect to EC2 instance
- Utilizes GitHub Secrets for:
  - EC2_HOST
  - EC2_SSH_KEY
  - EC2_USER
- Downloads build artifacts from previous job
- Copies files to EC2 using rsync over SSH
- Executes remote commands to restart service (e.g., pm2, docker, or systemd)
- Includes error handling for deployment failures
- Add step to verify successful deployment
