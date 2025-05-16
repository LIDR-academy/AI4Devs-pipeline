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

## Prompt 2

````md
# PR Description Summary

I have made a set of changes in the current branch. Please analyze the full diff and provide a clear and concise Pull Request description that includes the following:

## ✅ Required Output

1. **Summary of the Changes**:
   - A high-level overview of what was modified, added, removed, or refactored.
   - Mention affected components, files, or features.

2. **Reasoning Behind the Changes**:
   - Why each significant change was made.
   - What problems or limitations the changes address.

3. **Any Relevant Context or Considerations**:
   - Mention any known side effects, breaking changes, or considerations for reviewers.
   - If applicable, include links to related issues, tickets, or discussions.

## 💡 Format

Please output the result in well-structured Markdown, using sections such as:

\`\`\`markdown
## Summary

...

## Rationale

...

## Additional Context

...
\`\`\`

The goal is to help other developers understand **what** was changed and **why**, in order to facilitate an effective review and improve project documentation.

---

Only use information that can be inferred from the code changes and existing comments. Avoid making assumptions beyond what is available in the diff.
````