using MediatR;
using Nexora.Application.Reminders.DTOs;
using Nexora.Domain.Reminders;

namespace Nexora.Application.Reminders.Commands.CreateReminder;

public sealed record CreateReminderCommand(
    string Title,
    string? Description,
    DateTime DueAtUtc,
    RecurrenceType Recurrence) : IRequest<ReminderDto>;
