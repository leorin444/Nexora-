using Microsoft.Extensions.Logging;
using Nexora.Application.AI;

namespace Nexora.Infrastructure.AI;

/// <summary>
/// Null-pattern AI provider that returns a graceful fallback when
/// no real AI service is configured or reachable.
/// Guarantees the system is fully usable without AI.
/// </summary>
public sealed class NullAIProvider(ILogger<NullAIProvider> logger) : IAIProvider
{
    public bool IsAvailable => false;

    public string ProviderName => "Null (AI Disabled)";

    public Task<string> CompleteAsync(string prompt, CancellationToken cancellationToken = default)
    {
        logger.LogDebug("NullAIProvider invoked CompleteAsync — returning fallback.");
        return Task.FromResult("AI features are currently unavailable. Your request has been noted and the system continues to operate normally.");
    }

    public Task<string> SummarizeAsync(string content, CancellationToken cancellationToken = default)
    {
        logger.LogDebug("NullAIProvider invoked SummarizeAsync — returning empty.");
        return Task.FromResult(string.Empty);
    }

    public Task<IReadOnlyList<string>> TagAsync(string content, CancellationToken cancellationToken = default)
    {
        logger.LogDebug("NullAIProvider invoked TagAsync — returning empty list.");
        return Task.FromResult<IReadOnlyList<string>>([]);
    }

    public Task<string> ImproveCommunicationAsync(string text, string context, CancellationToken cancellationToken = default)
    {
        logger.LogDebug("NullAIProvider invoked ImproveCommunicationAsync — returning fallback.");
        return Task.FromResult("AI communication coaching is currently unavailable. Your original message remains unchanged.");
    }
}
