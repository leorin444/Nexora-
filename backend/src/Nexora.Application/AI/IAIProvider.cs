namespace Nexora.Application.AI;

/// <summary>
/// Provider-independent AI abstraction.
/// All AI features in the application use this interface — never a specific provider SDK directly.
/// Implementations: CloudAIProvider, OllamaAIProvider, NullAIProvider (graceful fallback).
/// </summary>
public interface IAIProvider
{
    /// <summary>Whether this AI provider is currently available and configured.</summary>
    bool IsAvailable { get; }

    /// <summary>
    /// Generate a completion for a given prompt.
    /// Returns an empty string if the provider is unavailable rather than throwing.
    /// </summary>
    Task<string> CompleteAsync(string prompt, CancellationToken cancellationToken = default);

    /// <summary>
    /// Summarize the provided content.
    /// Returns an empty string if the provider is unavailable.
    /// </summary>
    Task<string> SummarizeAsync(string content, CancellationToken cancellationToken = default);

    /// <summary>
    /// Generate relevant tags for the provided content.
    /// Returns an empty list if the provider is unavailable.
    /// </summary>
    Task<IReadOnlyList<string>> TagAsync(string content, CancellationToken cancellationToken = default);

    /// <summary>
    /// Assist with communication — suggest improvements or alternative phrasings.
    /// Returns an empty string if the provider is unavailable.
    /// </summary>
    Task<string> ImproveCommunicationAsync(string text, string context, CancellationToken cancellationToken = default);
}
