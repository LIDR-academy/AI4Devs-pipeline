# Project Brief

## Overview
LTI (Talent Tracking System) is a comprehensive full-stack application designed to streamline the recruitment process. It allows recruiters to manage candidates, track their progress through various stages of hiring, and organize candidate data efficiently.

## Core Objectives
- **Candidate Management:** Create, read, update, and delete candidate profiles.
- **Hiring Pipeline:** Track candidates through different status columns (e.g., Applied, Interviewing, Hired, Rejected).
- **Data Organization:** Store and retrieve candidate details including contact info, education, work experience, and CVs.
- **Efficiency:** Provide a fluid user experience with a responsive React frontend and a robust Express backend.

## Key Features
- **Frontend:** React-based UI using Bootstrap for styling, featuring drag-and-drop capabilities (inferred from package.json `react-beautiful-dnd` or similar patterns in typical kanban apps, though not explicitly confirmed in README, standard for "Tracking Systems").
- **Backend:** Express.js server with TypeScript, exposing RESTful endpoints.
- **Database:** PostgreSQL managed via Prisma ORM for type-safe database interactions.
- **Infrastructure:** Docker and Docker Compose for easy deployment and environment setup.
