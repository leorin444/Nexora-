# ADR-002: Flutter Web for Web Application

**Status:** Accepted  
**Date:** 2026-10-05  
**Deciders:** Product Owner, Development Agent

---

## Context

The platform requires a web application. Options evaluated were:

1. Flutter Web (same codebase as mobile)
2. React / Next.js (separate codebase)
3. Blazor WebAssembly (separate .NET web codebase)
4. Blazor Server (used for Admin)

## Decision

Use **Flutter Web** for the primary user-facing web application.

## Rationale

- Maximum code sharing with the Flutter mobile application (widgets, business logic, navigation, state management).
- Single team, single language (Dart), lower cognitive overhead.
- Acceptable for the target audience (personal/couple use, small user base).
- Modern Flutter Web (CanvasKit renderer) provides good rendering quality.

## Known Trade-offs

| Trade-off | Mitigation |
|---|---|
| SEO is poor for Flutter Web | This is a private platform, not a public SEO-driven site. Not a concern. |
| Initial bundle size is larger | Acceptable for a private authenticated application. |
| Some platform-specific web integrations are harder | Evaluated case by case; Flutter plugins cover common cases. |

## Consequences

- `/mobile` and `/web` may share code via a shared Flutter package in the future if significant duplication is identified.
- If a fully native web experience is needed for a specific feature, a dedicated REST API endpoint can serve an embedded HTML/JS widget.
- This decision will be revisited if the user base or SEO requirements change significantly.
