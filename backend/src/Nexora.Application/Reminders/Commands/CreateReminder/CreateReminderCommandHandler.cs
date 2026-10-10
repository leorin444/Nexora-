using MediatR;
using Nexora.Application.Common.Interfaces;
using Nexora.Application.Reminders.DTOs;
using Nexora.Domain.Reminders;

namespace Nexora.Application.Reminders.Commands.CreateReminder;

public sealed class CreateReminderCommandHandler(
    INexoraDbContext dbContext,
    ICurrentUserService currentUser) : IRequestHandler<CreateReminderCommand, ReminderDto>
{
    public async Task<ReminderDto> Handle(CreateReminderCommand request, CancellationToken cancellationToken)
    {
        var userId = currentUser.UserId
            ?? throw new UnauthorizedAccessException("User is not authenticated.");

        var reminder = new Reminder
        {
            OwnerId = userId,
            Title = request.Title,
            Description = request.Description,
            DueAtUtc = request.DueAtUtc,
            Recurrence = request.Recurrence,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };

        dbContext.Reminders.Add(reminder);
        await dbContext.SaveChangesAsync(cancellationToken);

        return MapToDto(reminder);
    }

    internal static ReminderDto MapToDto(Reminder r) => new(
        r.Id, r.Title, r.Description, r.DueAtUtc,
        r.IsCompleted, r.CompletedAtUtc, r.Recurrence,
        r.CreatedAtUtc, r.UpdatedAtUtc);
}
