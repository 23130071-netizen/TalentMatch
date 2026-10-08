-- TalentMatch initial migration generated from schema.prisma
-- Prisma target: 6.19.0

CREATE TYPE "Role" AS ENUM ('CLIENT', 'FREELANCER', 'ADMIN');

CREATE TYPE "UserStatus" AS ENUM ('ACTIVE', 'SUSPENDED', 'DEACTIVATED');

CREATE TYPE "AvailabilityStatus" AS ENUM ('AVAILABLE', 'LIMITED', 'UNAVAILABLE');

CREATE TYPE "ExperienceLevel" AS ENUM ('ENTRY', 'INTERMEDIATE', 'EXPERT');

CREATE TYPE "BudgetType" AS ENUM ('FIXED', 'HOURLY');

CREATE TYPE "JobStatus" AS ENUM ('DRAFT', 'OPEN', 'IN_REVIEW', 'NEGOTIATING', 'FILLED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'CLOSED');

CREATE TYPE "ApplicationStatus" AS ENUM ('APPLIED', 'SHORTLISTED', 'NEGOTIATING', 'SELECTED', 'REJECTED', 'WITHDRAWN');

CREATE TYPE "ProposalStatus" AS ENUM ('DRAFT', 'SUBMITTED', 'UPDATED', 'WITHDRAWN');

CREATE TYPE "QuotationStatus" AS ENUM ('DRAFT', 'SUBMITTED', 'UPDATED', 'ACCEPTED', 'REJECTED', 'WITHDRAWN');

CREATE TYPE "InvitationStatus" AS ENUM ('PENDING', 'ACCEPTED', 'DECLINED', 'EXPIRED', 'CANCELLED', 'COMPLETED');

CREATE TYPE "AgreementStatus" AS ENUM ('DRAFT', 'PENDING_CLIENT_CONFIRMATION', 'PENDING_FREELANCER_CONFIRMATION', 'PENDING_PAYMENT', 'ACTIVE', 'COMPLETED', 'CANCELLED', 'DISPUTED');

CREATE TYPE "ProjectStatus" AS ENUM ('PENDING_PAYMENT', 'ACTIVE', 'ON_HOLD', 'COMPLETED', 'CANCELLED', 'DISPUTED');

CREATE TYPE "MilestoneStatus" AS ENUM ('PENDING', 'IN_PROGRESS', 'SUBMITTED', 'IN_REVIEW', 'REVISION_REQUESTED', 'RESUBMITTED', 'ACCEPTED', 'COMPLETED', 'CANCELLED');

CREATE TYPE "DeliverableStatus" AS ENUM ('SUBMITTED', 'IN_REVIEW', 'REVISION_REQUESTED', 'RESUBMITTED', 'ACCEPTED');

CREATE TYPE "RevisionStatus" AS ENUM ('OPEN', 'ACKNOWLEDGED', 'RESUBMITTED', 'RESOLVED', 'CANCELLED');

CREATE TYPE "ChangeRequestStatus" AS ENUM ('PENDING', 'ACCEPTED', 'REJECTED', 'CANCELLED');

CREATE TYPE "PaymentStatus" AS ENUM ('PENDING', 'HELD', 'RELEASED', 'REFUNDED', 'FAILED', 'CANCELLED');

CREATE TYPE "DisputeStatus" AS ENUM ('OPEN', 'UNDER_REVIEW', 'RESOLVED', 'REJECTED', 'CLOSED');

CREATE TYPE "ReportStatus" AS ENUM ('OPEN', 'UNDER_REVIEW', 'RESOLVED', 'REJECTED', 'CLOSED');

CREATE TYPE "NotificationType" AS ENUM ('APPLICATION', 'INVITATION', 'PROPOSAL', 'QUOTATION', 'SHORTLIST', 'SELECTION', 'AGREEMENT', 'PAYMENT', 'PROJECT', 'MILESTONE', 'DELIVERABLE', 'REVISION', 'REVIEW', 'MESSAGE', 'DISPUTE', 'SYSTEM');

CREATE TYPE "FileVisibility" AS ENUM ('PUBLIC', 'OWNER_ONLY', 'PROJECT_PARTICIPANTS');

CREATE TABLE "User" (
  "id" TEXT NOT NULL,
  "email" TEXT NOT NULL,
  "passwordHash" TEXT NOT NULL,
  "role" "Role" NOT NULL,
  "fullName" TEXT NOT NULL,
  "avatarUrl" TEXT,
  "bio" TEXT,
  "location" TEXT,
  "timezone" TEXT,
  "phone" TEXT,
  "status" "UserStatus" NOT NULL DEFAULT 'ACTIVE',
  "lastLoginAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "FreelancerProfile" (
  "id" TEXT NOT NULL,
  "userId" TEXT NOT NULL,
  "headline" TEXT,
  "professionalTitle" TEXT,
  "summary" TEXT,
  "experienceYears" INTEGER NOT NULL DEFAULT 0,
  "education" JSONB,
  "certifications" JSONB,
  "languages" JSONB,
  "hourlyRate" DECIMAL(12,2),
  "availability" "AvailabilityStatus" NOT NULL DEFAULT 'AVAILABLE',
  "talentCredit" INTEGER NOT NULL DEFAULT 500,
  "rating" DOUBLE PRECISION NOT NULL DEFAULT 0,
  "reviewCount" INTEGER NOT NULL DEFAULT 0,
  "completedProjects" INTEGER NOT NULL DEFAULT 0,
  "onTimeRate" DOUBLE PRECISION NOT NULL DEFAULT 100,
  "profileCompletion" INTEGER NOT NULL DEFAULT 0,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "FreelancerProfile_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "ClientProfile" (
  "id" TEXT NOT NULL,
  "userId" TEXT NOT NULL,
  "companyName" TEXT,
  "companyLogoUrl" TEXT,
  "companyDescription" TEXT,
  "industry" TEXT,
  "website" TEXT,
  "companySize" TEXT,
  "foundedYear" INTEGER,
  "contactInfo" TEXT,
  "verificationStatus" TEXT NOT NULL DEFAULT 'UNVERIFIED',
  "rating" DOUBLE PRECISION NOT NULL DEFAULT 0,
  "reviewCount" INTEGER NOT NULL DEFAULT 0,
  "projectsPosted" INTEGER NOT NULL DEFAULT 0,
  "projectsCompleted" INTEGER NOT NULL DEFAULT 0,
  "totalSpending" DECIMAL(14,2) NOT NULL DEFAULT 0,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "ClientProfile_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Category" (
  "id" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "slug" TEXT NOT NULL,
  "description" TEXT,
  CONSTRAINT "Category_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Skill" (
  "id" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "slug" TEXT NOT NULL,
  CONSTRAINT "Skill_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "FreelancerSkill" (
  "freelancerId" TEXT NOT NULL,
  "skillId" TEXT NOT NULL,
  "level" INTEGER NOT NULL DEFAULT 3,
  CONSTRAINT "FreelancerSkill_pkey" PRIMARY KEY ("freelancerId", "skillId")
);

CREATE TABLE "FreelancerCategory" (
  "freelancerId" TEXT NOT NULL,
  "categoryId" TEXT NOT NULL,
  CONSTRAINT "FreelancerCategory_pkey" PRIMARY KEY ("freelancerId", "categoryId")
);

CREATE TABLE "FreelancerService" (
  "id" TEXT NOT NULL,
  "freelancerId" TEXT NOT NULL,
  "categoryId" TEXT,
  "title" TEXT NOT NULL,
  "description" TEXT NOT NULL,
  "startingPrice" DECIMAL(12,2),
  CONSTRAINT "FreelancerService_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Cv" (
  "id" TEXT NOT NULL,
  "freelancerId" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "professionalSummary" TEXT,
  "workExperience" JSONB,
  "education" JSONB,
  "skillsText" TEXT,
  "certifications" JSONB,
  "languages" JSONB,
  "referencesText" TEXT,
  "fileUrl" TEXT,
  "isDefault" BOOLEAN NOT NULL DEFAULT false,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "Cv_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Portfolio" (
  "id" TEXT NOT NULL,
  "freelancerId" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "description" TEXT NOT NULL,
  "role" TEXT,
  "technologies" TEXT[] NOT NULL,
  "mediaUrls" TEXT[] NOT NULL,
  "externalUrl" TEXT,
  "completedAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "Portfolio_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Job" (
  "id" TEXT NOT NULL,
  "clientId" TEXT NOT NULL,
  "categoryId" TEXT,
  "title" TEXT NOT NULL,
  "description" TEXT NOT NULL,
  "experienceLevel" "ExperienceLevel" NOT NULL DEFAULT 'INTERMEDIATE',
  "budgetType" "BudgetType" NOT NULL DEFAULT 'FIXED',
  "budgetMin" DECIMAL(12,2),
  "budgetMax" DECIMAL(12,2),
  "hourlyRateMin" DECIMAL(10,2),
  "hourlyRateMax" DECIMAL(10,2),
  "currency" TEXT NOT NULL DEFAULT 'VND',
  "deadline" TIMESTAMP(3),
  "deliverables" TEXT,
  "revisionRequirements" TEXT,
  "preferredFreelancerLevel" TEXT,
  "location" TEXT,
  "isRemote" BOOLEAN NOT NULL DEFAULT true,
  "visibility" TEXT NOT NULL DEFAULT 'PUBLIC',
  "maxHires" INTEGER NOT NULL DEFAULT 1,
  "status" "JobStatus" NOT NULL DEFAULT 'DRAFT',
  "publishedAt" TIMESTAMP(3),
  "closedAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "Job_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "JobSkill" (
  "jobId" TEXT NOT NULL,
  "skillId" TEXT NOT NULL,
  "required" BOOLEAN NOT NULL DEFAULT true,
  CONSTRAINT "JobSkill_pkey" PRIMARY KEY ("jobId", "skillId")
);

CREATE TABLE "ScreeningQuestion" (
  "id" TEXT NOT NULL,
  "jobId" TEXT NOT NULL,
  "question" TEXT NOT NULL,
  "required" BOOLEAN NOT NULL DEFAULT false,
  CONSTRAINT "ScreeningQuestion_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "SavedJob" (
  "userId" TEXT NOT NULL,
  "jobId" TEXT NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "SavedJob_pkey" PRIMARY KEY ("userId", "jobId")
);

CREATE TABLE "SavedFreelancer" (
  "clientId" TEXT NOT NULL,
  "freelancerId" TEXT NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "SavedFreelancer_pkey" PRIMARY KEY ("clientId", "freelancerId")
);

CREATE TABLE "Application" (
  "id" TEXT NOT NULL,
  "jobId" TEXT NOT NULL,
  "freelancerId" TEXT NOT NULL,
  "cvId" TEXT,
  "status" "ApplicationStatus" NOT NULL DEFAULT 'APPLIED',
  "source" TEXT NOT NULL DEFAULT 'DIRECT',
  "screeningAnswers" JSONB,
  "appliedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "Application_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "ApplicationStatusHistory" (
  "id" TEXT NOT NULL,
  "applicationId" TEXT NOT NULL,
  "fromStatus" "ApplicationStatus",
  "toStatus" "ApplicationStatus" NOT NULL,
  "reason" TEXT,
  "changedById" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "ApplicationStatusHistory_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Proposal" (
  "id" TEXT NOT NULL,
  "applicationId" TEXT NOT NULL,
  "coverLetter" TEXT NOT NULL,
  "approach" TEXT,
  "estimatedTimeline" TEXT,
  "relevantExperience" TEXT,
  "proposedTerms" TEXT,
  "attachmentUrls" TEXT[] NOT NULL,
  "status" "ProposalStatus" NOT NULL DEFAULT 'SUBMITTED',
  "version" INTEGER NOT NULL DEFAULT 1,
  "submittedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "Proposal_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "ProposalVersion" (
  "id" TEXT NOT NULL,
  "proposalId" TEXT NOT NULL,
  "version" INTEGER NOT NULL,
  "snapshot" JSONB NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "ProposalVersion_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Quotation" (
  "id" TEXT NOT NULL,
  "applicationId" TEXT NOT NULL,
  "amount" DECIMAL(12,2) NOT NULL,
  "currency" TEXT NOT NULL DEFAULT 'VND',
  "pricingType" "BudgetType" NOT NULL DEFAULT 'FIXED',
  "estimatedDays" INTEGER NOT NULL,
  "scope" TEXT NOT NULL,
  "deliverables" TEXT NOT NULL,
  "revisionTerms" TEXT,
  "notes" TEXT,
  "status" "QuotationStatus" NOT NULL DEFAULT 'SUBMITTED',
  "version" INTEGER NOT NULL DEFAULT 1,
  "submittedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "Quotation_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "QuotationVersion" (
  "id" TEXT NOT NULL,
  "quotationId" TEXT NOT NULL,
  "version" INTEGER NOT NULL,
  "snapshot" JSONB NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "QuotationVersion_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Invitation" (
  "id" TEXT NOT NULL,
  "jobId" TEXT NOT NULL,
  "clientId" TEXT NOT NULL,
  "freelancerId" TEXT NOT NULL,
  "applicationId" TEXT,
  "message" TEXT,
  "status" "InvitationStatus" NOT NULL DEFAULT 'PENDING',
  "expiresAt" TIMESTAMP(3),
  "respondedAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "Invitation_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Shortlist" (
  "id" TEXT NOT NULL,
  "clientId" TEXT NOT NULL,
  "freelancerId" TEXT NOT NULL,
  "jobId" TEXT,
  "applicationId" TEXT,
  "note" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "Shortlist_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Negotiation" (
  "id" TEXT NOT NULL,
  "applicationId" TEXT NOT NULL,
  "requestedById" TEXT NOT NULL,
  "message" TEXT NOT NULL,
  "proposedAmount" DECIMAL(12,2),
  "proposedDays" INTEGER,
  "status" TEXT NOT NULL DEFAULT 'OPEN',
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "resolvedAt" TIMESTAMP(3),
  CONSTRAINT "Negotiation_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Agreement" (
  "id" TEXT NOT NULL,
  "jobId" TEXT NOT NULL,
  "clientId" TEXT NOT NULL,
  "freelancerId" TEXT NOT NULL,
  "applicationId" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "scope" TEXT NOT NULL,
  "deliverables" TEXT NOT NULL,
  "amount" DECIMAL(12,2) NOT NULL,
  "currency" TEXT NOT NULL DEFAULT 'VND',
  "paymentTerms" TEXT NOT NULL,
  "revisionTerms" TEXT,
  "cancellationTerms" TEXT,
  "ownershipTerms" TEXT,
  "confidentialityTerms" TEXT,
  "startDate" TIMESTAMP(3),
  "deadline" TIMESTAMP(3),
  "status" "AgreementStatus" NOT NULL DEFAULT 'PENDING_CLIENT_CONFIRMATION',
  "clientConfirmedAt" TIMESTAMP(3),
  "freelancerConfirmedAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "Agreement_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "AgreementConfirmation" (
  "id" TEXT NOT NULL,
  "agreementId" TEXT NOT NULL,
  "userId" TEXT NOT NULL,
  "role" "Role" NOT NULL,
  "confirmedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "AgreementConfirmation_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "AgreementVersion" (
  "id" TEXT NOT NULL,
  "agreementId" TEXT NOT NULL,
  "version" INTEGER NOT NULL,
  "snapshot" JSONB NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "AgreementVersion_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Project" (
  "id" TEXT NOT NULL,
  "agreementId" TEXT NOT NULL,
  "jobId" TEXT NOT NULL,
  "clientId" TEXT NOT NULL,
  "freelancerId" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "status" "ProjectStatus" NOT NULL DEFAULT 'PENDING_PAYMENT',
  "progress" INTEGER NOT NULL DEFAULT 0,
  "startDate" TIMESTAMP(3),
  "deadline" TIMESTAMP(3),
  "completedAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "Project_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Milestone" (
  "id" TEXT NOT NULL,
  "projectId" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "description" TEXT NOT NULL,
  "amount" DECIMAL(12,2) NOT NULL,
  "dueDate" TIMESTAMP(3),
  "orderIndex" INTEGER NOT NULL,
  "status" "MilestoneStatus" NOT NULL DEFAULT 'PENDING',
  "startedAt" TIMESTAMP(3),
  "acceptedAt" TIMESTAMP(3),
  "completedAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "Milestone_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Deliverable" (
  "id" TEXT NOT NULL,
  "milestoneId" TEXT NOT NULL,
  "submittedById" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "description" TEXT NOT NULL,
  "fileUrls" TEXT[] NOT NULL,
  "links" TEXT[] NOT NULL,
  "status" "DeliverableStatus" NOT NULL DEFAULT 'SUBMITTED',
  "submittedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "Deliverable_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "RevisionRequest" (
  "id" TEXT NOT NULL,
  "milestoneId" TEXT NOT NULL,
  "deliverableId" TEXT NOT NULL,
  "requestedById" TEXT NOT NULL,
  "freelancerId" TEXT NOT NULL,
  "request" TEXT NOT NULL,
  "reason" TEXT,
  "response" TEXT,
  "status" "RevisionStatus" NOT NULL DEFAULT 'OPEN',
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "acknowledgedAt" TIMESTAMP(3),
  "resolvedAt" TIMESTAMP(3),
  CONSTRAINT "RevisionRequest_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "ChangeRequest" (
  "id" TEXT NOT NULL,
  "projectId" TEXT NOT NULL,
  "agreementId" TEXT NOT NULL,
  "requestedById" TEXT NOT NULL,
  "proposedScope" TEXT,
  "proposedAmount" DECIMAL(12,2),
  "proposedDeadline" TIMESTAMP(3),
  "reason" TEXT NOT NULL,
  "status" "ChangeRequestStatus" NOT NULL DEFAULT 'PENDING',
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "resolvedAt" TIMESTAMP(3),
  CONSTRAINT "ChangeRequest_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Payment" (
  "id" TEXT NOT NULL,
  "projectId" TEXT NOT NULL,
  "milestoneId" TEXT,
  "payerId" TEXT NOT NULL,
  "payeeId" TEXT NOT NULL,
  "amount" DECIMAL(12,2) NOT NULL,
  "currency" TEXT NOT NULL DEFAULT 'VND',
  "platformFee" DECIMAL(12,2) NOT NULL DEFAULT 0,
  "netAmount" DECIMAL(12,2) NOT NULL,
  "status" "PaymentStatus" NOT NULL DEFAULT 'PENDING',
  "transactionCode" TEXT,
  "fundedAt" TIMESTAMP(3),
  "releasedAt" TIMESTAMP(3),
  "refundedAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "Payment_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "PaymentTransaction" (
  "id" TEXT NOT NULL,
  "paymentId" TEXT NOT NULL,
  "type" TEXT NOT NULL,
  "fromStatus" "PaymentStatus",
  "toStatus" "PaymentStatus" NOT NULL,
  "amount" DECIMAL(12,2) NOT NULL,
  "reference" TEXT,
  "metadata" JSONB,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "PaymentTransaction_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Review" (
  "id" TEXT NOT NULL,
  "projectId" TEXT NOT NULL,
  "reviewerId" TEXT NOT NULL,
  "revieweeId" TEXT NOT NULL,
  "rating" INTEGER NOT NULL,
  "comment" TEXT NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "Review_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "TalentCreditTransaction" (
  "id" TEXT NOT NULL,
  "userId" TEXT NOT NULL,
  "projectId" TEXT,
  "changeAmount" INTEGER NOT NULL,
  "reason" TEXT NOT NULL,
  "balanceAfter" INTEGER NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "TalentCreditTransaction_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Notification" (
  "id" TEXT NOT NULL,
  "userId" TEXT NOT NULL,
  "type" "NotificationType" NOT NULL,
  "title" TEXT NOT NULL,
  "content" TEXT NOT NULL,
  "deepLink" TEXT,
  "isRead" BOOLEAN NOT NULL DEFAULT false,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "Notification_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Conversation" (
  "id" TEXT NOT NULL,
  "projectId" TEXT,
  "jobId" TEXT,
  "title" TEXT,
  "lastMessageAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "Conversation_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "ConversationParticipant" (
  "conversationId" TEXT NOT NULL,
  "userId" TEXT NOT NULL,
  "joinedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "lastReadAt" TIMESTAMP(3),
  CONSTRAINT "ConversationParticipant_pkey" PRIMARY KEY ("conversationId", "userId")
);

CREATE TABLE "Message" (
  "id" TEXT NOT NULL,
  "conversationId" TEXT NOT NULL,
  "senderId" TEXT NOT NULL,
  "content" TEXT NOT NULL,
  "attachmentUrls" TEXT[] NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "editedAt" TIMESTAMP(3),
  CONSTRAINT "Message_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Dispute" (
  "id" TEXT NOT NULL,
  "projectId" TEXT NOT NULL,
  "reportedById" TEXT NOT NULL,
  "reason" TEXT NOT NULL,
  "description" TEXT NOT NULL,
  "evidenceUrls" TEXT[] NOT NULL,
  "status" "DisputeStatus" NOT NULL DEFAULT 'OPEN',
  "resolution" TEXT,
  "adminNote" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "resolvedAt" TIMESTAMP(3),
  CONSTRAINT "Dispute_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Report" (
  "id" TEXT NOT NULL,
  "reporterId" TEXT NOT NULL,
  "targetUserId" TEXT,
  "jobId" TEXT,
  "projectId" TEXT,
  "reviewId" TEXT,
  "messageId" TEXT,
  "type" TEXT NOT NULL,
  "reason" TEXT NOT NULL,
  "description" TEXT,
  "status" "ReportStatus" NOT NULL DEFAULT 'OPEN',
  "resolution" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "resolvedAt" TIMESTAMP(3),
  CONSTRAINT "Report_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "FileAsset" (
  "id" TEXT NOT NULL,
  "ownerId" TEXT NOT NULL,
  "projectId" TEXT,
  "category" TEXT NOT NULL,
  "originalName" TEXT NOT NULL,
  "storedName" TEXT NOT NULL,
  "mimeType" TEXT NOT NULL,
  "sizeBytes" INTEGER NOT NULL,
  "path" TEXT NOT NULL,
  "visibility" "FileVisibility" NOT NULL DEFAULT 'OWNER_ONLY',
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "FileAsset_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "ProjectActivity" (
  "id" TEXT NOT NULL,
  "projectId" TEXT NOT NULL,
  "actorId" TEXT,
  "type" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "detail" TEXT,
  "metadata" JSONB,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "ProjectActivity_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "JobStatusHistory" (
  "id" TEXT NOT NULL,
  "jobId" TEXT NOT NULL,
  "fromStatus" "JobStatus",
  "toStatus" "JobStatus" NOT NULL,
  "changedById" TEXT,
  "reason" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "JobStatusHistory_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "AdminAudit" (
  "id" TEXT NOT NULL,
  "adminId" TEXT NOT NULL,
  "action" TEXT NOT NULL,
  "entityType" TEXT NOT NULL,
  "entityId" TEXT NOT NULL,
  "detail" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "AdminAudit_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "JobQuestion" (
  "id" TEXT NOT NULL,
  "jobId" TEXT NOT NULL,
  "userId" TEXT NOT NULL,
  "question" TEXT NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "JobQuestion_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "JobQuestionAnswer" (
  "id" TEXT NOT NULL,
  "questionId" TEXT NOT NULL,
  "userId" TEXT NOT NULL,
  "answer" TEXT NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "JobQuestionAnswer_pkey" PRIMARY KEY ("id")
);


-- Indexes
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");
CREATE INDEX "User_role_status_idx" ON "User"("role", "status");
CREATE INDEX "User_createdAt_idx" ON "User"("createdAt");
CREATE UNIQUE INDEX "FreelancerProfile_userId_key" ON "FreelancerProfile"("userId");
CREATE INDEX "FreelancerProfile_availability_rating_idx" ON "FreelancerProfile"("availability", "rating");
CREATE INDEX "FreelancerProfile_talentCredit_idx" ON "FreelancerProfile"("talentCredit");
CREATE UNIQUE INDEX "ClientProfile_userId_key" ON "ClientProfile"("userId");
CREATE UNIQUE INDEX "Category_name_key" ON "Category"("name");
CREATE UNIQUE INDEX "Category_slug_key" ON "Category"("slug");
CREATE UNIQUE INDEX "Skill_name_key" ON "Skill"("name");
CREATE UNIQUE INDEX "Skill_slug_key" ON "Skill"("slug");
CREATE INDEX "FreelancerSkill_skillId_idx" ON "FreelancerSkill"("skillId");
CREATE INDEX "Job_status_publishedAt_idx" ON "Job"("status", "publishedAt");
CREATE INDEX "Job_categoryId_status_idx" ON "Job"("categoryId", "status");
CREATE INDEX "Job_clientId_idx" ON "Job"("clientId");
CREATE INDEX "JobSkill_skillId_idx" ON "JobSkill"("skillId");
CREATE UNIQUE INDEX "Application_jobId_freelancerId_key" ON "Application"("jobId", "freelancerId");
CREATE INDEX "Application_jobId_status_idx" ON "Application"("jobId", "status");
CREATE INDEX "Application_freelancerId_status_idx" ON "Application"("freelancerId", "status");
CREATE INDEX "ApplicationStatusHistory_applicationId_createdAt_idx" ON "ApplicationStatusHistory"("applicationId", "createdAt");
CREATE UNIQUE INDEX "Proposal_applicationId_key" ON "Proposal"("applicationId");
CREATE UNIQUE INDEX "ProposalVersion_proposalId_version_key" ON "ProposalVersion"("proposalId", "version");
CREATE UNIQUE INDEX "Quotation_applicationId_key" ON "Quotation"("applicationId");
CREATE UNIQUE INDEX "QuotationVersion_quotationId_version_key" ON "QuotationVersion"("quotationId", "version");
CREATE UNIQUE INDEX "Invitation_applicationId_key" ON "Invitation"("applicationId");
CREATE UNIQUE INDEX "Invitation_jobId_freelancerId_key" ON "Invitation"("jobId", "freelancerId");
CREATE INDEX "Invitation_freelancerId_status_idx" ON "Invitation"("freelancerId", "status");
CREATE UNIQUE INDEX "Shortlist_clientId_freelancerId_jobId_key" ON "Shortlist"("clientId", "freelancerId", "jobId");
CREATE INDEX "Negotiation_applicationId_createdAt_idx" ON "Negotiation"("applicationId", "createdAt");
CREATE UNIQUE INDEX "Agreement_applicationId_key" ON "Agreement"("applicationId");
CREATE UNIQUE INDEX "AgreementConfirmation_agreementId_userId_key" ON "AgreementConfirmation"("agreementId", "userId");
CREATE UNIQUE INDEX "AgreementVersion_agreementId_version_key" ON "AgreementVersion"("agreementId", "version");
CREATE UNIQUE INDEX "Project_agreementId_key" ON "Project"("agreementId");
CREATE INDEX "Project_clientId_status_idx" ON "Project"("clientId", "status");
CREATE INDEX "Project_freelancerId_status_idx" ON "Project"("freelancerId", "status");
CREATE UNIQUE INDEX "Milestone_projectId_orderIndex_key" ON "Milestone"("projectId", "orderIndex");
CREATE INDEX "Milestone_projectId_status_idx" ON "Milestone"("projectId", "status");
CREATE UNIQUE INDEX "Payment_transactionCode_key" ON "Payment"("transactionCode");
CREATE INDEX "Payment_projectId_status_idx" ON "Payment"("projectId", "status");
CREATE UNIQUE INDEX "Review_projectId_reviewerId_revieweeId_key" ON "Review"("projectId", "reviewerId", "revieweeId");
CREATE INDEX "Review_revieweeId_createdAt_idx" ON "Review"("revieweeId", "createdAt");
CREATE INDEX "TalentCreditTransaction_userId_createdAt_idx" ON "TalentCreditTransaction"("userId", "createdAt");
CREATE INDEX "Notification_userId_isRead_createdAt_idx" ON "Notification"("userId", "isRead", "createdAt");
CREATE INDEX "Conversation_projectId_idx" ON "Conversation"("projectId");
CREATE INDEX "ConversationParticipant_userId_idx" ON "ConversationParticipant"("userId");
CREATE INDEX "Message_conversationId_createdAt_idx" ON "Message"("conversationId", "createdAt");
CREATE INDEX "Dispute_status_createdAt_idx" ON "Dispute"("status", "createdAt");
CREATE INDEX "FileAsset_ownerId_category_idx" ON "FileAsset"("ownerId", "category");
CREATE INDEX "ProjectActivity_projectId_createdAt_idx" ON "ProjectActivity"("projectId", "createdAt");
CREATE INDEX "JobStatusHistory_jobId_createdAt_idx" ON "JobStatusHistory"("jobId", "createdAt");
CREATE INDEX "AdminAudit_adminId_createdAt_idx" ON "AdminAudit"("adminId", "createdAt");


-- Foreign keys
ALTER TABLE "FreelancerProfile" ADD CONSTRAINT "FreelancerProfile_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ClientProfile" ADD CONSTRAINT "ClientProfile_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "FreelancerSkill" ADD CONSTRAINT "FreelancerSkill_freelancerId_fkey" FOREIGN KEY ("freelancerId") REFERENCES "FreelancerProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "FreelancerSkill" ADD CONSTRAINT "FreelancerSkill_skillId_fkey" FOREIGN KEY ("skillId") REFERENCES "Skill"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "FreelancerCategory" ADD CONSTRAINT "FreelancerCategory_freelancerId_fkey" FOREIGN KEY ("freelancerId") REFERENCES "FreelancerProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "FreelancerCategory" ADD CONSTRAINT "FreelancerCategory_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "Category"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "FreelancerService" ADD CONSTRAINT "FreelancerService_freelancerId_fkey" FOREIGN KEY ("freelancerId") REFERENCES "FreelancerProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "FreelancerService" ADD CONSTRAINT "FreelancerService_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "Category"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Cv" ADD CONSTRAINT "Cv_freelancerId_fkey" FOREIGN KEY ("freelancerId") REFERENCES "FreelancerProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Portfolio" ADD CONSTRAINT "Portfolio_freelancerId_fkey" FOREIGN KEY ("freelancerId") REFERENCES "FreelancerProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Job" ADD CONSTRAINT "Job_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Job" ADD CONSTRAINT "Job_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "Category"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "JobSkill" ADD CONSTRAINT "JobSkill_jobId_fkey" FOREIGN KEY ("jobId") REFERENCES "Job"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "JobSkill" ADD CONSTRAINT "JobSkill_skillId_fkey" FOREIGN KEY ("skillId") REFERENCES "Skill"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ScreeningQuestion" ADD CONSTRAINT "ScreeningQuestion_jobId_fkey" FOREIGN KEY ("jobId") REFERENCES "Job"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "SavedJob" ADD CONSTRAINT "SavedJob_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "SavedJob" ADD CONSTRAINT "SavedJob_jobId_fkey" FOREIGN KEY ("jobId") REFERENCES "Job"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "SavedFreelancer" ADD CONSTRAINT "SavedFreelancer_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "SavedFreelancer" ADD CONSTRAINT "SavedFreelancer_freelancerId_fkey" FOREIGN KEY ("freelancerId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Application" ADD CONSTRAINT "Application_jobId_fkey" FOREIGN KEY ("jobId") REFERENCES "Job"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Application" ADD CONSTRAINT "Application_freelancerId_fkey" FOREIGN KEY ("freelancerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Application" ADD CONSTRAINT "Application_cvId_fkey" FOREIGN KEY ("cvId") REFERENCES "Cv"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "ApplicationStatusHistory" ADD CONSTRAINT "ApplicationStatusHistory_applicationId_fkey" FOREIGN KEY ("applicationId") REFERENCES "Application"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ApplicationStatusHistory" ADD CONSTRAINT "ApplicationStatusHistory_changedById_fkey" FOREIGN KEY ("changedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Proposal" ADD CONSTRAINT "Proposal_applicationId_fkey" FOREIGN KEY ("applicationId") REFERENCES "Application"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ProposalVersion" ADD CONSTRAINT "ProposalVersion_proposalId_fkey" FOREIGN KEY ("proposalId") REFERENCES "Proposal"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Quotation" ADD CONSTRAINT "Quotation_applicationId_fkey" FOREIGN KEY ("applicationId") REFERENCES "Application"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "QuotationVersion" ADD CONSTRAINT "QuotationVersion_quotationId_fkey" FOREIGN KEY ("quotationId") REFERENCES "Quotation"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Invitation" ADD CONSTRAINT "Invitation_jobId_fkey" FOREIGN KEY ("jobId") REFERENCES "Job"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Invitation" ADD CONSTRAINT "Invitation_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Invitation" ADD CONSTRAINT "Invitation_freelancerId_fkey" FOREIGN KEY ("freelancerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Invitation" ADD CONSTRAINT "Invitation_applicationId_fkey" FOREIGN KEY ("applicationId") REFERENCES "Application"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Shortlist" ADD CONSTRAINT "Shortlist_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Shortlist" ADD CONSTRAINT "Shortlist_freelancerId_fkey" FOREIGN KEY ("freelancerId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Shortlist" ADD CONSTRAINT "Shortlist_jobId_fkey" FOREIGN KEY ("jobId") REFERENCES "Job"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Shortlist" ADD CONSTRAINT "Shortlist_applicationId_fkey" FOREIGN KEY ("applicationId") REFERENCES "Application"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Negotiation" ADD CONSTRAINT "Negotiation_applicationId_fkey" FOREIGN KEY ("applicationId") REFERENCES "Application"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Negotiation" ADD CONSTRAINT "Negotiation_requestedById_fkey" FOREIGN KEY ("requestedById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Agreement" ADD CONSTRAINT "Agreement_jobId_fkey" FOREIGN KEY ("jobId") REFERENCES "Job"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Agreement" ADD CONSTRAINT "Agreement_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Agreement" ADD CONSTRAINT "Agreement_freelancerId_fkey" FOREIGN KEY ("freelancerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Agreement" ADD CONSTRAINT "Agreement_applicationId_fkey" FOREIGN KEY ("applicationId") REFERENCES "Application"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "AgreementConfirmation" ADD CONSTRAINT "AgreementConfirmation_agreementId_fkey" FOREIGN KEY ("agreementId") REFERENCES "Agreement"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "AgreementConfirmation" ADD CONSTRAINT "AgreementConfirmation_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "AgreementVersion" ADD CONSTRAINT "AgreementVersion_agreementId_fkey" FOREIGN KEY ("agreementId") REFERENCES "Agreement"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Project" ADD CONSTRAINT "Project_agreementId_fkey" FOREIGN KEY ("agreementId") REFERENCES "Agreement"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Project" ADD CONSTRAINT "Project_jobId_fkey" FOREIGN KEY ("jobId") REFERENCES "Job"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Project" ADD CONSTRAINT "Project_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Project" ADD CONSTRAINT "Project_freelancerId_fkey" FOREIGN KEY ("freelancerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Milestone" ADD CONSTRAINT "Milestone_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Deliverable" ADD CONSTRAINT "Deliverable_milestoneId_fkey" FOREIGN KEY ("milestoneId") REFERENCES "Milestone"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Deliverable" ADD CONSTRAINT "Deliverable_submittedById_fkey" FOREIGN KEY ("submittedById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "RevisionRequest" ADD CONSTRAINT "RevisionRequest_milestoneId_fkey" FOREIGN KEY ("milestoneId") REFERENCES "Milestone"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "RevisionRequest" ADD CONSTRAINT "RevisionRequest_deliverableId_fkey" FOREIGN KEY ("deliverableId") REFERENCES "Deliverable"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "RevisionRequest" ADD CONSTRAINT "RevisionRequest_requestedById_fkey" FOREIGN KEY ("requestedById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "RevisionRequest" ADD CONSTRAINT "RevisionRequest_freelancerId_fkey" FOREIGN KEY ("freelancerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "ChangeRequest" ADD CONSTRAINT "ChangeRequest_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ChangeRequest" ADD CONSTRAINT "ChangeRequest_agreementId_fkey" FOREIGN KEY ("agreementId") REFERENCES "Agreement"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ChangeRequest" ADD CONSTRAINT "ChangeRequest_requestedById_fkey" FOREIGN KEY ("requestedById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_milestoneId_fkey" FOREIGN KEY ("milestoneId") REFERENCES "Milestone"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_payerId_fkey" FOREIGN KEY ("payerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_payeeId_fkey" FOREIGN KEY ("payeeId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "PaymentTransaction" ADD CONSTRAINT "PaymentTransaction_paymentId_fkey" FOREIGN KEY ("paymentId") REFERENCES "Payment"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Review" ADD CONSTRAINT "Review_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Review" ADD CONSTRAINT "Review_reviewerId_fkey" FOREIGN KEY ("reviewerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Review" ADD CONSTRAINT "Review_revieweeId_fkey" FOREIGN KEY ("revieweeId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "TalentCreditTransaction" ADD CONSTRAINT "TalentCreditTransaction_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "TalentCreditTransaction" ADD CONSTRAINT "TalentCreditTransaction_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Notification" ADD CONSTRAINT "Notification_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Conversation" ADD CONSTRAINT "Conversation_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Conversation" ADD CONSTRAINT "Conversation_jobId_fkey" FOREIGN KEY ("jobId") REFERENCES "Job"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "ConversationParticipant" ADD CONSTRAINT "ConversationParticipant_conversationId_fkey" FOREIGN KEY ("conversationId") REFERENCES "Conversation"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ConversationParticipant" ADD CONSTRAINT "ConversationParticipant_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Message" ADD CONSTRAINT "Message_conversationId_fkey" FOREIGN KEY ("conversationId") REFERENCES "Conversation"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Message" ADD CONSTRAINT "Message_senderId_fkey" FOREIGN KEY ("senderId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Dispute" ADD CONSTRAINT "Dispute_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Dispute" ADD CONSTRAINT "Dispute_reportedById_fkey" FOREIGN KEY ("reportedById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Report" ADD CONSTRAINT "Report_reporterId_fkey" FOREIGN KEY ("reporterId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Report" ADD CONSTRAINT "Report_targetUserId_fkey" FOREIGN KEY ("targetUserId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Report" ADD CONSTRAINT "Report_jobId_fkey" FOREIGN KEY ("jobId") REFERENCES "Job"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Report" ADD CONSTRAINT "Report_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Report" ADD CONSTRAINT "Report_reviewId_fkey" FOREIGN KEY ("reviewId") REFERENCES "Review"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Report" ADD CONSTRAINT "Report_messageId_fkey" FOREIGN KEY ("messageId") REFERENCES "Message"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "FileAsset" ADD CONSTRAINT "FileAsset_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "FileAsset" ADD CONSTRAINT "FileAsset_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ProjectActivity" ADD CONSTRAINT "ProjectActivity_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ProjectActivity" ADD CONSTRAINT "ProjectActivity_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "JobStatusHistory" ADD CONSTRAINT "JobStatusHistory_jobId_fkey" FOREIGN KEY ("jobId") REFERENCES "Job"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "JobStatusHistory" ADD CONSTRAINT "JobStatusHistory_changedById_fkey" FOREIGN KEY ("changedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "AdminAudit" ADD CONSTRAINT "AdminAudit_adminId_fkey" FOREIGN KEY ("adminId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "JobQuestion" ADD CONSTRAINT "JobQuestion_jobId_fkey" FOREIGN KEY ("jobId") REFERENCES "Job"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "JobQuestion" ADD CONSTRAINT "JobQuestion_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "JobQuestionAnswer" ADD CONSTRAINT "JobQuestionAnswer_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES "JobQuestion"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "JobQuestionAnswer" ADD CONSTRAINT "JobQuestionAnswer_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
