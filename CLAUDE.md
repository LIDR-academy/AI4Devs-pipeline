# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LTI (Sistema de Seguimiento de Talento) is a full-stack talent management system for recruitment processes. It consists of:

- **Frontend**: React application with TypeScript, Bootstrap UI, and React Router
- **Backend**: Express.js with TypeScript, Prisma ORM, and PostgreSQL database
- **Architecture**: Domain-Driven Design (DDD) with layered architecture following SOLID principles

## Common Development Commands

### Backend Development
```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Database setup and migrations
npx prisma generate
npx prisma migrate dev
ts-node seed.ts

# Development server (with hot reload)
npm run dev

# Build for production
npm run build

# Start production server
npm start

# Run tests
npm test

# Prisma commands
npm run prisma:generate
```

### Frontend Development
```bash
# Navigate to frontend directory
cd frontend

# Install dependencies
npm install

# Development server
npm start

# Build for production
npm run build

# Run tests
npm test

# E2E testing with Cypress
npm run cypress:open
npm run cypress:run
```

### Docker & Database
```bash
# Start PostgreSQL database
docker-compose up -d

# Stop database
docker-compose down
```

### Full Application Setup
```bash
# Install all dependencies
cd frontend && npm install
cd ../backend && npm install

# Start database
docker-compose up -d

# Setup backend
cd backend
npm run build
npm start

# Start frontend (new terminal)
cd frontend
npm start
```

## Architecture Overview

### Backend Structure (Domain-Driven Design)

**Layer Organization**:
- `src/domain/models/`: Core business entities (Candidate, Position, Interview, etc.)
- `src/application/services/`: Business logic and use cases
- `src/presentation/controllers/`: HTTP request handling
- `src/routes/`: API route definitions
- `prisma/`: Database schema and migrations

**Key Domain Entities**:
- **Candidate**: Core aggregate root with educations, work experiences, resumes, and applications
- **Position**: Job positions with interview flows and requirements
- **Interview**: Interview process management with steps and flows
- **Company**: Organizations with employees and positions

**Design Patterns Applied**:
- **Repository Pattern**: Data access abstraction (partially implemented)
- **Service Layer**: Business logic encapsulation in `application/services/`
- **Domain Models**: Rich domain objects with business behavior
- **Aggregates**: Candidate as aggregate root containing related entities

### Frontend Structure

**Component Organization**:
- `src/components/`: React components for UI elements
- `src/services/`: API service layer for backend communication
- **Key Components**: RecruiterDashboard, AddCandidateForm, Positions, PositionDetails

**Technology Stack**:
- React 18 with TypeScript
- React Router for navigation
- Bootstrap 5 for styling
- React Beautiful DnD for drag-and-drop
- Cypress for E2E testing

## Database Schema

**Primary Entities**:
- `Candidate` (1:N with Education, WorkExperience, Resume, Application)
- `Position` (N:1 with Company, 1:N with Application)
- `Interview` flow system with InterviewFlow, InterviewStep, InterviewType
- `Company` and `Employee` management

**Database Configuration**:
- PostgreSQL running on localhost:5432
- Connection: `postgresql://LTIdbUser:D1ymf8wyQEGthFR1E9xhCq@localhost:5432/LTIdb`
- Prisma ORM for database operations

## API Endpoints

**Candidate Management**:
- `POST /candidates` - Create new candidate with educations, work experiences, and CV
- `GET /candidates/:id` - Retrieve candidate by ID
- File upload support for CV/resumes

**Position Management**:
- Position CRUD operations
- Interview flow management

**Key API Patterns**:
- RESTful design
- JSON request/response format
- File upload support via Multer
- OpenAPI specification in `backend/api-spec.yaml`

## Development Guidelines

### Code Quality Standards
- **SOLID Principles**: Enforced throughout codebase (see ManifestoBuenasPracticas.md)
- **DRY Principle**: Avoid code duplication
- **TypeScript**: Strict typing for both frontend and backend
- **Testing**: Jest for unit tests, Cypress for E2E tests

### Key Design Decisions
- **Domain-Driven Design**: Business logic centered around domain models
- **Layered Architecture**: Clear separation between domain, application, and presentation layers
- **Aggregate Pattern**: Candidate serves as aggregate root for related entities
- **Value Objects**: Education and WorkExperience as value objects within Candidate aggregate

## Testing Strategy

**Backend Testing**:
- Unit tests for services: `candidateService.test.ts`, `positionService.test.ts`
- Controller tests: `candidateController.test.ts`, `positionController.test.ts`
- Test command: `npm test` (Jest)

**Frontend Testing**:
- E2E tests with Cypress: `cypress/integration/positionDetails.spec.js`
- Component testing with Jest and React Testing Library
- Test commands: `npm test`, `npm run cypress:open`

## CI/CD Pipeline

**GitHub Actions Configuration** (`.github/workflows/ci.yml`):
- Triggered on pull requests to `main` and `develop` branches
- Frontend-focused pipeline: install dependencies, run tests, build React app
- Deployment to EC2 with SSH and rsync
- Nginx restart for web server

**Required Secrets**:
- `EC2_SSH_PRIVATE_KEY`: SSH private key for EC2 access
- `EC2_HOST`: EC2 instance hostname/IP
- `EC2_USER`: SSH username for EC2
- `EC2_DEPLOY_PATH`: Deployment path on EC2

## Environment Setup

**Local Development**:
- Node.js 18+
- PostgreSQL via Docker
- Frontend: http://localhost:3000
- Backend: http://localhost:3010

**Production Deployment**:
- EC2 instance with Node.js and Nginx
- PM2 for process management
- Environment variables in `.env` files

## Key Files and Documentation

- `backend/ManifestoBuenasPracticas.md`: Comprehensive DDD and SOLID principles guide
- `backend/ModeloDatos.md`: Complete database model documentation with ERD
- `backend/api-spec.yaml`: OpenAPI specification for all endpoints
- `backend/prisma/schema.prisma`: Database schema definition
- `prompts/prompts.md`: Project prompts and guidelines

## Development Best Practices

- Follow existing domain model patterns when adding new entities
- Use TypeScript interfaces for type safety
- Implement proper error handling and validation
- Maintain separation of concerns between layers
- Write tests for new functionality
- Follow the established file and directory structure
- Use Prisma migrations for database schema changes