using Nexora.Domain.Common;

namespace Nexora.Domain.Vault;

public enum VaultItemType
{
    Document = 0,
    Secret = 1,
    Card = 2,
    Custom = 3
}

public sealed class VaultItem
{
    public Guid Id { get; set; } = Guid.NewGuid();

    /// <summary>Owner/Creator of the vault item. Resolved by backend from JWT.</summary>
    public Guid OwnerId { get; set; }

    /// <summary>Associated couple ID if item is shared or partner visible.</summary>
    public Guid? CoupleId { get; set; }

    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }

    public VaultItemType ItemType { get; set; } = VaultItemType.Document;

    /// <summary>Encrypted or protected content/data payload.</summary>
    public string EncryptedPayload { get; set; } = string.Empty;

    /// <summary>Optional tags for category lookup, comma-separated or JSON list.</summary>
    public string? Tags { get; set; }

    /// <summary>Privacy level: Private, Shared, or PartnerVisible.</summary>
    public VisibilityLevel Visibility { get; set; } = VisibilityLevel.Private;

    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAtUtc { get; set; } = DateTime.UtcNow;
}
