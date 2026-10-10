namespace Nexora.Domain.Couples;

public enum CoupleStatus
{
    Active = 0,
    Paused = 1,
    Ended = 2
}

/// <summary>
/// Represents a couple relationship between exactly two users.
/// Security rule: A user can only belong to ONE active couple at any time.
/// </summary>
public sealed class Couple
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid Partner1Id { get; set; }
    public Guid Partner2Id { get; set; }

    public CoupleStatus Status { get; set; } = CoupleStatus.Active;

    public DateTime ConnectedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime? EndedAtUtc { get; set; }

    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAtUtc { get; set; } = DateTime.UtcNow;

    public bool HasPartner(Guid userId) => Partner1Id == userId || Partner2Id == userId;

    public Guid GetOtherPartnerId(Guid userId)
    {
        if (Partner1Id == userId) return Partner2Id;
        if (Partner2Id == userId) return Partner1Id;
        throw new InvalidOperationException("User is not a member of this couple.");
    }
}
