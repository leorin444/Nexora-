using MediatR;
using Microsoft.EntityFrameworkCore;
using Nexora.Application.Calendar.Commands.CreateCalendarEvent;
using Nexora.Application.Calendar.DTOs;
using Nexora.Application.Common.Interfaces;
using Nexora.Domain.Common;
using Nexora.Domain.Couples;

namespace Nexora.Application.Calendar.Queries.GetCalendarEvents;

public sealed record GetCalendarEventsQuery(
    DateTime StartUtc,
    DateTime EndUtc) : IRequest<IList<CalendarEventDto>>;

public sealed class GetCalendarEventsQueryHandler(
    INexoraDbContext dbContext,
    ICurrentUserService currentUser) : IRequestHandler<GetCalendarEventsQuery, IList<CalendarEventDto>>
{
    public async Task<IList<CalendarEventDto>> Handle(GetCalendarEventsQuery request, CancellationToken cancellationToken)
    {
        var userId = currentUser.UserId
            ?? throw new UnauthorizedAccessException("User is not authenticated.");

        // Fetch user's active couple if any
        var couple = await dbContext.Couples
            .AsNoTracking()
            .FirstOrDefaultAsync(c => (c.Partner1Id == userId || c.Partner2Id == userId) && c.Status == CoupleStatus.Active, cancellationToken);

        var partnerId = couple?.GetOtherPartnerId(userId);

        // Security rule:
        // 1. All events owned by current user
        // 2. Events owned by partner that are Shared or PartnerVisible
        var query = dbContext.CalendarEvents
            .AsNoTracking()
            .Where(e => e.StartTimeUtc <= request.EndUtc && e.EndTimeUtc >= request.StartUtc)
            .Where(e =>
                e.OwnerId == userId ||
                (partnerId.HasValue && e.OwnerId == partnerId.Value && e.Visibility != VisibilityLevel.Private));

        var events = await query
            .OrderBy(e => e.StartTimeUtc)
            .ToListAsync(cancellationToken);

        return events.Select(CreateCalendarEventCommandHandler.MapToDto).ToList();
    }
}
