# System Patterns

## System Architecture
The application follows a standard **Client-Server Architecture**:
- **Frontend (Client):** React Single Page Application (SPA).
- **Backend (Server):** Node.js/Express REST API.
- **Database:** PostgreSQL relational database.

## Backend Architecture
The backend (`/backend`) is structured using a **Layered Architecture** (Clean Architecture inspired) to separate concerns:

1. **Presentation Layer (`src/presentation/`)**
   - Handles HTTP requests and responses.
   - Controllers interacting with the router.
   
2. **Routes Layer (`src/routes/`)**
   - Defines API endpoints and maps them to controllers.

3. **Application Layer (`src/application/`)**
   - Orchestrates use cases and business flows.
   - Acts as a bridge between presentation and domain layers.

4. **Domain Layer (`src/domain/`)**
   - Contains business logic and models.
   - Pure TypeScript, independent of external frameworks.
   - Prisma models defined in `prisma/schema.prisma`.

5. **Infrastructure Layer (`src/infrastructure/`)**
   - Implements interfaces for external systems (Database, File System, etc.).
   - Database access via Prisma Client.

## Frontend Architecture
The frontend (`/frontend`) is a **React** application created with Create React App:
- **Components:** UI building blocks (likely atomic design or feature-based).
- **Routing:** `react-router-dom` for client-side navigation.
- **State Management:** Local state (useState/useReducer) and likely Context API for global usage (auth, theme).
- **Styling:** Bootstrap / React-Bootstrap for responsive layout and components.

## Directory Structure Map
```
/
├── backend/
│   ├── src/
│   │   ├── application/    # Use cases
│   │   ├── domain/         # Business logic
│   │   ├── infrastructure/ # DB & external services
│   │   ├── presentation/   # Controllers
│   │   ├── routes/         # API Routes
│   │   └── index.ts        # Entry point
│   ├── prisma/             # DB Schema & Seeds
│   └── tests/              # Jest tests
├── frontend/
│   ├── src/                # React source
│   ├── public/             # Static assets
│   └── build/              # Production artifacts
├── docker-compose.yml      # Service orchestration
└── .env                    # Environment variables
```

## Key Dependencies
- Backend depends on Database (PostgreSQL).
- Frontend depends on Backend API.
