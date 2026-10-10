namespace Nexora.Application.Common.Interfaces;

public interface IAuditLogService
{
    Task LogAsync(
        string action,
        string domain,
        string entityName,
        string? entityId = null,
        string details = "",
        CancellationToken cancellationToken = default);
}
