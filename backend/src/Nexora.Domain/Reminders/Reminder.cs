namespace Nexora.Domain.Reminders;

/// <summary>
/// Recurrence pattern for a reminder.
/// </summary>
public enum RecurrenceType
{
    None = 0,
    Daily = 1,
    Weekly = 2,
    Monthly = 3,
    Yearly = 4
}

/// <summary>
/// A reminder created by a user — personal or couple-scoped.
/// </summary>
public sealed class Reminder
{
    public Guid Id { get; set; } = Guid.NewGuid();

    /// <summary>Resolved by backend from JWT claims — never from client input.</summary>
    public Guid OwnerId { get; set; }

    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }

    public DateTime DueAtUtc { get; set; }
    public bool IsCompleted { get; set; } = false;
    public DateTime? CompletedAtUtc { get; set; }

    public RecurrenceType Recurrence { get; set; } = RecurrenceType.None;

    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAtUtc { get; set; } = DateTime.UtcNow;
}
