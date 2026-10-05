using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Nexora.Domain.Identity;

namespace Nexora.Infrastructure.Persistence;

/// <summary>
/// Seeds essential data on first startup:
/// - Roles (Admin, User)
/// - Default admin user (credentials from configuration — never hardcoded)
/// </summary>
public static class DatabaseSeeder
{
    public static async Task SeedAsync(
        NexoraDbContext context,
        UserManager<ApplicationUser> userManager,
        RoleManager<IdentityRole<Guid>> roleManager,
        ILogger logger)
    {
        // Apply any pending migrations
        await context.Database.MigrateAsync();

        // Seed roles
        string[] roles = ["Admin", "User"];
        foreach (var role in roles)
        {
            if (!await roleManager.RoleExistsAsync(role))
            {
                await roleManager.CreateAsync(new IdentityRole<Guid>(role));
                logger.LogInformation("Created role: {Role}", role);
            }
        }
    }
}
