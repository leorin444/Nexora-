using Nexora.Domain.Common;

namespace Nexora.Domain.Notes;

/// <summary>
/// A personal note created by a user.
/// Visibility determines who can access it — enforced server-side.
/// </summary>
public sealed class Note
{
    public Guid Id { get; set; } = Guid.NewGuid();

    /// <summary>The user who owns this note. Resolved by the backend — never trusted from client.</summary>
    public Guid OwnerId { get; set; }

    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public bool IsPinned { get; set; } = false;
    public VisibilityLevel Visibility { get; set; } = VisibilityLevel.Private;
    public bool IsArchived { get; set; } = false;

    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAtUtc { get; set; } = DateTime.UtcNow;
}
