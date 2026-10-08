# Architecture

TalentMatch is a two-workspace npm project.

```text
React + Vite
    |
    | REST / JSON + JWT
    v
Express controllers
    |
    v
Domain services / authorization / state guards
    |
    v
Prisma 6.19.0
    |
    v
PostgreSQL
```

## Backend layers

- `routes/`: URL and middleware composition only.
- `controllers/`: request validation, ownership checks and orchestration.
- `services/`: reusable matching, notifications, activity timeline and TalentCredit logic.
- `middleware/`: authentication, role authorization, file upload and safe errors.
- `prisma/`: schema, migration and rich seed data.

Multi-record business operations such as selection, agreement confirmation, payment funding/release and project completion use Prisma transactions so the database is not left half-updated.

## Frontend

- `context/AuthContext.jsx`: token lifecycle and current user.
- `services/api.js`: one REST client and consistent error propagation.
- `components/`: layout, access guard, cards, status and four-state handling.
- `pages/`: user-goal screens rather than one page per database table.
- `ErrorBoundary`: catches component crashes and provides recovery UI.

Core pages render loading, empty, error and success states. Core actions call the backend and do not use frontend-only fake state.

## Data design

The Prisma domain contains 48 models covering identity, profiles, CV/portfolio, discovery, hiring, history/versioning, agreements, project execution, escrow-like payment, communication, reputation, moderation, files and audit activity.

Important history is not overwritten: application status changes, proposal/quotation versions, agreement versions, payment transactions, revisions, project activities, Job history and admin audits are retained.
