# Active Context

## Current Focus
**Initialization of the Memory Bank and Agent Rules.**
We are establishing the "Brain" of the project to ensure all future agent interactions are context-aware and consistent.

## Active Tasks
- [x] Analyze Repository & Existing Documentation
- [x] Create Memory Bank Structure
- [x] Create Agent Rules (`.agent/rules/00-memory-bank.md`)
- [x] Verification of "Project Brain" activation.
- [x] Log Prompts (Correction)
- [x] Configure CI/CD Pipeline (`.github/workflows/pipeline.yml`)
- [x] Implement OIDC Authentication (AWS CLI & Pipeline Update)
- [x] Create Helper Script (`setup-oidc.sh`)
- [x] Create EC2 Provisioning Script (`setup-ec2.sh`)
- [x] Repository Cleanup (Security Audit, .gitignore)
- [x] Documentation Update (README.md with CI/CD)

## Recent Changes
- Secured repository by updating `.gitignore` and auditing sensitive files.
- Updated `README.md` with comprehensive CI/CD and OIDC instructions.
- Created `setup-ec2.sh` to provision EC2 instance.
- Created `setup-oidc.sh` to automate OIDC/IAM setup.
- Configured OIDC (OpenID Connect) for secure AWS access in CI/CD.
- Created `.github/workflows/pipeline.yml` for Backend CI/CD.
- Created `/memory-bank/` directory.
- Populated `projectbrief.md`, `productContext.md`, `systemPatterns.md`, `techContext.md`.

## Next Steps
1. Create strict agent rule file.
2. Confirm setup with user.
