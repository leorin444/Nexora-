using Microsoft.EntityFrameworkCore;
using Nexora.Domain.Audit;
using Nexora.Domain.Calendar;
using Nexora.Domain.Chat;
using Nexora.Domain.Couples;
using Nexora.Domain.Features;
using Nexora.Domain.Identity;
using Nexora.Domain.News;
using Nexora.Domain.Notes;
using Nexora.Domain.Reminders;
using Nexora.Domain.Vault;

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
    DbSet<Note> Notes { get; }
    DbSet<Reminder> Reminders { get; }
    DbSet<Couple> Couples { get; }
    DbSet<CoupleInvitation> CoupleInvitations { get; }
    DbSet<CalendarEvent> CalendarEvents { get; }
    DbSet<ChatMessage> ChatMessages { get; }
    DbSet<VaultItem> VaultItems { get; }
    DbSet<NewsArticle> NewsArticles { get; }

    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
