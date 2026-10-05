# Architecture Overview

**Project:** Nexora  
**Version:** 1.0 (Phase 1 — Engineering Foundation)  
**Last Updated:** 2026-10-05

---

## System Overview

Nexora is a secure, private, extensible personal and couple platform implemented as a distributed system with the following components:

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                              │
│                                                                  │
│   Flutter Mobile App    Flutter Web App    Blazor Server Admin   │
│   (iOS / Android)       (Browser)          (Admin Dashboard)     │
└────────────────┬─────────────────┬──────────────────┬───────────┘
                 │   REST/HTTP     │   REST/HTTP       │ Direct ref
                 │   + SignalR     │   + SignalR       │
┌────────────────▼─────────────────▼──────────────────▼───────────┐
│                      BACKEND LAYER                               │
│                                                                  │
│              ASP.NET Core 10 Web API                             │
│              (Nexora.Api)                                        │
│                                                                  │
│   ┌──────────────────────────────────────────────────────────┐   │
│   │              Application Layer (Nexora.Application)       │   │
│   │   Commands · Queries · Interfaces · DTOs · Validators    │   │
│   └─────────────────────────┬────────────────────────────────┘   │
│                             │                                    │
│   ┌─────────────────────────▼────────────────────────────────┐   │
│   │              Domain Layer (Nexora.Domain)                  │   │
│   │   Entities · Value Objects · Domain Events · Enums        │   │
│   └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│   ┌──────────────────────────────────────────────────────────┐   │
│   │           Infrastructure Layer (Nexora.Infrastructure)    │   │
│   │   EF Core · Repositories · SignalR Hubs · AI Adapters    │   │
│   │   Hangfire Jobs · Email · External Services               │   │
│   └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────┬────────────────────┘
                                              │
┌─────────────────────────────────────────────▼────────────────────┐
│                      DATA / SERVICES LAYER                        │
│                                                                   │
│   SQL Server (primary DB)    Hangfire (job store, same DB)        │
│   SignalR (in-memory / Azure) AI Provider (Cloud / Ollama)        │
└───────────────────────────────────────────────────────────────────┘
```

---

## Backend — Clean Architecture

The backend follows Clean Architecture principles:

### Layer Dependencies (inward-only)

```
Api → Application → Domain
Infrastructure → Application → Domain
```

Infrastructure and Api both reference Application and Domain.  
Domain has zero external dependencies.  
Application depends only on Domain and defines interfaces that Infrastructure implements.

### Project Responsibilities

| Project | Responsibility |
|---|---|
| `Nexora.Domain` | Entities, value objects, domain events, enums, domain exceptions. No external dependencies. |
| `Nexora.Application` | Use cases (commands/queries via MediatR), DTOs, interfaces (repositories, services), validators (FluentValidation), application exceptions. References Domain only. |
| `Nexora.Infrastructure` | EF Core DbContext, repository implementations, SignalR hubs, Hangfire job classes, AI adapters, email, external service integrations. References Application and Domain. |
| `Nexora.Api` | HTTP controllers, middleware, startup configuration, SignalR endpoint mapping, health checks, Swagger. References Application. Infrastructure registered via DI in startup. |

---

## Domain Organization

Domains are organized as folders within each layer:

```
Nexora.Domain/
  Identity/
  Users/
  Couples/
  Privacy/
  FeatureManagement/
  Notes/
  Reminders/
  Calendar/
  Countdown/
  DailyReports/
  Communication/
  Feelings/
  MenstrualCalendar/
  Chat/
  Music/
  KnowledgeVault/
  News/
  AI/
  Notifications/
  Administration/
  AuditLogging/
  SystemSettings/
  Common/           ← shared value objects, base classes, interfaces
```

---

## Privacy Model

Every resource has an explicit visibility level:

| Level | Access |
|---|---|
| `PRIVATE` | Owner only |
| `PARTNER_VISIBLE` | Owner + connected partner |
| `SHARED` | All relevant couple members |

Privacy is enforced at the **backend authorization level**. The UI may also hide non-visible content for usability, but this is not a security control.

---

## Authentication & Authorization

- JWT Bearer tokens for the REST API (mobile + web clients)
- ASP.NET Core Cookie Authentication for the Blazor Server admin
- Role-based authorization: `User`, `Admin`
- Resource-based authorization via authorization handlers (verify ownership, couple membership, etc.)
- Feature flag enforcement via middleware / authorization policies

---

## Realtime

SignalR is used for:
- Couple chat
- Realtime couple status updates
- Future: notifications push

Hubs are defined in `Nexora.Infrastructure` and mapped in `Nexora.Api`.  
Hub authorization verifies couple membership server-side.

---

## Background Jobs

Hangfire with SQL Server persistence handles:
- News fetching (scheduled)
- Reminder notifications (scheduled)
- Daily report generation
- AI processing tasks
- Cleanup operations

Hangfire Dashboard is restricted to admin-authenticated users.

---

## AI Abstraction

```csharp
// Nexora.Application/AI/IAIProvider.cs
public interface IAIProvider
{
    Task<string> CompleteAsync(string prompt, CancellationToken ct = default);
    Task<string> SummarizeAsync(string content, CancellationToken ct = default);
    Task<IReadOnlyList<string>> TagAsync(string content, CancellationToken ct = default);
    bool IsAvailable { get; }
}
```

Implementations registered conditionally:
- `CloudAIProvider` (e.g., Gemini / OpenAI / etc.)
- `OllamaAIProvider` (local model)
- `NullAIProvider` (graceful fallback when AI is unavailable)

---

## Admin Dashboard

- Blazor Server application in `/admin/Nexora.Admin`
- Directly references `Nexora.Application` (no public REST API call for admin operations)
- Separate authentication context (cookie auth, admin role)
- Admins do NOT automatically see private user content
- All admin actions logged via the audit system

---

## Key Architectural Rules

1. Never trust client-supplied IDs — always resolve ownership from the authenticated user context.
2. Authorization must be verified in the backend on every protected operation.
3. Domain logic belongs in `Nexora.Domain` or `Nexora.Application` — never in controllers.
4. Infrastructure implementation details (EF Core, Hangfire, AI SDKs) must not leak into Application or Domain.
5. Secrets must never be in source code. Use .NET User Secrets (dev) or environment variables (prod).

---

## Current Phase

**Phase 1 — Engineering Foundation**

All subsequent phases build on this foundation without modifying its core structure.

See [`BACKLOG.md`](BACKLOG.md) for the full phase plan.
