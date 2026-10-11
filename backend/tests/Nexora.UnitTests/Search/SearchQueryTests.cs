using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Nexora.Application.Common.Interfaces;
using Nexora.Application.Search.DTOs;
using Nexora.Application.Search.Queries.UnifiedSearch;
using Nexora.Domain.Calendar;
using Nexora.Domain.Common;
using Nexora.Domain.Couples;
using Nexora.Domain.News;
using Nexora.Domain.Notes;
using Nexora.Domain.Reminders;
using Nexora.Infrastructure.Persistence;
using Xunit;

namespace Nexora.UnitTests.Search;

public class SearchQueryTests
{
    private static NexoraDbContext CreateDb() =>
        new(new DbContextOptionsBuilder<NexoraDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options);

    private static MockCurrentUserService UserOf(Guid userId) => new(userId);

    [Fact]
    public async Task UnifiedSearch_ShouldAggregateAcrossMultipleDomains()
    {
        var db = CreateDb();
        var user = Guid.NewGuid();

        db.Notes.Add(new Note
        {
            OwnerId = user,
            Title = "Trip to Paris Planning",
            Content = "Packing list for Paris vacation"
        });

        db.Reminders.Add(new Reminder
        {
            OwnerId = user,
            Title = "Book Paris museum tickets",
            Description = "Louvre and Orsay",
            DueAtUtc = DateTime.UtcNow.AddDays(2)
        });

        db.NewsArticles.Add(new NewsArticle
        {
            Url = "https://news.com/paris-2026",
            Title = "Paris Travel Guide 2026",
            Summary = "Top spots to visit in Paris",
            SourceName = "TravelDaily",
            Category = NewsCategory.Lifestyle
        });

        await db.SaveChangesAsync();

        var handler = new UnifiedSearchQueryHandler(db, UserOf(user));
        var response = await handler.Handle(new UnifiedSearchQuery("Paris"), default);

        response.Should().NotBeNull();
        response.TotalCount.Should().Be(3);
        response.Results.Should().Contain(r => r.ResultType == SearchResultType.Note);
        response.Results.Should().Contain(r => r.ResultType == SearchResultType.Reminder);
        response.Results.Should().Contain(r => r.ResultType == SearchResultType.NewsArticle);
    }

    [Fact]
    public async Task UnifiedSearch_ShouldRespectPartnerPrivacyBoundaries()
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

        // Partner B's private event
        db.CalendarEvents.Add(new CalendarEvent
        {
            OwnerId = userB,
            Title = "Surprise Birthday Party for User A",
            Visibility = VisibilityLevel.Private,
            StartTimeUtc = DateTime.UtcNow.AddDays(7),
            EndTimeUtc = DateTime.UtcNow.AddDays(7).AddHours(2)
        });

        // Partner B's shared event
        db.CalendarEvents.Add(new CalendarEvent
        {
            OwnerId = userB,
            CoupleId = couple.Id,
            Title = "Shared Dinner with Friends",
            Visibility = VisibilityLevel.Shared,
            StartTimeUtc = DateTime.UtcNow.AddDays(3),
            EndTimeUtc = DateTime.UtcNow.AddDays(3).AddHours(2)
        });

        await db.SaveChangesAsync();

        var handler = new UnifiedSearchQueryHandler(db, UserOf(userA));
        var response = await handler.Handle(new UnifiedSearchQuery("Party"), default);

        // User A should NOT see User B's private surprise party
        response.Results.Should().BeEmpty();

        var responseDinner = await handler.Handle(new UnifiedSearchQuery("Dinner"), default);
        responseDinner.Results.Should().HaveCount(1);
        responseDinner.Results.First().Title.Should().Be("Shared Dinner with Friends");
    }

    [Fact]
    public async Task UnifiedSearch_ShouldReturnEmpty_WhenQueryIsBlank()
    {
        var db = CreateDb();
        var user = Guid.NewGuid();
        var handler = new UnifiedSearchQueryHandler(db, UserOf(user));

        var response = await handler.Handle(new UnifiedSearchQuery("   "), default);
        response.TotalCount.Should().Be(0);
        response.Results.Should().BeEmpty();
    }
}

internal sealed class MockCurrentUserService(Guid userId) : ICurrentUserService
{
    public Guid? UserId => userId;
    public bool IsAuthenticated => true;
}
