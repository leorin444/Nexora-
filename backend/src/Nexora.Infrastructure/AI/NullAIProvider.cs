using Nexora.Application.AI;
using Microsoft.Extensions.Logging;

namespace Nexora.Infrastructure.AI;

/// <summary>
/// Null (no-op) AI provider used when no AI provider is configured or available.
/// Ensures the application continues to function gracefully without AI.
/// </summary>
internal sealed class NullAIProvider(ILogger<NullAIProvider> logger) : IAIProvider
{
    public bool IsAvailable => false;

    public Task<string> CompleteAsync(string prompt, CancellationToken cancellationToken = default)
    {
        logger.LogDebug("NullAIProvider: CompleteAsync called — AI not configured.");
        return Task.FromResult(string.Empty);
    }

    public Task<string> SummarizeAsync(string content, CancellationToken cancellationToken = default)
    {
        logger.LogDebug("NullAIProvider: SummarizeAsync called — AI not configured.");
        return Task.FromResult(string.Empty);
    }

    public Task<IReadOnlyList<string>> TagAsync(string content, CancellationToken cancellationToken = default)
    {
        logger.LogDebug("NullAIProvider: TagAsync called — AI not configured.");
        return Task.FromResult<IReadOnlyList<string>>([]);
    }

    public Task<string> ImproveCommunicationAsync(string text, string context, CancellationToken cancellationToken = default)
    {
        logger.LogDebug("NullAIProvider: ImproveCommunicationAsync called — AI not configured.");
        return Task.FromResult(string.Empty);
    }
}
