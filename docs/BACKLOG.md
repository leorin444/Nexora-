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
- [ ] `appsettings.json` — confirm no secrets ✅
- [ ] `.NET User Secrets` initialized for Nexora.Api
- [ ] First successful `dotnet build`
- [ ] First successful `dotnet test`

### Flutter Mobile

- [x] `nexora_mobile` Flutter project scaffolded
- [ ] Basic app structure established
- [ ] First successful `flutter build`

### Blazor Admin

- [x] `Nexora.Admin` Blazor project scaffolded
- [ ] First successful `dotnet build`

### CI

- [x] GitHub Actions `ci.yml` workflow created

---

## Phase 2 — Identity & Security

### Backend

- [ ] ASP.NET Core Identity configured
- [ ] `User` entity defined
- [ ] `Role` entity defined
- [ ] Database migrations for Identity tables
- [ ] Registration endpoint (`POST /api/auth/register`)
- [ ] Login endpoint (`POST /api/auth/login`)
- [ ] Logout endpoint (`POST /api/auth/logout`)
- [ ] JWT access token issuance
- [ ] Refresh token issuance and storage
- [ ] Token refresh endpoint (`POST /api/auth/refresh`)
- [ ] Token revocation on logout
- [ ] Password hashing verified
- [ ] User profile endpoint (`GET /api/users/me`)
- [ ] Authorization policies defined
- [ ] Audit log foundation

### Tests

- [ ] Registration — happy path
- [ ] Registration — duplicate email
- [ ] Login — valid credentials
- [ ] Login — invalid credentials
- [ ] Token refresh — valid token
- [ ] Token refresh — expired token
- [ ] User A cannot access User B's profile
- [ ] Unauthorized request returns 401
- [ ] Forbidden request returns 403

### Flutter Mobile

- [ ] Auth state management
- [ ] Login screen
- [ ] Registration screen
- [ ] Token storage (secure storage)

---

## Phase 3 — Platform Core

- [ ] Feature flag registry
- [ ] Feature flag evaluation service
- [ ] Personal Mode concept
- [ ] Couple Mode concept
- [ ] Visibility enum (`Private`, `PartnerVisible`, `Shared`)
- [ ] Authorization policies for visibility
- [ ] Shared resource foundation

---

## Phase 4 — Admin Foundation

- [ ] Admin login (Blazor cookie auth)
- [ ] Admin dashboard home
- [ ] User list
- [ ] Feature flag management UI
- [ ] System settings
- [ ] Audit log viewer
- [ ] News sector/source management

---

## Phases 5–13

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
