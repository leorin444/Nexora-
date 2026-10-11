using Nexora.Domain.Common;

namespace Nexora.Application.Calendar.DTOs;

public sealed record CalendarEventDto(
    Guid Id,
    Guid OwnerId,
    Guid? CoupleId,
    string Title,
    string? Description,
    string? Location,
    DateTime StartTimeUtc,
    DateTime EndTimeUtc,
    bool IsAllDay,
    VisibilityLevel Visibility,
    DateTime CreatedAtUtc,
    DateTime UpdatedAtUtc);
