# Security Policy

**Project:** Nexora  
**Version:** 1.0  
**Last Updated:** 2026-10-05

---

## Core Security Principles

1. **Never trust the client.** Every protected operation is authorized server-side.
2. **Privacy by design.** The most restrictive visibility is the default.
3. **Least privilege.** Each role, user, and service has access only to what it needs.
4. **Secrets never in source code.** Use .NET User Secrets (dev) or environment variables (prod).
5. **Defense in depth.** Authorization is checked at the API level, the application layer, and where appropriate at the database query level.

---

## Authentication

### API (Mobile + Web clients)

- JWT Bearer tokens issued on successful login.
- Access token lifetime: **15 minutes** (short-lived).
- Refresh token: **7 days**, stored securely (HttpOnly cookie or secure storage).
- JWT signing key is a strong random secret (minimum 32 bytes), stored in User Secrets / environment variables — never committed.
- Tokens are validated on every protected request.
- Token revocation is supported via a token blacklist / refresh token invalidation in the database.

### Admin Dashboard (Blazor Server)

- ASP.NET Core Cookie Authentication.
- Separate admin login page.
- Admin role enforced on all admin routes.
- Session timeout appropriate for admin tools.

### Password Handling

- Passwords are hashed using **ASP.NET Core Identity** default hasher (PBKDF2 with HMACSHA512, 100,000 iterations).
- Passwords are never stored in plaintext.
- Passwords are never logged.
- Password validation: minimum length 8, complexity rules enforced.

---

## Authorization

### Roles

| Role | Description |
|---|---|
| `User` | Standard platform user. Can access only their own data and authorized couple data. |
| `Admin` | Platform administrator. Can manage platform configuration. Cannot access private user content by default. |

### Resource Authorization

Every resource access is authorized by:

1. **Authentication check** — Is the request authenticated?
2. **Role check** — Does the user have the required role?
3. **Ownership check** — Does the authenticated user own the resource?
4. **Visibility check** — Is the resource visibility appropriate for this user?
5. **Couple membership check** — For couple resources, is the user a member of the relevant couple?
6. **Feature flag check** — Is the feature enabled for this user/system?

### Authorization Handler Pattern

Custom `IAuthorizationHandler` implementations enforce resource-level authorization:

```csharp
// Example pattern
public class NoteAuthorizationHandler
    : AuthorizationHandler<OperationAuthorizationRequirement, Note>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        OperationAuthorizationRequirement requirement,
        Note resource)
    {
        var userId = context.User.GetUserId();

        if (requirement == Operations.Read)
        {
            if (resource.OwnerId == userId ||
                (resource.Visibility == Visibility.PartnerVisible && IsPartner(userId, resource)) ||
                (resource.Visibility == Visibility.Shared && IsCoupleMe(userId, resource)))
            {
                context.Succeed(requirement);
            }
        }
        // ... etc.
        return Task.CompletedTask;
    }
}
```

---

## Privacy Model

| Visibility | Who Can Access |
|---|---|
| `Private` | Owner only |
| `PartnerVisible` | Owner + active connected partner |
| `Shared` | Both couple members |

**Default visibility for sensitive resources:** `Private`

Sensitive resources (private feelings, menstrual calendar, private notes) default to `Private` and require explicit user action to change visibility.

---

## Trust Boundaries

### Never trust from the client:

- User IDs (always resolve from the authenticated JWT claim)
- Couple IDs (always verify membership server-side)
- Resource IDs (always verify ownership/visibility before returning or modifying)
- Feature flags (always evaluate server-side)
- Visibility values (validate and clamp server-side)
- Admin status (always check role from the token/session, never a client-provided flag)

### Always resolve server-side:

```csharp
// WRONG — never do this
var userId = request.UserId;

// CORRECT — always do this
var userId = httpContext.User.GetUserId(); // from JWT claim
```

---

## Explicit Security Tests Required

The following scenarios must be tested with integration/security tests:

| Scenario | Test Type |
|---|---|
| User A reads User B's private resource | Integration — expect 403/404 |
| User A modifies User B's resource | Integration — expect 403/404 |
| User A accesses an unrelated couple's data | Integration — expect 403 |
| User A accesses a disabled feature | Integration — expect 403/404 |
| Using an expired invitation token | Integration — expect 400 |
| Reusing a single-use invitation token | Integration — expect 400 |
| Unauthorized admin operation by a regular user | Integration — expect 403 |
| Admin accessing private user feelings/journal | Integration — expect 403 |
| JWT with manipulated claims | Unit — token validation |
| JWT with expired expiry | Unit — token validation |

---

## Logging and Audit

- All authentication events (login, logout, failed login, registration) are logged.
- All admin actions are logged to the audit log.
- All authorization failures are logged (with user context, not resource content).
- Personal/private content is **never** included in log messages.
- Log levels: `Information` for normal operations, `Warning` for suspicious events, `Error` for failures.

---

## Production Security Checklist

Before any production deployment:

- [ ] HTTPS enforced (HTTP Strict Transport Security header)
- [ ] JWT signing key rotated from any dev default
- [ ] Database not publicly exposed
- [ ] Admin dashboard not publicly accessible
- [ ] Hangfire dashboard not publicly accessible
- [ ] Rate limiting configured on auth endpoints
- [ ] Input validation active on all endpoints
- [ ] Dependency vulnerability scan run
- [ ] Security headers configured (CORS, CSP, X-Frame-Options, etc.)
- [ ] Secrets confirmed not in repository (git secrets scan)
- [ ] Error responses do not leak stack traces or sensitive info

---

## Known Sensitive Areas

| Area | Privacy Level | Extra Care |
|---|---|---|
| Private feelings / reflection | Private only | AI must not accidentally expose to admin |
| Menstrual calendar | Private by default | Explicit user consent to share with partner |
| Private notes | Private by default | Ownership strictly enforced |
| Couple chat messages | Couple members only | No admin visibility by default |
| User passwords | Never stored/visible | Hash only |
| JWT secrets | Never in source | User Secrets / env vars only |
| AI API keys | Never in source | User Secrets / env vars only |
