# Nexora

**A secure, private, extensible personal and couple platform.**

> Private. Organized. Together.

---

## What Is Nexora?

Nexora is a personal and couple platform designed to be a centralized hub for:

- Personal organization (notes, reminders, calendar, countdowns, daily reflection)
- Couple interaction (chat, shared notes, shared media, couple calendar)
- Knowledge management (knowledge vault, saved links, screenshots)
- AI-assisted features (communication coach, summaries, tagging)
- News aggregation from curated sources
- And more — progressively built over time

---

## Technology Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter 3.x / Dart |
| Web | Flutter Web |
| Backend API | ASP.NET Core 10 (Clean Architecture) |
| Admin Dashboard | Blazor Server (.NET 10) |
| Database | Microsoft SQL Server |
| Realtime | SignalR |
| Background Jobs | Hangfire |
| AI | Provider-abstracted (Cloud / Ollama) |

---

## Repository Structure

```
/docs          — Documentation, ADRs, SRS, API reference
/mobile        — Flutter mobile application
/web           — Flutter Web application
/backend       — ASP.NET Core Web API (Clean Architecture)
/admin         — Blazor Server admin dashboard
/database      — EF Core migrations and database scripts
/tests         — Cross-cutting / E2E tests
```

---

## Getting Started (Development)

See [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md) for full setup instructions.

### Quick prerequisites

- .NET 10 SDK
- Flutter 3.x SDK
- SQL Server Express (local)
- Git

### Clone and initialize

```bash
git clone <repo-url>
cd Nexora
```

Then follow the setup steps in `docs/DEVELOPMENT.md`.

---

## Documentation

| Document | Purpose |
|---|---|
| [`docs/SRS.md`](docs/SRS.md) | Software Requirements Specification |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | System architecture overview |
| [`docs/SECURITY.md`](docs/SECURITY.md) | Security model and rules |
| [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md) | Developer setup guide |
| [`docs/DATABASE.md`](docs/DATABASE.md) | Database design and migration guide |
| [`docs/API.md`](docs/API.md) | API reference |
| [`docs/BACKLOG.md`](docs/BACKLOG.md) | Development backlog |
| [`docs/DECISIONS/`](docs/DECISIONS/) | Architecture Decision Records (ADRs) |

---

## Development Phase

Current phase: **Phase 1 — Engineering Foundation**

See [`docs/BACKLOG.md`](docs/BACKLOG.md) for full phase plan and progress.

---

## Security

**Never commit:** credentials, connection strings, API keys, JWT secrets, or `.env` files.

See [`docs/SECURITY.md`](docs/SECURITY.md) for the full security model.

---

## License

Private — not for public distribution.
