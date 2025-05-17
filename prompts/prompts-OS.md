Cursor with Claude 3.7-sonnet as an agent

**Prompt 1:**

You are a senior DevOps engineer with a strong experience in EC2 and GitHub actions. Your mission is to create a pipeline in GitHub Actions that, after the trigger “push to a branch with an open Pull Request”, follows the following steps:

Pass some backend tests.
Generate a build of the backend.
Deploy the backend on an EC2. 
**To do this, you must set up the GitHub Actions workflow in a .github/workflows/pipeline.yml file**

**Prompt 2:**
Update @pipeline.yml to change the following data:
- the branch to push is pipeline-OS
- to install dependencies, the command is not npm ci but npm install
- replace EC2_HOST to EC2_INSTANCE
- replace EC2_SSH_KEY with EC2_SSH_PRIVATE_KEY

**Prompt 3:**
In your build process I do not see any setup of credentials for AWS to be able to access it, don't you need it?

**Prompt 4:**
Now I want you to put all the backend tests and the build process into the @ci.yml  file, then you update the @pipeline.yml  to launch only if @ci.yml  file passed 

**Prompt 5:**
check @ci.yml and @pipeline.yml because now no action is triggered

**Prompt 6:**
It now triggers fine, I have this issue: 
Download immutable action package 'actions/setup-node@v3'
  Version: 3.9.1
  Digest: sha256:d8c8dbd6e63927801f9de42620f961a361b03be6034dcc11e83ca01f50cb9f40
  Source commit SHA: 3235b876344d2a9aa001b8d1453c930bba69e610
Error: Missing download info for actions/upload-artifact@v3

