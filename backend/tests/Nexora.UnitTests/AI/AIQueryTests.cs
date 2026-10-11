using FluentAssertions;
using Microsoft.Extensions.Logging.Abstractions;
using Nexora.Application.AI.Queries.AskAI;
using Nexora.Application.AI.Queries.CommunicationCoach;
using Nexora.Application.Common.Interfaces;
using Nexora.Infrastructure.AI;
using Xunit;

namespace Nexora.UnitTests.AI;

public class AIQueryTests
{
    private static MockCurrentUserService AuthUser() => new(Guid.NewGuid());

    [Fact]
    public async Task NullAIProvider_ShouldReturnFallback_WhenAIDisabled()
    {
        var logger = NullLogger<NullAIProvider>.Instance;
        var provider = new NullAIProvider(logger);

        provider.IsAvailable.Should().BeFalse();
        provider.ProviderName.Should().Contain("Null");

        var response = await provider.CompleteAsync("hello");
        response.Should().Contain("unavailable");
    }

    [Fact]
    public async Task AskAIQuery_ShouldReturnResponse_WithNullProvider()
    {
        var logger = NullLogger<NullAIProvider>.Instance;
        var provider = new NullAIProvider(logger);
        var handler = new AskAIQueryHandler(provider, AuthUser());

        var result = await handler.Handle(new AskAIQuery("How can I be a better partner?"), default);

        result.Should().NotBeNull();
        result.Answer.Should().Contain("unavailable");
        result.Provider.Should().Contain("Null");
        result.IsAvailable.Should().BeFalse();
    }

    [Fact]
    public async Task CommunicationCoach_ShouldReturnFallback_WhenAIDisabled()
    {
        var logger = NullLogger<NullAIProvider>.Instance;
        var provider = new NullAIProvider(logger);
        var handler = new CommunicationCoachQueryHandler(provider, AuthUser());

        var result = await handler.Handle(new CommunicationCoachQuery("You never listen to me!"), default);

        result.Should().NotBeNull();
        result.Suggestion.Should().Contain("unavailable");
        result.Provider.Should().Contain("Null");
        result.IsAvailable.Should().BeFalse();
    }

    [Fact]
    public async Task AskAIQuery_ShouldThrow_WhenPromptEmpty()
    {
        var logger = NullLogger<NullAIProvider>.Instance;
        var provider = new NullAIProvider(logger);
        var handler = new AskAIQueryHandler(provider, AuthUser());

        var act = () => handler.Handle(new AskAIQuery(""), default);
        await act.Should().ThrowAsync<ArgumentException>().WithMessage("*Prompt*");
    }
}

internal sealed class MockCurrentUserService(Guid userId) : ICurrentUserService
{
    public Guid? UserId => userId;
    public bool IsAuthenticated => true;
}
