namespace Nexora.Domain.Features;

/// <summary>
/// Known platform feature keys.
/// Administrator can enable/disable these features centrally.
/// </summary>
public static class FeatureKeys
{
    public const string Chat = "Chat";
    public const string KnowledgeVault = "KnowledgeVault";
    public const string News = "News";
    public const string AI = "AI";
    public const string Music = "Music";
    public const string CommunicationCoach = "CommunicationCoach";
    public const string Countdown = "Countdown";
    public const string MenstrualCalendar = "MenstrualCalendar";

    public static readonly IReadOnlyList<string> All = new[]
    {
        Chat,
        KnowledgeVault,
        News,
        AI,
        Music,
        CommunicationCoach,
        Countdown,
        MenstrualCalendar
    };
}

/// <summary>
/// Persisted feature flag entity.
/// </summary>
public sealed class FeatureFlag
{
    public string Name { get; set; } = string.Empty;
    public bool IsEnabled { get; set; } = true;
    public string Description { get; set; } = string.Empty;
    public DateTime UpdatedAtUtc { get; set; } = DateTime.UtcNow;
    public string? UpdatedBy { get; set; }
}
