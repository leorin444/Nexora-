namespace Nexora.Application.Common.Interfaces;

public interface IFeatureFlagService
{
    Task<bool> IsFeatureEnabledAsync(string featureName, CancellationToken cancellationToken = default);
    Task<IDictionary<string, bool>> GetAllFeatureFlagsAsync(CancellationToken cancellationToken = default);
    Task SetFeatureStateAsync(string featureName, bool isEnabled, string updatedBy, CancellationToken cancellationToken = default);
}
