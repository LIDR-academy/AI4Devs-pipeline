# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LTI (Talent Tracking System) is a full-stack ATS (Applicant Tracking System) with:
- **Backend**: Node.js + Express + TypeScript, using Prisma ORM with PostgreSQL
- **Frontend**: React (JavaScript/TypeScript mix), bootstrapped with Create React App
- **Database**: PostgreSQL via Docker

Backend runs on `http://localhost:3010`, frontend on `http://localhost:3000`.

## Commands

### Backend (`cd backend`)
```sh
npm run dev          # Development with hot reload (ts-node-dev)
npm run build        # Compile TypeScript → dist/
npm start            # Run compiled dist/index.js
npm test             # Run Jest tests
npm run prisma:generate  # Regenerate Prisma client after schema changes
```

Run a single test file:
```sh
npx jest src/application/services/candidateService.test.ts
```

Prisma database setup (from `backend/`):
```sh
npx prisma migrate dev
ts-node prisma/seed.ts
```

### Frontend (`cd frontend`)
```sh
npm start            # Dev server
npm run build        # Production build
npm test             # Jest tests
npm run cypress:open # Cypress E2E (interactive)
npm run cypress:run  # Cypress E2E (headless)
```

### Infrastructure (root)
```sh
docker-compose up -d    # Start PostgreSQL container
docker-compose down     # Stop container
```

## Architecture

### Backend (DDD layered architecture)

```
backend/src/
├── index.ts                    # Express app entry point, middleware setup
├── routes/                     # Route definitions (candidateRoutes, positionRoutes)
├── presentation/controllers/   # HTTP controllers — parse req/res, call services
├── application/services/       # Use cases / application logic
│   └── validator.ts            # Input validation
├── domain/models/              # Domain entities (Candidate, Position, Application, etc.)
└── infrastructure/             # (implied by Prisma) — data access
```

Domain models (`domain/models/`) encapsulate business logic and map directly to Prisma schema entities: `Candidate`, `Education`, `WorkExperience`, `Resume`, `Company`, `Employee`, `Position`, `Application`, `InterviewFlow`, `InterviewStep`, `InterviewType`, `Interview`.

The `Candidate` aggregate root owns `Education`, `WorkExperience`, `Resume`, and `Application`.

`PrismaClient` is attached to every Express request via middleware in `index.ts` (`req.prisma`), making it available in controllers without direct imports.

### Frontend

```
frontend/src/
├── App.js                      # Root component with React Router routes
├── components/                 # Feature components (Positions, PositionDetails, RecruiterDashboard, etc.)
└── services/candidateService.js # API client calls to backend
```

Uses React Bootstrap for UI, `react-beautiful-dnd` / `react-dnd` for drag-and-drop (Kanban board for candidate pipeline stages).

### Key design constraints (from ManifestoBuenasPracticas.md)

- Follow DDD: domain logic lives in `domain/models/`, not in controllers or routes
- Apply SOLID principles: SRP per class, use repositories to abstract data access
- Avoid repeating validation or DB logic — centralize in domain models or services
- New routes should follow the pattern in `backend/src/prompts/CreateNewRoute.md`

## Environment

Root `.env` defines DB credentials used by `docker-compose.yml`. Backend `backend/.env` should contain `DATABASE_URL`. The Prisma schema currently hard-codes a connection string — prefer using the `DATABASE_URL` env var via `backend/.env`.

## API Reference

Full OpenAPI spec: `backend/api-spec.yaml`  
Data model diagram: `backend/ModeloDatos.md`

## CI / Deployment

GitHub Actions workflow is at `.github/workflows/ci.yml` (currently empty — this is the task for this branch).

Production targets an EC2 instance. Required GitHub secrets: `AWS_ACCESS_ID`, `AWS_ACCESS_KEY`, `EC2_INSTANCE`.
