using MediatR;
using Microsoft.EntityFrameworkCore;
using Nexora.Application.Common.Interfaces;

namespace Nexora.Application.Reminders.Commands.CompleteReminder;

public sealed class CompleteReminderCommandHandler(
    INexoraDbContext dbContext,
    ICurrentUserService currentUser) : IRequestHandler<CompleteReminderCommand>
{
    public async Task Handle(CompleteReminderCommand request, CancellationToken cancellationToken)
    {
        var userId = currentUser.UserId
            ?? throw new UnauthorizedAccessException("User is not authenticated.");

        var reminder = await dbContext.Reminders
            .FirstOrDefaultAsync(r => r.Id == request.ReminderId && r.OwnerId == userId, cancellationToken)
            ?? throw new KeyNotFoundException("Reminder not found or access denied.");

        reminder.IsCompleted = true;
        reminder.CompletedAtUtc = DateTime.UtcNow;
        reminder.UpdatedAtUtc = DateTime.UtcNow;

        await dbContext.SaveChangesAsync(cancellationToken);
    }
}
