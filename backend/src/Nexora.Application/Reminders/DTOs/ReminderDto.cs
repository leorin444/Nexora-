using Nexora.Domain.Reminders;

namespace Nexora.Application.Reminders.DTOs;

public sealed record ReminderDto(
    Guid Id,
    string Title,
    string? Description,
    DateTime DueAtUtc,
    bool IsCompleted,
    DateTime? CompletedAtUtc,
    RecurrenceType Recurrence,
    DateTime CreatedAtUtc,
    DateTime UpdatedAtUtc);
