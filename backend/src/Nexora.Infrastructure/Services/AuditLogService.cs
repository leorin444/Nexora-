using Microsoft.AspNetCore.Http;
using Nexora.Application.Common.Interfaces;
using Nexora.Domain.Audit;

namespace Nexora.Infrastructure.Services;

public sealed class AuditLogService(
    INexoraDbContext dbContext,
    ICurrentUserService currentUserService,
    IHttpContextAccessor httpContextAccessor) : IAuditLogService
{
    public async Task LogAsync(
        string action,
        string domain,
        string entityName,
        string? entityId = null,
        string details = "",
        CancellationToken cancellationToken = default)
    {
        var httpContext = httpContextAccessor.HttpContext;
        var userEmail = httpContext?.User.Identity?.Name ?? "Anonymous";

        var log = new AuditLog
        {
            UserId = currentUserService.UserId,
            UserEmail = userEmail,
            Action = action,
            Domain = domain,
            EntityName = entityName,
            EntityId = entityId,
            Details = details,
            IpAddress = httpContext?.Connection.RemoteIpAddress?.ToString(),
            CreatedAtUtc = DateTime.UtcNow
        };

        dbContext.AuditLogs.Add(log);
        await dbContext.SaveChangesAsync(cancellationToken);
    }
}
