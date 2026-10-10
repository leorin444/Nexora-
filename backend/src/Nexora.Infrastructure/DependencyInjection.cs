using Hangfire;
using Hangfire.SqlServer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Nexora.Application.AI;
using Nexora.Application.Common.Interfaces;
using Nexora.Domain.Identity;
using Nexora.Infrastructure.AI;
using Nexora.Infrastructure.Identity;
using Nexora.Infrastructure.Persistence;

namespace Nexora.Infrastructure;

/// <summary>
/// Registers all Infrastructure layer services into the DI container.
/// Called from the API and Admin startup.
/// </summary>
public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructureServices(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        // ─── Database (EF Core + SQL Server) ──────────────────────────────────
        var connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException(
                "Connection string 'DefaultConnection' not found. " +
                "Set it via .NET User Secrets (development) or environment variable (production).");

        services.AddDbContext<NexoraDbContext>(options =>
            options.UseSqlServer(connectionString, sql =>
            {
                sql.MigrationsAssembly(typeof(NexoraDbContext).Assembly.FullName);
                sql.EnableRetryOnFailure(maxRetryCount: 3);
            }));

        services.AddScoped<INexoraDbContext>(sp => sp.GetRequiredService<NexoraDbContext>());

        // ─── ASP.NET Core Identity ─────────────────────────────────────────────
        services.AddIdentity<ApplicationUser, IdentityRole<Guid>>(options =>
        {
            options.Password.RequireDigit = true;
            options.Password.RequireLowercase = true;
            options.Password.RequireUppercase = true;
            options.Password.RequiredLength = 8;
            options.Password.RequireNonAlphanumeric = false;

            options.User.RequireUniqueEmail = true;
            options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(5);
            options.Lockout.MaxFailedAccessAttempts = 5;
        })
        .AddEntityFrameworkStores<NexoraDbContext>()
        .AddDefaultTokenProviders();

        // ─── Identity Services ─────────────────────────────────────────────────
        services.AddScoped<ITokenService, TokenService>();
        services.AddHttpContextAccessor();
        services.AddScoped<ICurrentUserService, CurrentUserService>();

        // ─── Platform Core Services ────────────────────────────────────────────
        services.AddScoped<IFeatureFlagService, Nexora.Infrastructure.Services.FeatureFlagService>();
        services.AddScoped<IAuditLogService, Nexora.Infrastructure.Services.AuditLogService>();

        // ─── Background Jobs (Hangfire) ────────────────────────────────────────
        services.AddHangfire(config => config
            .SetDataCompatibilityLevel(CompatibilityLevel.Version_180)
            .UseSimpleAssemblyNameTypeSerializer()
            .UseRecommendedSerializerSettings()
            .UseSqlServerStorage(connectionString, new SqlServerStorageOptions
            {
                CommandBatchMaxTimeout = TimeSpan.FromMinutes(5),
                SlidingInvisibilityTimeout = TimeSpan.FromMinutes(5),
                QueuePollInterval = TimeSpan.Zero,
                UseRecommendedIsolationLevel = true,
                DisableGlobalLocks = true
            }));
        services.AddHangfireServer();

        // ─── AI Provider ──────────────────────────────────────────────────────
        var aiProvider = configuration.GetValue<string>("AI:Provider") ?? "None";
        services.AddAIProvider(aiProvider, configuration);

        // ─── Health Checks ─────────────────────────────────────────────────────
        services.AddHealthChecks()
            .AddSqlServer(
                connectionString,
                name: "sql-server",
                tags: ["db", "sql"]);

        return services;
    }

    private static IServiceCollection AddAIProvider(
        this IServiceCollection services,
        string providerName,
        IConfiguration configuration)
    {
        services.AddSingleton<IAIProvider, NullAIProvider>();
        return services;
    }
}
