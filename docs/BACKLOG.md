# Development Backlog

**Project:** Nexora  
**Last Updated:** 2026-10-05

---

## Phase Status

| Phase | Name | Status |
|---|---|---|
| Phase 0 | Product Specification | 🟡 In Progress |
| Phase 1 | Engineering Foundation | 🟡 In Progress |
| Phase 2 | Identity & Security | ⬜ Not Started |
| Phase 3 | Platform Core | ⬜ Not Started |
| Phase 4 | Admin Foundation | ⬜ Not Started |
| Phase 5 | Personal Mode MVP | ⬜ Not Started |
| Phase 6 | Couple Mode MVP | ⬜ Not Started |
| Phase 7 | Couple Communication | ⬜ Not Started |
| Phase 8 | Special Couple Features | ⬜ Not Started |
| Phase 9 | Knowledge Vault | ⬜ Not Started |
| Phase 10 | AI Platform | ⬜ Not Started |
| Phase 11 | News Platform | ⬜ Not Started |
| Phase 12 | Search & Intelligence | ⬜ Not Started |
| Phase 13 | Production Hardening | ⬜ Not Started |

---

## Phase 0 — Product Specification

### Documentation

- [x] SRS stub created
- [x] ARCHITECTURE.md created
- [x] SECURITY.md created
- [x] DEVELOPMENT.md created
- [ ] DATABASE.md — needs full schema design
- [ ] API.md — needs endpoint documentation
- [x] ADR-001: Monorepo structure
- [x] ADR-002: Flutter Web
- [x] ADR-003: Background jobs (Hangfire)
- [x] ADR-004: Admin dashboard (Blazor Server)
- [x] ADR-005: Secrets management (.NET User Secrets)

---

## Phase 1 — Engineering Foundation

### Git & Repository

- [x] Git repository initialized
- [x] `.gitignore` created (covers .NET, Flutter, IDE, secrets)
- [x] `main` branch established
- [ ] `develop` branch created
- [ ] GitHub remote configured
- [ ] GitHub Actions CI workflow created
- [ ] README updated

### Directory Skeleton

- [x] `/docs` directory
- [x] `/docs/DECISIONS` directory
- [x] `/mobile` directory
- [x] `/web` directory
- [x] `/backend` directory structure
- [x] `/admin` directory
- [x] `/database/migrations` directory
- [x] `/tests` directory

### Backend

- [x] `Nexora.Domain` project created
- [x] `Nexora.Application` project created
- [x] `Nexora.Infrastructure` project created
- [x] `Nexora.Api` project created
- [x] `Nexora.UnitTests` project created
- [x] `Nexora.IntegrationTests` project created
- [x] Solution file (`Nexora.slnx`) with all projects
- [x] Project references (Domain ← Application ← Infrastructure ← Api)
- [x] MediatR installed (Application)
- [x] FluentValidation installed (Application)
- [x] EF Core + SQL Server installed (Infrastructure)
- [x] Hangfire installed (Infrastructure)
- [x] Serilog installed (Infrastructure + Api)
- [x] Swashbuckle (Swagger) installed (Api)
- [x] JWT Bearer auth installed (Api)
- [x] `Program.cs` configured (Serilog, CORS, health checks, Swagger, SignalR)
- [x] `GlobalExceptionMiddleware` implemented
- [x] `ValidationBehaviour` (MediatR pipeline) implemented
- [x] `LoggingBehaviour` (MediatR pipeline) implemented
- [x] `IAIProvider` abstraction defined
- [x] `NullAIProvider` (graceful fallback) implemented
- [x] `SystemController` (`/api/system/status`) implemented
- [x] `/health` endpoint configured
- [x] Application `DependencyInjection` extension
- [x] Infrastructure `DependencyInjection` extension
- [x] Common exceptions: `NotFoundException`, `ForbiddenAccessException`, `ValidationException`
- [x] `appsettings.json` — confirm no secrets ✅
- [x] `.NET User Secrets` initialized for Nexora.Api
- [x] First successful `dotnet build`
- [x] First successful `dotnet test`

### Flutter Mobile

- [x] `nexora_mobile` Flutter project scaffolded
- [x] Basic app structure established
- [x] First successful `flutter analyze` & `flutter test`

### Blazor Admin

- [x] `Nexora.Admin` Blazor project scaffolded
- [x] First successful `dotnet build`

### CI

- [x] GitHub Actions `ci.yml` workflow created

---

## Phase 2 — Identity & Security

### Backend

- [x] ASP.NET Core Identity configured
- [x] `ApplicationUser` entity defined
- [x] `RefreshToken` entity with rotation tracking defined
- [x] Database migrations for Identity tables (`InitialIdentityAndRefreshTokens`)
- [x] Registration endpoint (`POST /api/auth/register`)
- [x] Login endpoint (`POST /api/auth/login`)
- [x] Logout endpoint (`POST /api/auth/logout`)
- [x] JWT access token issuance (HMAC-SHA256, claims, roles)
- [x] Refresh token issuance and hashed storage
- [x] Token refresh endpoint (`POST /api/auth/refresh`) with rotation
- [x] Token revocation on logout
- [x] Password hashing & validation verified (PBKDF2 via Identity)
- [x] User profile endpoint (`GET /api/users/me`)
- [x] Authorization policies defined (`AdminOnly`, `UserOrAdmin`)
- [ ] Audit log foundation

### Tests

- [x] Registration — happy path
- [x] Registration — duplicate email
- [x] Login — valid credentials
- [x] Login — invalid credentials (constant-time response)
- [x] Account deactivation check
- [ ] Integration: Token refresh — valid token
- [ ] Integration: Token refresh — expired token
- [ ] Integration: User A cannot access User B's profile
- [ ] Integration: Unauthorized request returns 401
- [ ] Integration: Forbidden request returns 403

### Flutter Mobile

- [x] Auth state management (`AuthProvider`)
- [x] Login screen (`LoginScreen`)
- [x] Registration screen (`RegisterScreen`)
- [x] Token storage (`TokenStorage` using `flutter_secure_storage`)

---

## Phase 3 — Platform Core

- [x] Feature flag registry (`FeatureKeys`)
- [x] Feature flag evaluation service (`IFeatureFlagService` / `FeatureFlagService`)
- [x] Visibility enum (`VisibilityLevel`: `Private`, `Shared`, `PartnerVisible`)
- [x] Audit logging service & EF entity (`IAuditLogService` / `AuditLogService` / `AuditLog`)
- [x] Dynamic feature flag endpoint (`GET /api/features`)
- [x] Admin feature flag toggle endpoint (`PUT /api/admin/features/{name}`)
- [x] Unit tests for FeatureFlagService (`8/8` total backend unit tests passing)

---

## Phase 4 — Admin Foundation

- [x] Blazor Server Admin application structure & navigation (`NavMenu`)
- [x] Admin API integration service (`NexoraApiClient`)
- [x] Admin dashboard home & health overview (`Home.razor`)
- [x] Feature flag management UI with interactive toggles (`Features.razor`)
- [x] User & Couple management view placeholder with privacy boundary notice (`Users.razor`)
- [x] Audit log viewer component (`Audit.razor`)
- [x] Workspace verification (0 build errors, 8/8 unit tests passing, 1/1 integration test passing)

## Phase 5 — Personal Domain Core (Notes & Reminders)

- [x] Note entity with `VisibilityLevel` support (`Private`, `Shared`, `PartnerVisible`)
- [x] Reminder entity with `RecurrenceType` support (`None`, `Daily`, `Weekly`, `Monthly`, `Yearly`)
- [x] CQRS Notes handlers with server-side `OwnerId` enforcement (never trusting client IDs)
- [x] CQRS Reminders handlers with completion toggling and ownership checks
- [x] EF Core configurations & migration (`PersonalDomainNotesAndReminders`)
- [x] `NotesController` & `RemindersController` REST endpoints
- [x] Unit test suite verifying cross-user access denial and tamper resistance (`13/13` backend tests passing)
- [x] Flutter mobile `NotesScreen`, `NoteEditorScreen`, `NotesService`, and `NoteModel`
- [x] Flutter test passing (`1/1` test passing)

## Phase 6 — Couple Domain (Invitation & Relationship System)

- [x] Couple entity with status transitions (`Active`, `Paused`, `Ended`)
- [x] CoupleInvitation entity with cryptographically secure 8-character codes and 48-hour expiration
- [x] Rule enforcement: Strictly one active couple per user max
- [x] Single-use invitation logic with self-pairing prevention and code invalidation
- [x] CQRS commands & queries (`CreateInvitationCommand`, `AcceptInvitationCommand`, `GetCurrentCoupleQuery`)
- [x] EF Core configurations & migration (`CoupleSystemInvitationsAndRelationships`)
- [x] `CouplesController` endpoints (`GET /current`, `POST /invitations`, `POST /invitations/accept`)
- [x] 5 new unit tests verifying invitation generation, expiration, pairing, and abuse protection (`18/18` backend tests passing)
- [x] Flutter mobile `CoupleScreen`, `CouplesService`, and `CoupleModel`
- [x] Flutter widget smoke tests passing (`1/1` test passing)

## Phase 7 — Shared Calendar & Realtime Foundation

- [x] CalendarEvent entity supporting couple-scope and `VisibilityLevel` (`Private`, `Shared`, `PartnerVisible`)
- [x] SignalR hub (`NexoraHub`) mapped to `/hubs/nexora` with authenticated user and couple group messaging
- [x] `IRealtimeNotificationService` abstraction implemented via `SignalRNotificationService`
- [x] `CreateCalendarEventCommand` CQRS handler with couple membership validation and realtime push notifications
- [x] `GetCalendarEventsQuery` CQRS handler with date-range filter and partner visibility boundary enforcement
- [x] EF Core `CalendarEventConfiguration` and migration (`SharedCalendarAndRealtime`)
- [x] `CalendarController` REST endpoints (`GET /api/calendar`, `POST /api/calendar`)
- [x] 3 new unit tests for event creation, realtime broadcast, and partner visibility boundaries (`21/21` backend tests passing)
- [x] Flutter mobile `CalendarScreen`, `CalendarService`, and `CalendarEventModel` with event creation modal

## Phase 8 — Couple Realtime Chat & Media Foundation

- [x] ChatMessage entity with `MessageDeliveryStatus` (`Sent`, `Delivered`, `Read`) and attachment support
- [x] `SendMessageCommand` CQRS handler validating active couple membership and broadcasting `ChatMessageReceived` via SignalR
- [x] `GetChatMessagesQuery` CQRS handler retrieving messages within couple space in chronological order with pagination
- [x] EF Core `ChatMessageConfiguration` and migration (`CoupleRealtimeChat`)
- [x] `ChatController` REST endpoints (`GET /api/chat`, `POST /api/chat`)
- [x] 3 new unit tests for permissions, realtime broadcast, and chronological pagination (`24/24` backend tests passing)
- [x] Flutter mobile `ChatScreen`, `ChatService`, and `ChatMessageModel` with message thread view and text input
- [x] Home screen navigation button for "Couple Chat"

## Phase 9 — Knowledge Vault (Documents & Secrets)

- [x] VaultItem entity with `VaultItemType` (`Document`, `Secret`, `Card`, `Custom`) and `VisibilityLevel` privacy boundary
- [x] `CreateVaultItemCommand` CQRS handler with couple association for shared/partner-visible items
- [x] `GetVaultItemsQuery` CQRS handler with full-text search across title, description, and tags while strictly isolating partner private secrets
- [x] EF Core `VaultItemConfiguration` and migration (`KnowledgeVaultDocumentsAndSecrets`)
- [x] `VaultController` REST endpoints (`GET /api/vault?search=`, `POST /api/vault`)
- [x] 3 new unit tests for item creation, shared couple linking, and private secret isolation (`27/27` backend tests passing)
- [x] Flutter mobile `VaultScreen`, `VaultService`, and `VaultItemModel` with search bar and secure entry dialog
- [x] Home screen navigation button for "Knowledge Vault"

---

## Phases 10–13

See Master Development Specification for detailed requirements.  
Backlog items will be expanded as each phase begins.

---

## Known Issues / Technical Debt

_None at this stage — greenfield project._

---

## Legend

| Symbol | Meaning |
|---|---|
| ✅ | Complete |
| 🟡 | In progress |
| ⬜ | Not started |
| ❌ | Blocked |
| [x] | Task complete |
| [ ] | Task pending |
