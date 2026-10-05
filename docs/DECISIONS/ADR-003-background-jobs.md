# ADR-003: Background Job Processing with Hangfire

**Status:** Accepted  
**Date:** 2026-10-05  
**Deciders:** Product Owner, Development Agent

---

## Context

The platform requires background job processing for:

- Periodic news fetching and normalization
- Scheduled reminders and notifications
- Daily report generation
- AI processing tasks
- Cleanup and maintenance operations

Options evaluated:

1. **Hangfire** — mature, battle-tested, has a built-in dashboard, SQL Server persistence support
2. **.NET Hosted Services / `BackgroundService`** — built-in, no dashboard, limited retry/scheduling
3. **Quartz.NET** — feature-rich scheduler, more complex configuration
4. **Azure Functions / AWS Lambda** — cloud-dependent, adds infrastructure complexity

## Decision

Use **Hangfire** with **SQL Server** as the persistent job store.

## Rationale

- Hangfire's SQL Server persistence means jobs survive application restarts.
- Built-in retry policies and failure handling.
- Hangfire Dashboard provides visibility into job status (restricted to admins).
- SQL Server is already the primary database — no additional infrastructure needed.
- Well-supported in the .NET ecosystem with active maintenance.
- Simple integration into ASP.NET Core DI.

## Configuration Rules

- The Hangfire Dashboard **must** be protected by admin authorization.
- The Hangfire Dashboard **must not** be exposed publicly (behind admin route or localhost only).
- Job definitions (classes) live in `Nexora.Application` or `Nexora.Infrastructure`.
- Jobs must be idempotent where possible — they may run more than once on failure.

## Consequences

- Adds a Hangfire schema to the SQL Server database (managed automatically by Hangfire).
- The Hangfire schema tables do not need to be in EF Core migrations — Hangfire manages them.
- Long-running or CPU-intensive jobs should be run on a dedicated server/worker process in production.
- This decision will be revisited if the system requires distributed workers at scale.
