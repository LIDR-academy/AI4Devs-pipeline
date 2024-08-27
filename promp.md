---
Step 1:

We are using github acction, and the workflow we will use for the project @AI4Devs-pipeline is the file @pipeline.yml

In that firs step, I require:
1. Identify the backend test.
2. configure the backend test, that will trigger when "push to a branch with an open Pull Request"

Cursor:
Here's how you can configure the backend tests in your GitHub Actions workflow
pipeline.yml

This configuration does the following:
The workflow is triggered on pull requests to the main branch.
It defines a job named test-backend that runs on an Ubuntu environment.
The steps for the test-backend job are:
Checkout the code using actions/checkout@v3.
Set up Node.js using actions/setup-node@v3 with version 16.x.
Navigate to the backend directory and install dependencies using npm ci.
Run the backend tests using npm test in the backend directory.

------