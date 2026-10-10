using Microsoft.EntityFrameworkCore;
using Nexora.Application.Common.Interfaces;
using Nexora.Domain.Features;

namespace Nexora.Infrastructure.Services;

public sealed class FeatureFlagService(INexoraDbContext dbContext) : IFeatureFlagService
{
    public async Task<bool> IsFeatureEnabledAsync(string featureName, CancellationToken cancellationToken = default)
    {
        var flag = await dbContext.FeatureFlags
            .AsNoTracking()
            .FirstOrDefaultAsync(f => f.Name == featureName, cancellationToken);

        // Default to enabled if flag entry not present
        return flag?.IsEnabled ?? true;
    }

    public async Task<IDictionary<string, bool>> GetAllFeatureFlagsAsync(CancellationToken cancellationToken = default)
    {
        var flagsInDb = await dbContext.FeatureFlags
            .AsNoTracking()
            .ToDictionaryAsync(f => f.Name, f => f.IsEnabled, cancellationToken);

        var result = new Dictionary<string, bool>();
        foreach (var key in FeatureKeys.All)
        {
            result[key] = flagsInDb.TryGetValue(key, out var isEnabled) ? isEnabled : true;
        }

        return result;
    }

    public async Task SetFeatureStateAsync(string featureName, bool isEnabled, string updatedBy, CancellationToken cancellationToken = default)
    {
        var flag = await dbContext.FeatureFlags
            .FirstOrDefaultAsync(f => f.Name == featureName, cancellationToken);

        if (flag is null)
        {
            flag = new FeatureFlag
            {
                Name = featureName,
                IsEnabled = isEnabled,
                Description = $"Feature flag for {featureName}",
                UpdatedAtUtc = DateTime.UtcNow,
                UpdatedBy = updatedBy
            };
            dbContext.FeatureFlags.Add(flag);
        }
        else
        {
            flag.IsEnabled = isEnabled;
            flag.UpdatedAtUtc = DateTime.UtcNow;
            flag.UpdatedBy = updatedBy;
        }

        await dbContext.SaveChangesAsync(cancellationToken);
    }
}
