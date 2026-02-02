# Tech Context

## Technology Stack

### Frontend
- **Language:** TypeScript / JavaScript (React)
- **Framework:** React 18
- **Styling:** Bootstrap 5, React-Bootstrap
- **Routing:** React Router DOM 6
- **Drag & Drop:** `react-beautiful-dnd` or `react-dnd` (based on package.json analysis)
- **HTTP Client:** Native `fetch` or `axios` (to be confirmed in code).

### Backend
- **Runtime:** Node.js
- **Framework:** Express 4
- **Language:** TypeScript
- **ORM:** Prisma
- **Database:** PostgreSQL
- **Documentation:** Swagger (swagger-jsdoc, swagger-ui-express)

### Infrastructure & DevOps
- **Containerization:** Docker, Docker Compose
- **Hosting:** AWS EC2 (t2.micro, Amazon Linux 2023)
- **Security:**
    - **Group:** `LTI-SecurityGroup`
    - **Ports:** 22 (SSH), 80 (HTTP), 3000 (Frontend), 3010 (Backend)
- **CI/CD:** GitHub Actions (Backend CI/CD with OIDC)

## Development Environment
- **Node Version:** 16.x or higher recommended.
- **Package Manager:** `npm`

## Key Commands

| Action | Frontend (`/frontend`) | Backend (`/backend`) |
| :--- | :--- | :--- |
| **Install** | `npm install` | `npm install` |
| **Start Dev** | `npm start` | `npm run dev` |
| **Build** | `npm run build` | `npm run build` |
| **Test** | `npm test` | `npm test` |
| **Cypress** | `npm run cypress:open` | N/A |
| **Prisma Gen**| N/A | `npx prisma generate` |
| **DB Migrate**| N/A | `npx prisma migrate dev` |
| **DB Seed**   | N/A | `ts-node seed.ts` |

## Ports
- **Frontend:** 3000
- **Backend:** 3010
- **PostgreSQL:** 5432
