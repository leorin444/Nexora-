# ADR-005: Secrets Management with .NET User Secrets

**Status:** Accepted  
**Date:** 2026-10-05  
**Deciders:** Product Owner, Development Agent

---

## Context

The application requires secrets for development:

- Database connection strings
- JWT signing keys
- AI provider API keys
- Email/notification service credentials
- Any third-party service keys

Secrets must never be committed to Git.

Options evaluated:

1. **.NET User Secrets** — built-in to .NET, stored outside the project directory
2. `.env` files — simple, but easy to accidentally commit; no .NET-native tooling
3. Azure Key Vault — cloud-dependent, adds infrastructure complexity for local dev
4. HashiCorp Vault — heavy infrastructure for local dev

## Decision

Use **.NET User Secrets** for local development secrets.

For production, use **environment variables** injected by the deployment environment (container env vars, systemd environment files, or a secrets manager integration).

## How It Works

.NET User Secrets stores secrets in:
```
%APPDATA%\Microsoft\UserSecrets\<user-secrets-id>\secrets.json
```
This location is outside the project directory and never tracked by Git.

## Setup for Each Project

```bash
# In backend/src/Nexora.Api
dotnet user-secrets init

# Add a secret
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Server=.;Database=NexoraDb;..."
dotnet user-secrets set "Jwt:SecretKey" "your-dev-secret-key"
```

## Configuration Priority (ASP.NET Core)

ASP.NET Core configuration sources are loaded in this order (later overrides earlier):

1. `appsettings.json` (defaults, no secrets)
2. `appsettings.{Environment}.json` (environment-specific, no secrets)
3. User Secrets (Development only, not committed)
4. Environment Variables (Production)

## Rules

- `appsettings.json` must contain only non-secret defaults and placeholder values.
- `appsettings.Development.json` must not contain real secrets (use User Secrets instead).
- `appsettings.Production.json` is gitignored and should not exist in the repo.
- All secret keys must be documented in `docs/DEVELOPMENT.md` so developers know which User Secrets to configure.
- The CI pipeline uses GitHub Actions secrets (environment variables) — never hardcoded values.

## Consequences

- New developers must run `dotnet user-secrets set ...` commands to configure their local environment.
- `docs/DEVELOPMENT.md` must list all required secret keys.
- Production deployment must inject secrets as environment variables or a mounted secrets file outside the repository.
