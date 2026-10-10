using MediatR;

namespace Nexora.Application.Reminders.Commands.CompleteReminder;

public sealed record CompleteReminderCommand(Guid ReminderId) : IRequest;
