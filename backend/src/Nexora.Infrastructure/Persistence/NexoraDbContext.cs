using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Nexora.Application.Common.Interfaces;
using Nexora.Domain.Audit;
using Nexora.Domain.Features;
using Nexora.Domain.Identity;

namespace Nexora.Infrastructure.Persistence;

/// <summary>
/// The central EF Core DbContext for Nexora.
/// Inherits IdentityDbContext so ASP.NET Core Identity tables are managed here.
/// Implements INexoraDbContext so Application handlers can depend on the interface.
/// </summary>
public sealed class NexoraDbContext
    : IdentityDbContext<ApplicationUser, IdentityRole<Guid>, Guid>,
      INexoraDbContext
{
    public NexoraDbContext(DbContextOptions<NexoraDbContext> options) : base(options) { }

    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<FeatureFlag> FeatureFlags => Set<FeatureFlag>();
    public DbSet<AuditLog> AuditLogs => Set<AuditLog>();

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder); // Identity schema

        // Apply all entity configurations from this assembly
        builder.ApplyConfigurationsFromAssembly(typeof(NexoraDbContext).Assembly);

        // Rename Identity tables to cleaner names
        builder.Entity<ApplicationUser>().ToTable("Users");
        builder.Entity<IdentityRole<Guid>>().ToTable("Roles");
        builder.Entity<IdentityUserRole<Guid>>().ToTable("UserRoles");
        builder.Entity<IdentityUserClaim<Guid>>().ToTable("UserClaims");
        builder.Entity<IdentityUserLogin<Guid>>().ToTable("UserLogins");
        builder.Entity<IdentityRoleClaim<Guid>>().ToTable("RoleClaims");
        builder.Entity<IdentityUserToken<Guid>>().ToTable("UserTokens");
    }

    public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        return await base.SaveChangesAsync(cancellationToken);
    }
}
