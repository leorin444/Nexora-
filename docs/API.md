# API Specification & Conventions

**Project:** Nexora Web API  
**Base URL (Local):** `https://localhost:5001/api`  
**Protocol:** RESTful JSON over HTTPS + WebSocket (SignalR)  

---

## 1. General Principles

### 1.1 Content Negotiation & Formatting
- Request/Response content type: `application/json` or `application/problem+json` for errors.
- Naming policy: `camelCase` for JSON keys.
- Timestamps: ISO-8601 UTC strings (`2026-10-05T14:30:00Z`).

### 1.2 Authentication
All protected endpoints require an HTTP Authorization header:
```http
Authorization: Bearer <jwt-access-token>
```

### 1.3 Standard Error Format (RFC 7807)
```json
{
  "type": "https://httpstatuses.com/400",
  "title": "Validation failed",
  "status": 400,
  "detail": "Email is already registered.",
  "instance": "/api/auth/register",
  "traceId": "0HN6..."
}
```

---

## 2. API Endpoints Overview

### 2.1 System & Health
| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/health` | Anonymous | Health check probe (SQL Server, etc.) |
| `GET` | `/api/system/status` | Anonymous | Basic API status and version |

### 2.2 Authentication & Identity (`/api/auth`)
| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/api/auth/register` | Anonymous | Register a new user |
| `POST` | `/api/auth/login` | Anonymous | Authenticate with credentials -> access & refresh tokens |
| `POST` | `/api/auth/refresh` | Anonymous | Rotate refresh token and get fresh access token |
| `POST` | `/api/auth/logout` | Bearer | Revoke active refresh token |

### 2.3 User Profile (`/api/users`)
| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/api/users/me` | Bearer | Get current user's profile |
| `PUT` | `/api/users/me` | Bearer | Update user profile |

### 2.4 Couple Management (`/api/couples`)
| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/api/couples/current` | Bearer | Get active couple details |
| `POST` | `/api/couples/invitations` | Bearer | Generate a couple invitation code / QR data |
| `POST` | `/api/couples/invitations/accept` | Bearer | Accept couple invitation |
| `POST` | `/api/couples/leave` | Bearer | Dissolve or leave current couple |

### 2.5 Personal & Shared Features
- `/api/notes` (`GET`, `POST`, `PUT`, `DELETE`): Notes with visibility filter.
- `/api/reminders` (`GET`, `POST`, `PUT`, `DELETE`): Reminders and completion state.
- `/api/calendar/events` (`GET`, `POST`, `PUT`, `DELETE`): Calendar and countdown events.
- `/api/reflections` (`GET`, `POST`): Daily reflections and moods.
- `/api/vault` (`GET`, `POST`, `PUT`, `DELETE`): Knowledge Vault items and tags.

### 2.6 News (`/api/news`)
| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/api/news/sectors` | Bearer | List available news sectors |
| `GET` | `/api/news/top` | Bearer | Get curated top news per sector |

### 2.7 Administration (`/api/admin`)
| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/api/admin/features` | Admin | List feature flags and states |
| `PUT` | `/api/admin/features/{key}` | Admin | Toggle feature flag |
| `GET` | `/api/admin/users` | Admin | List platform users |
| `GET` | `/api/admin/audit-logs` | Admin | View audit logs |

---

## 3. Realtime SignalR Hubs

### 3.1 Couple Chat Hub (`/hubs/couple-chat`)
- **Connection**: Requires valid JWT token in query string or authorization header.
- **Client Methods**:
  - `SendMessage(string conversationId, string content)`
  - `TypingIndicator(string conversationId, bool isTyping)`
- **Server Events**:
  - `ReceiveMessage(ChatMessageDto message)`
  - `UserTyping(Guid userId, bool isTyping)`
