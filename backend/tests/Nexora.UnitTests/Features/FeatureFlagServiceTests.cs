using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Nexora.Domain.Features;
using Nexora.Infrastructure.Persistence;
using Nexora.Infrastructure.Services;
using Xunit;

namespace Nexora.UnitTests.Features;

public class FeatureFlagServiceTests
{
    private NexoraDbContext CreateDbContext()
    {
        var options = new DbContextOptionsBuilder<NexoraDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        return new NexoraDbContext(options);
    }

    [Fact]
    public async Task IsFeatureEnabledAsync_WhenFlagNotPresent_ShouldDefaultToTrue()
    {
        var db = CreateDbContext();
        var service = new FeatureFlagService(db);

        var isEnabled = await service.IsFeatureEnabledAsync(FeatureKeys.Chat);

        isEnabled.Should().BeTrue();
    }

    [Fact]
    public async Task SetFeatureStateAsync_ShouldPersistStateAndToggle()
    {
        var db = CreateDbContext();
        var service = new FeatureFlagService(db);

        await service.SetFeatureStateAsync(FeatureKeys.Chat, false, "AdminUser");

        var isEnabled = await service.IsFeatureEnabledAsync(FeatureKeys.Chat);
        isEnabled.Should().BeFalse();

        var allFlags = await service.GetAllFeatureFlagsAsync();
        allFlags[FeatureKeys.Chat].Should().BeFalse();
        allFlags[FeatureKeys.AI].Should().BeTrue();
    }
}
