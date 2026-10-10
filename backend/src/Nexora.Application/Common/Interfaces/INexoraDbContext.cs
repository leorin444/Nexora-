using Microsoft.EntityFrameworkCore;
using Nexora.Domain.Audit;
using Nexora.Domain.Features;
using Nexora.Domain.Identity;

namespace Nexora.Application.Common.Interfaces;

/// <summary>
/// Application-layer abstraction over the EF Core DbContext.
/// Handlers depend on this interface rather than the concrete Infrastructure type.
/// </summary>
public interface INexoraDbContext
{
    DbSet<RefreshToken> RefreshTokens { get; }
    DbSet<FeatureFlag> FeatureFlags { get; }
    DbSet<AuditLog> AuditLogs { get; }

    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
