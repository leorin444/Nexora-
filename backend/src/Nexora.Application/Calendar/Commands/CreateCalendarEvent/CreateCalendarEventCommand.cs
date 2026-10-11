using MediatR;
using Microsoft.EntityFrameworkCore;
using Nexora.Application.Calendar.DTOs;
using Nexora.Application.Common.Interfaces;
using Nexora.Domain.Calendar;
using Nexora.Domain.Common;
using Nexora.Domain.Couples;

namespace Nexora.Application.Calendar.Commands.CreateCalendarEvent;

public sealed record CreateCalendarEventCommand(
    string Title,
    string? Description,
    string? Location,
    DateTime StartTimeUtc,
    DateTime EndTimeUtc,
    bool IsAllDay,
    VisibilityLevel Visibility) : IRequest<CalendarEventDto>;

public sealed class CreateCalendarEventCommandHandler(
    INexoraDbContext dbContext,
    ICurrentUserService currentUser,
    IRealtimeNotificationService realtime) : IRequestHandler<CreateCalendarEventCommand, CalendarEventDto>
{
    public async Task<CalendarEventDto> Handle(CreateCalendarEventCommand request, CancellationToken cancellationToken)
    {
        var userId = currentUser.UserId
            ?? throw new UnauthorizedAccessException("User is not authenticated.");

        if (request.EndTimeUtc < request.StartTimeUtc)
        {
            throw new ArgumentException("End time must be after start time.");
        }

        Guid? coupleId = null;
        if (request.Visibility != VisibilityLevel.Private)
        {
            // Verify active couple membership if sharing with partner
            var couple = await dbContext.Couples
                .AsNoTracking()
                .FirstOrDefaultAsync(c => (c.Partner1Id == userId || c.Partner2Id == userId) && c.Status == CoupleStatus.Active, cancellationToken);

            coupleId = couple?.Id;
        }

        var calendarEvent = new CalendarEvent
        {
            OwnerId = userId,
            CoupleId = coupleId,
            Title = request.Title,
            Description = request.Description,
            Location = request.Location,
            StartTimeUtc = request.StartTimeUtc,
            EndTimeUtc = request.EndTimeUtc,
            IsAllDay = request.IsAllDay,
            Visibility = request.Visibility,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };

        dbContext.CalendarEvents.Add(calendarEvent);
        await dbContext.SaveChangesAsync(cancellationToken);

        var dto = MapToDto(calendarEvent);

        // Realtime notification if couple-shared
        if (coupleId.HasValue)
        {
            await realtime.NotifyCoupleAsync(coupleId.Value, "CalendarEventCreated", dto, cancellationToken);
        }

        return dto;
    }

    internal static CalendarEventDto MapToDto(CalendarEvent e) => new(
        e.Id,
        e.OwnerId,
        e.CoupleId,
        e.Title,
        e.Description,
        e.Location,
        e.StartTimeUtc,
        e.EndTimeUtc,
        e.IsAllDay,
        e.Visibility,
        e.CreatedAtUtc,
        e.UpdatedAtUtc);
}
