# TalentMatch State Machines

Backend endpoints enforce transitions through operation-specific checks; `backend/src/utils/state.js` contains reusable guards for the most frequently mutated states.

## Job
`DRAFT -> OPEN -> IN_REVIEW/NEGOTIATING -> FILLED -> IN_PROGRESS -> COMPLETED`

Terminal/alternative paths: `OPEN|IN_REVIEW|NEGOTIATING -> CLOSED|CANCELLED`. A Job can only be published by its owner. Selection changes a single-hire Job to `FILLED`; payment activation moves it to `IN_PROGRESS`; successful project completion moves it to `COMPLETED`.

## Application
`APPLIED -> SHORTLISTED -> NEGOTIATING -> SELECTED`

Alternative paths: `APPLIED|SHORTLISTED|NEGOTIATING -> REJECTED|WITHDRAWN`. A selected single-hire application causes competing applications to be rejected.

## Proposal / Quotation
Proposal: `DRAFT -> SUBMITTED -> UPDATED -> WITHDRAWN`.
Quotation: `DRAFT -> SUBMITTED -> UPDATED -> ACCEPTED|REJECTED|WITHDRAWN`.

Edits are allowed only while the parent application is `APPLIED`, `SHORTLISTED` or `NEGOTIATING`. Previous proposal/quotation snapshots are stored in version tables before updates.

## Invitation
`PENDING -> ACCEPTED -> COMPLETED`

Alternative terminal states: `DECLINED`, `EXPIRED`, `CANCELLED`. `ACCEPTED` is not the end of the flow: the Freelancer must complete an Application with Proposal + Quotation; then the invitation becomes `COMPLETED`.

## Agreement
`PENDING_CLIENT_CONFIRMATION <-> PENDING_FREELANCER_CONFIRMATION -> PENDING_PAYMENT -> ACTIVE -> COMPLETED`

Both unique participants must confirm. Only after two confirmations is a Project created in `PENDING_PAYMENT`. Funding changes the Agreement to `ACTIVE`. Project completion changes it to `COMPLETED`. Dispute/cancellation are controlled alternative states.

## Payment
`PENDING -> HELD -> RELEASED`

Alternatives: `PENDING -> FAILED|CANCELLED`; `HELD -> REFUNDED`. Release is blocked until every required milestone is accepted and no blocking dispute exists. Duplicate release is prevented because only a `HELD` payment can be released.

## Project
`PENDING_PAYMENT -> ACTIVE -> COMPLETED`

Alternative: `ACTIVE -> DISPUTED -> ACTIVE` after resolution, or cancellation where permitted. A Project cannot activate before funding. Completion requires accepted milestones, released payment and no blocking dispute.

## Milestone
`PENDING -> IN_PROGRESS -> SUBMITTED -> IN_REVIEW -> ACCEPTED -> COMPLETED`

Revision branch: `IN_REVIEW -> REVISION_REQUESTED -> RESUBMITTED -> IN_REVIEW`.

## Deliverable
`SUBMITTED -> IN_REVIEW -> ACCEPTED`

Revision branch: `IN_REVIEW -> REVISION_REQUESTED -> RESUBMITTED -> IN_REVIEW`.

## Revision
`OPEN -> ACKNOWLEDGED -> RESUBMITTED -> RESOLVED`

The request record is preserved; resubmission does not overwrite revision history.

## Change Request
`PENDING -> ACCEPTED|REJECTED|CANCELLED`.

Only the other project participant can accept/reject. Accepted requests create agreement history before changing scope/amount/deadline.

## Dispute
`OPEN -> UNDER_REVIEW -> RESOLVED|REJECTED|CLOSED`.

Admin resolution is audited. A project remains blocked while another dispute is `OPEN` or `UNDER_REVIEW`.
