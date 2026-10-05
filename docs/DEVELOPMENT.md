# Development Guide

**Project:** Nexora  
**Last Updated:** 2026-10-05

---

## Prerequisites

Install the following before setting up the project:

| Tool | Version | Download |
|---|---|---|
| .NET SDK | 10.0+ | https://dotnet.microsoft.com/download |
| Flutter SDK | 3.47+ | https://flutter.dev/docs/get-started/install |
| Git | 2.x+ | https://git-scm.com |
| SQL Server Express | 2022 (or full) | https://www.microsoft.com/en-us/sql-server/sql-server-downloads |
| SQL Server Management Studio (optional) | Latest | https://aka.ms/ssmsfullsetup |

---

## Repository Structure

```
/docs          — Documentation, ADRs, SRS, API reference
/mobile        — Flutter mobile application (nexora_mobile)
/web           — Flutter Web application (future)
/backend       — ASP.NET Core 10 Web API
  /src
    Nexora.Api           — HTTP entry point, controllers, middleware
    Nexora.Application   — Use cases, interfaces, DTOs, validators
    Nexora.Domain        — Entities, value objects, domain logic
    Nexora.Infrastructure — EF Core, Hangfire, AI adapters
  /tests
    Nexora.UnitTests
    Nexora.IntegrationTests
/admin         — Blazor Server admin dashboard (Nexora.Admin)
/database      — EF Core migrations and SQL scripts
/tests         — Cross-cutting / E2E tests
```

---

## Backend Setup

### 1. Clone the repository

```bash
git clone <repo-url>
cd Nexora
```

### 2. Configure User Secrets

Navigate to the API project and initialize User Secrets:

```bash
cd backend/src/Nexora.Api
dotnet user-secrets init
```

Set required secrets (replace values with your local configuration):

```bash
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Server=.\\SQLEXPRESS;Database=NexoraDb;Trusted_Connection=True;TrustServerCertificate=True"
dotnet user-secrets set "Jwt:SecretKey" "your-dev-jwt-secret-key-minimum-32-characters"
```

> **Important:** Never commit real secrets to the repository. The `.gitignore` excludes `appsettings.Production.json` and `appsettings.Local.json`.

### 3. Create the development database

```bash
# Run EF Core migrations (once migrations are created in Phase 2)
cd backend/src/Nexora.Api
dotnet ef database update
```

### 4. Run the backend

```bash
cd backend
dotnet run --project src/Nexora.Api/Nexora.Api.csproj
```

API will be available at: `https://localhost:5001`  
Swagger UI: `https://localhost:5001/swagger`  
Health check: `https://localhost:5001/health`

---

## Flutter Mobile Setup

```bash
cd mobile/nexora_mobile
flutter pub get
flutter run
```

For web:
```bash
flutter run -d chrome
```

---

## Admin Dashboard Setup

```bash
cd admin/Nexora.Admin
dotnet run
```

---

## Running Tests

### Backend unit tests

```bash
cd backend
dotnet test tests/Nexora.UnitTests/Nexora.UnitTests.csproj
```

### Backend integration tests

```bash
dotnet test tests/Nexora.IntegrationTests/Nexora.IntegrationTests.csproj
```

### All backend tests

```bash
dotnet test backend/Nexora.slnx
```

### Flutter tests

```bash
cd mobile/nexora_mobile
flutter test
```

---

## Required User Secrets Reference

| Key | Description | Example |
|---|---|---|
| `ConnectionStrings:DefaultConnection` | SQL Server connection string | `Server=.\\SQLEXPRESS;Database=NexoraDb;Trusted_Connection=True;TrustServerCertificate=True` |
| `Jwt:SecretKey` | JWT signing key (min 32 chars) | `dev-secret-key-replace-in-production-please` |
| `AI:CloudApiKey` | Cloud AI API key (optional) | `sk-...` |
| `AI:CloudEndpoint` | Cloud AI endpoint (optional) | `https://...` |

---

## Git Workflow

### Branches

- `main` — production-ready code
- `develop` — integration branch

### Feature branches

```
feature/authentication
feature/couple-system
feature/notes
feature/chat
...
```

### Commit message format

```
feat(auth): add user registration
feat(couple): add invitation validation
test(auth): add cross-user authorization tests
fix(chat): prevent unauthorized couple access
docs(api): update authentication endpoint docs
```

### Never commit

- Secrets, API keys, connection strings with passwords
- `.env` files
- `appsettings.Production.json`
- Binary database files (`.mdf`, `.ldf`)

---

## Development Phases

See [`BACKLOG.md`](BACKLOG.md) for the full phase list and progress tracking.

Current: **Phase 1 — Engineering Foundation**  
Next: **Phase 2 — Identity & Security**
