# Prompts

## Prompt 1

````md
# Prompt for GitHub Actions Workflow Generation

I'm working on a repository with the following structure:

\`\`\`
backend/  # Node.js project with Jest for testing
\`\`\`

Please generate a GitHub Actions workflow file named \`.github/workflows/pipeline.yml\` with the following specifications:

## 🔁 Trigger
- The workflow should run on **push to any branch that has an open Pull Request**.

## 🧪 Workflow Steps
1. **Run backend tests**:
   - Directory: \`backend/\`
   - Commands:
     \`\`\`bash
     npm install
     npm test
     \`\`\`

2. **Build the backend**:
   - Command:
     \`\`\`bash
     npm run build
     \`\`\`

3. **Deploy to an EC2 instance via SSH**, only if all previous steps succeed:
   - Use the following GitHub Secrets for SSH connection:
     - \`HOST_DNS\`
     - \`USERNAME\`
     - \`SSH_PRIVATE_KEY\`
     - \`TARGET_DIR\`
   - Deployment involves copying the build artifacts to the EC2 instance's \`TARGET_DIR\`.

## ✅ Additional Requirements
- The workflow must **fail if tests or build steps fail**.
- The **deployment step should only run if all previous steps are successful**.

Please generate the full content of the \`pipeline.yml\` file accordingly.
````