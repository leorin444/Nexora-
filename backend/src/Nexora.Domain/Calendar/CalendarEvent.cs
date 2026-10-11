using Nexora.Domain.Common;

namespace Nexora.Domain.Calendar;

public sealed class CalendarEvent
{
    public Guid Id { get; set; } = Guid.NewGuid();

    /// <summary>Owner/Creator of the event. Resolved by backend from JWT.</summary>
    public Guid OwnerId { get; set; }

    /// <summary>Associated couple ID if event is couple-scoped.</summary>
    public Guid? CoupleId { get; set; }

    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? Location { get; set; }

    public DateTime StartTimeUtc { get; set; }
    public DateTime EndTimeUtc { get; set; }
    public bool IsAllDay { get; set; } = false;

    /// <summary>Privacy level: Private, Shared, or PartnerVisible.</summary>
    public VisibilityLevel Visibility { get; set; } = VisibilityLevel.Private;

    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAtUtc { get; set; } = DateTime.UtcNow;
}
