using MediatR;
using Microsoft.EntityFrameworkCore;
using Nexora.Application.Common.Interfaces;
using Nexora.Application.Reminders.Commands.CreateReminder;
using Nexora.Application.Reminders.DTOs;

namespace Nexora.Application.Reminders.Queries.GetReminders;

public sealed class GetRemindersQueryHandler(
    INexoraDbContext dbContext,
    ICurrentUserService currentUser) : IRequestHandler<GetRemindersQuery, IList<ReminderDto>>
{
    public async Task<IList<ReminderDto>> Handle(GetRemindersQuery request, CancellationToken cancellationToken)
    {
        var userId = currentUser.UserId
            ?? throw new UnauthorizedAccessException("User is not authenticated.");

        var query = dbContext.Reminders
            .AsNoTracking()
            .Where(r => r.OwnerId == userId);

        if (!request.IncludeCompleted)
            query = query.Where(r => !r.IsCompleted);

        return await query
            .OrderBy(r => r.DueAtUtc)
            .Select(r => CreateReminderCommandHandler.MapToDto(r))
            .ToListAsync(cancellationToken);
    }
}
