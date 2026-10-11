using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Nexora.Application.Calendar.Commands.CreateCalendarEvent;
using Nexora.Application.Calendar.Queries.GetCalendarEvents;
using Nexora.Application.Common.Interfaces;
using Nexora.Domain.Calendar;
using Nexora.Domain.Common;
using Nexora.Domain.Couples;
using Nexora.Infrastructure.Persistence;
using Xunit;

namespace Nexora.UnitTests.Calendar;

public class CalendarCommandTests
{
    private static NexoraDbContext CreateDb() =>
        new(new DbContextOptionsBuilder<NexoraDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options);

    private static MockCurrentUserService UserOf(Guid userId) => new(userId);
    private static MockRealtimeNotificationService RealtimeOf() => new();

    [Fact]
    public async Task CreateCalendarEvent_Personal_ShouldSaveWithOwnerId()
    {
        var db = CreateDb();
        var user = Guid.NewGuid();
        var realtime = RealtimeOf();
        var handler = new CreateCalendarEventCommandHandler(db, UserOf(user), realtime);

        var now = DateTime.UtcNow;
        var result = await handler.Handle(
            new CreateCalendarEventCommand("Dentist", "Checkup", "Clinic", now, now.AddHours(1), false, VisibilityLevel.Private),
            default);

        result.Should().NotBeNull();
        result.Title.Should().Be("Dentist");
        result.OwnerId.Should().Be(user);
        result.CoupleId.Should().BeNull();
        realtime.NotifiedCouples.Should().BeEmpty();
    }

    [Fact]
    public async Task CreateCalendarEvent_SharedWithCouple_ShouldBroadcastRealtime()
    {
        var db = CreateDb();
        var userA = Guid.NewGuid();
        var userB = Guid.NewGuid();
        var couple = new Couple
        {
            Partner1Id = userA,
            Partner2Id = userB,
            Status = CoupleStatus.Active
        };
        db.Couples.Add(couple);
        await db.SaveChangesAsync();

        var realtime = RealtimeOf();
        var handler = new CreateCalendarEventCommandHandler(db, UserOf(userA), realtime);

        var start = DateTime.UtcNow.AddDays(1);
        var end = start.AddHours(2);

        var result = await handler.Handle(
            new CreateCalendarEventCommand("Dinner Date", "Italian", "Downtown", start, end, false, VisibilityLevel.Shared),
            default);

        result.CoupleId.Should().Be(couple.Id);
        realtime.NotifiedCouples.Should().Contain(couple.Id);
    }

    [Fact]
    public async Task GetCalendarEvents_ShouldIncludePartnerShared_ButExcludePartnerPrivate()
    {
        var db = CreateDb();
        var userA = Guid.NewGuid();
        var userB = Guid.NewGuid();
        var couple = new Couple
        {
            Partner1Id = userA,
            Partner2Id = userB,
            Status = CoupleStatus.Active
        };
        db.Couples.Add(couple);

        var now = DateTime.UtcNow;

        // User A's private event
        db.CalendarEvents.Add(new CalendarEvent
        {
            OwnerId = userA,
            Title = "User A Private",
            StartTimeUtc = now,
            EndTimeUtc = now.AddHours(1),
            Visibility = VisibilityLevel.Private
        });

        // User B's private event
        db.CalendarEvents.Add(new CalendarEvent
        {
            OwnerId = userB,
            Title = "User B Secret Diary",
            StartTimeUtc = now,
            EndTimeUtc = now.AddHours(1),
            Visibility = VisibilityLevel.Private
        });

        // User B's shared event
        db.CalendarEvents.Add(new CalendarEvent
        {
            OwnerId = userB,
            CoupleId = couple.Id,
            Title = "Movie Night",
            StartTimeUtc = now.AddHours(2),
            EndTimeUtc = now.AddHours(4),
            Visibility = VisibilityLevel.Shared
        });

        await db.SaveChangesAsync();

        var queryHandler = new GetCalendarEventsQueryHandler(db, UserOf(userA));
        var events = await queryHandler.Handle(
            new GetCalendarEventsQuery(now.AddDays(-1), now.AddDays(1)),
            default);

        events.Should().HaveCount(2);
        events.Select(e => e.Title).Should().Contain("User A Private");
        events.Select(e => e.Title).Should().Contain("Movie Night");
        events.Select(e => e.Title).Should().NotContain("User B Secret Diary");
    }
}

internal sealed class MockCurrentUserService(Guid userId) : Nexora.Application.Common.Interfaces.ICurrentUserService
{
    public Guid? UserId => userId;
    public bool IsAuthenticated => true;
}

internal sealed class MockRealtimeNotificationService : IRealtimeNotificationService
{
    public List<Guid> NotifiedCouples { get; } = [];
    public List<Guid> NotifiedUsers { get; } = [];

    public Task NotifyCoupleAsync(Guid coupleId, string method, object payload, CancellationToken cancellationToken = default)
    {
        NotifiedCouples.Add(coupleId);
        return Task.CompletedTask;
    }

    public Task NotifyUserAsync(Guid userId, string method, object payload, CancellationToken cancellationToken = default)
    {
        NotifiedUsers.Add(userId);
        return Task.CompletedTask;
    }
}
