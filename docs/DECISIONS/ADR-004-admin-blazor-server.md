# ADR-004: Admin Dashboard with Blazor Server

**Status:** Accepted  
**Date:** 2026-10-05  
**Deciders:** Product Owner, Development Agent

---

## Context

The platform requires a dedicated admin dashboard for:

- User management
- Couple management
- Feature flag management
- System settings
- News sector/source configuration
- Audit log viewing
- System health information

Options evaluated:

1. **Flutter Web** (same stack as mobile/web app)
2. **Blazor Server** (.NET — shares domain/infrastructure code)
3. **React / Vue** (separate frontend framework)
4. **ASP.NET Core MVC** (server-rendered, minimal JS)

## Decision

Use **Blazor Server** for the admin dashboard.

## Rationale

- Blazor Server runs on the server; all rendering logic stays on the backend — appropriate for an admin tool.
- Can directly reference `Nexora.Application` and `Nexora.Infrastructure` without going through the public REST API for admin operations.
- Shares the same .NET solution as the backend — no separate language or build toolchain.
- Simpler authentication integration (ASP.NET Core Identity / cookie auth for server-rendered admin).
- No need for JavaScript framework expertise.
- Excellent for data-heavy admin UIs with real-time capabilities (SignalR is built into Blazor Server).

## Known Trade-offs

| Trade-off | Mitigation |
|---|---|
| Requires persistent server connection (WebSocket) | Acceptable — admin is a low-traffic internal tool. |
| Not a thick-client SPA | Not needed for an admin dashboard. |
| Deployed alongside or separately from API | Initially co-deployed; can be separated later. |

## Consequences

- Admin project lives in `/admin/Nexora.Admin`.
- Admin project references `Nexora.Application` directly.
- Admin authentication uses ASP.NET Core cookie authentication with admin role enforcement.
- The Blazor Server admin must **never** be exposed on the same public port as the API without explicit admin route protection.
- Admin actions are logged via the audit system.
