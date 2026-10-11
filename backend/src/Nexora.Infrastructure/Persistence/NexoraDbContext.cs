using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Nexora.Application.Common.Interfaces;
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

namespace Nexora.Infrastructure.Persistence;

/// <summary>
/// The central EF Core DbContext for Nexora.
/// </summary>
public sealed class NexoraDbContext
    : IdentityDbContext<ApplicationUser, IdentityRole<Guid>, Guid>,
      INexoraDbContext
{
    public NexoraDbContext(DbContextOptions<NexoraDbContext> options) : base(options) { }

    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<FeatureFlag> FeatureFlags => Set<FeatureFlag>();
    public DbSet<AuditLog> AuditLogs => Set<AuditLog>();
    public DbSet<Note> Notes => Set<Note>();
    public DbSet<Reminder> Reminders => Set<Reminder>();
    public DbSet<Couple> Couples => Set<Couple>();
    public DbSet<CoupleInvitation> CoupleInvitations => Set<CoupleInvitation>();
    public DbSet<CalendarEvent> CalendarEvents => Set<CalendarEvent>();
    public DbSet<ChatMessage> ChatMessages => Set<ChatMessage>();
    public DbSet<VaultItem> VaultItems => Set<VaultItem>();
    public DbSet<NewsArticle> NewsArticles => Set<NewsArticle>();

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);
        builder.ApplyConfigurationsFromAssembly(typeof(NexoraDbContext).Assembly);

        builder.Entity<ApplicationUser>().ToTable("Users");
        builder.Entity<IdentityRole<Guid>>().ToTable("Roles");
        builder.Entity<IdentityUserRole<Guid>>().ToTable("UserRoles");
        builder.Entity<IdentityUserClaim<Guid>>().ToTable("UserClaims");
        builder.Entity<IdentityUserLogin<Guid>>().ToTable("UserLogins");
        builder.Entity<IdentityRoleClaim<Guid>>().ToTable("RoleClaims");
        builder.Entity<IdentityUserToken<Guid>>().ToTable("UserTokens");
    }

    public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        => await base.SaveChangesAsync(cancellationToken);
}
