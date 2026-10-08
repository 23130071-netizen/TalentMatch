# TalentMatch

TalentMatch is a full-stack freelance/talent marketplace connecting Clients/Companies and Freelancers. It supports two connected marketplace directions:

1. **Job Marketplace** — Client posts a Job → Freelancer discovers and applies → Proposal + Quotation → Shortlist/Negotiation → Selection → Agreement → Mock Escrow → Project → Milestones → Deliverables → Revision/Acceptance → Payment Release → Review → TalentCredit.
2. **Talent Marketplace** — Client searches Freelancer profiles → views professional information, Portfolio and CV → sends Invitation → Freelancer accepts → completes Application with Proposal + Quotation → the same hiring workflow continues.

This source is intentionally designed as a coherent product rather than a collection of CRUD screens.

## Technology

- Node.js: target `>=20 <23` (static QA in this build used Node `22.16.0`)
- Frontend: React `18.3.1`, Vite `6.1.0`, React Router `7.1.5`
- Backend: Express `4.21.2`
- Database: PostgreSQL
- ORM: **Prisma `6.19.0`**
- Prisma Client: **`6.19.0`**
- Authentication: JWT `9.0.2`, bcrypt `6.0.0`
- Validation: Zod `3.24.2`

Important package versions are pinned exactly; the project does not use `latest`, RC, beta or alpha versions.

## Product areas

- Guest Job/Freelancer discovery
- JWT authentication and backend role enforcement
- Role-specific onboarding
- Freelancer professional profile, CV, Portfolio, skills and services
- Client/company profile
- Job create/edit/publish/close and real search/filter/sort
- Freelancer discovery and rule-based explainable matching
- Saved Jobs / Saved Talent
- Direct Application with Proposal + Quotation
- Proposal and Quotation version history
- Client application decision center
- Shortlist and lightweight negotiation
- Invitation → Accept → Complete Application flow
- Selection with database transaction
- Dual-confirmation Agreement
- Mock escrow payment persisted in PostgreSQL
- Project Workspace, Milestones, Deliverables and Revision history
- Change Requests
- Activity timeline
- REST messaging and real notifications with deep links
- Reviews and deterministic TalentCredit history
- Disputes, reports and Admin moderation/audit
- Local file metadata and permission-aware download route
- Loading/empty/error/success UI and frontend Error Boundary

See `docs/ARCHITECTURE.md` and `docs/STATE_MACHINES.md`.

## Project structure

```text
TalentMatch_Complete/
├─ frontend/
│  └─ src/
│     ├─ components/
│     ├─ context/
│     ├─ pages/
│     └─ services/
├─ backend/
│  ├─ prisma/
│  │  ├─ migrations/
│  │  ├─ schema.prisma
│  │  └─ seed.js
│  ├─ src/
│  │  ├─ config/
│  │  ├─ controllers/
│  │  ├─ middleware/
│  │  ├─ routes/
│  │  ├─ services/
│  │  └─ utils/
│  └─ tests/
├─ docs/
├─ scripts/
├─ README.md
├─ TEST_REPORT.md
└─ package.json
```

# Windows setup

## 1. Install Node.js

Install Node.js 20 or 22 LTS, then verify in PowerShell:

```powershell
node -v
npm -v
```

## 2. Install PostgreSQL

Install PostgreSQL locally. PostgreSQL 16 or 17 is a suitable development target. During installation, remember the password for the `postgres` user.

## 3. Create the database

Using pgAdmin Query Tool or `psql`:

```sql
CREATE DATABASE talentmatch;
```

No manual table creation is required; Prisma migration creates the schema.

## 4. Create backend environment file

From the project root in PowerShell:

```powershell
Copy-Item backend\.env.example backend\.env
```

Edit `backend\.env`:

```env
PORT=3001
DATABASE_URL="postgresql://postgres:YOUR_PASSWORD@localhost:5432/talentmatch?schema=public"
JWT_SECRET="replace-with-a-long-random-secret"
JWT_EXPIRES_IN="7d"
CORS_ORIGIN="http://localhost:5173"
UPLOAD_DIR="uploads"
MAX_FILE_MB=10
```

Do not commit `backend/.env`.

## 5. Install dependencies

```powershell
npm install
```

## 6. Validate Prisma

```powershell
npm run prisma:validate
```

Expected result: Prisma reports that `backend/prisma/schema.prisma` is valid.

## 7. Generate Prisma Client

```powershell
npm run prisma:generate
```

## 8. Apply migration

```powershell
npm run db:migrate
```

The repository includes an initial migration under `backend/prisma/migrations/202610080001_init/`.

## 9. Seed realistic demo data

```powershell
npm run db:seed
```

The seed targets 57 users, 36 Jobs, many Applications/Proposals/Quotations, invitations and 15 projects in different business states.

## 10. Optional static/domain checks

```powershell
npm run test:static
npm run test:domain
```

## 11. Build the frontend

```powershell
npm run build
```

## 12. Run TalentMatch

```powershell
npm run dev
```

- Frontend: http://localhost:5173
- Backend: http://localhost:3001
- Health check: http://localhost:3001/api/health

`GET /api/health` reports both server status and whether PostgreSQL is reachable.

# Demo accounts

All demo accounts use password: **`123456`**

| Role | Email |
|---|---|
| Admin | `admin@talentmatch.local` |
| Client | `client1@talentmatch.local` |
| Client | `client2@talentmatch.local` |
| Freelancer | `freelancer1@talentmatch.local` |
| Freelancer | `freelancer2@talentmatch.local` |
| Freelancer | `freelancer3@talentmatch.local` |
| Freelancer | `freelancer4@talentmatch.local` |

Passwords are bcrypt hashes in the database; plaintext demo password exists only in seed documentation/input.

# Important seeded demo scenarios

The seed includes multiple states so demonstrations do not require manually preparing every record:

- OPEN Job with zero applications
- OPEN Jobs with 3+ applications and Proposal/Quotation
- Shortlisted candidates
- Negotiations in progress
- Agreement / Project `PENDING_PAYMENT`
- Payments `HELD`
- ACTIVE Projects
- Milestones in progress and in review
- Revision requested
- Completed Projects
- Completed + reviewed Projects
- Disputes
- Pending Invitations
- Accepted Invitations awaiting Application completion

# Fresh critical workflow to test

Do not rely only on seeded completed records. After setup, test this fresh path:

1. Login as `client1@talentmatch.local`.
2. Create and publish a new Job.
3. Login as `freelancer1@talentmatch.local`.
4. Discover the Job, save it if desired, then Apply with Proposal + Quotation.
5. Login as Client, open the Job Applications decision center.
6. Shortlist, optionally negotiate, then Select Freelancer.
7. Open the created Agreement and confirm as Client.
8. Login as Freelancer, open Agreements and confirm.
9. Client opens the newly created Project, creates Milestones whose total equals the Agreement amount, then clicks **Fund Payment**.
10. Freelancer starts a Milestone and submits a Deliverable.
11. Client starts review and requests Revision.
12. Freelancer resubmits.
13. Client reviews again and Accepts.
14. Repeat until every Milestone is accepted.
15. Client releases Payment; the system completes Project, Agreement and Job.
16. Both parties submit Reviews; Freelancer TalentCredit history updates.

Second critical workflow:

Client opens a Freelancer profile → sends Invitation to an OPEN Job → Freelancer accepts → clicks **Complete Application** → submits Proposal + Quotation → Client receives the resulting Application and continues the normal hiring workflow.

# API groups

Core REST groups include:

- `/api/auth`
- `/api/profiles`
- `/api/jobs`
- `/api/applications`
- `/api/invitations`
- `/api/agreements`
- `/api/projects`
- `/api/reviews`
- `/api/conversations`
- `/api/notifications`
- `/api/disputes`
- `/api/reports`
- `/api/files`
- `/api/admin`

Responses use `{ success, message, data }`. Raw Prisma errors are not returned to end users.

# Security notes

- Backend checks JWT and roles.
- Ownership is checked for private resources.
- Passwords use bcrypt.
- Secrets live only in environment variables.
- Admin APIs require `ADMIN`.
- Project messages/files are participant-restricted.
- Core multi-step mutations use Prisma transactions.
- Review requires a completed Project and uniqueness prevents duplicate bilateral reviews.
- Payment release is blocked unless all milestones are accepted and there is no unresolved dispute.

# Testing status of this delivered build

Read `TEST_REPORT.md` before treating this source as runtime-certified. In the build environment used to prepare this archive, outbound access to `registry.npmjs.org` failed with `EAI_AGAIN`, and PostgreSQL/Docker were not installed. Therefore runtime steps that require installed npm packages or PostgreSQL are explicitly marked **NOT TESTED**, never inferred as PASS from static inspection.
