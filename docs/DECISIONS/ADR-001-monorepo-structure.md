# ADR-001: Monorepo Structure

**Status:** Accepted  
**Date:** 2026-10-05  
**Deciders:** Product Owner, Development Agent

---

## Context

The platform consists of multiple projects: a Flutter mobile app, Flutter Web, an ASP.NET Core backend API, a Blazor Server admin dashboard, database migrations, and documentation. A decision was required on whether to use a monorepo or separate repositories per project.

## Decision

Use a **single monorepo** at `a:\Projects\Nexora` with the following top-level structure:

```
/docs          — Documentation, ADRs, specifications
/mobile        — Flutter mobile application
/web           — Flutter Web application
/backend       — ASP.NET Core Web API (Clean Architecture)
/admin         — Blazor Server admin dashboard
/database      — EF Core migrations and SQL scripts
/tests         — Cross-cutting and end-to-end tests
```

## Rationale

- All projects share the same domain language and evolve together.
- A monorepo makes cross-cutting changes (e.g., adding a new domain) easier to review in one pull request.
- Simpler CI/CD setup for a small team.
- Shared documentation and ADRs live alongside the code they describe.
- No cross-repo dependency management overhead at this stage.

## Consequences

- All developers must have the full toolchain installed (.NET SDK + Flutter SDK + Git).
- The root `.gitignore` must cover all project types.
- CI must be capable of building only affected projects (achievable with path filters in GitHub Actions).
- If the project significantly grows in team size, a migration to separate repos or a monorepo tool (e.g., Nx, Turborepo, or .NET Aspire orchestration) can be evaluated at that time.
