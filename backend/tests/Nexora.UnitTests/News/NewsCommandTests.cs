using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Nexora.Application.News.Commands.IngestNewsArticle;
using Nexora.Application.News.Queries.GetNewsArticles;
using Nexora.Domain.News;
using Nexora.Infrastructure.Persistence;
using Xunit;

namespace Nexora.UnitTests.News;

public class NewsCommandTests
{
    private static NexoraDbContext CreateDb() =>
        new(new DbContextOptionsBuilder<NexoraDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options);

    [Fact]
    public async Task IngestNewsArticle_ShouldSave_AndDeduplicateByUrl()
    {
        var db = CreateDb();
        var handler = new IngestNewsArticleCommandHandler(db);

        var first = await handler.Handle(
            new IngestNewsArticleCommand(
                "https://techcrunch.com/article1",
                "New AI Breakthrough",
                "Summary 1",
                "Content 1",
                "TechCrunch",
                null,
                NewsCategory.ArtificialIntelligence,
                5.0,
                true,
                DateTime.UtcNow),
            default);

        first.Should().NotBeNull();
        first.Title.Should().Be("New AI Breakthrough");

        // Duplicate ingestion with same URL
        var second = await handler.Handle(
            new IngestNewsArticleCommand(
                "https://techcrunch.com/article1",
                "Duplicate Article Attempt",
                "Summary 2",
                "Content 2",
                "TechCrunch",
                null,
                NewsCategory.ArtificialIntelligence,
                8.0,
                true,
                DateTime.UtcNow),
            default);

        // Deduplication ensures only 1 entity exists in database
        var count = await db.NewsArticles.CountAsync();
        count.Should().Be(1);

        // Curation score updated to higher score
        second.CurationScore.Should().Be(8.0);
    }

    [Fact]
    public async Task GetNewsArticles_ShouldFilterByCategory_AndRankByTopStories()
    {
        var db = CreateDb();
        db.NewsArticles.AddRange(
            new NewsArticle
            {
                Url = "https://news.com/tech-standard",
                Title = "Regular Tech News",
                Summary = "Summary",
                SourceName = "Source",
                Category = NewsCategory.Technology,
                CurationScore = 2.0,
                IsTopStory = false,
                PublishedAtUtc = DateTime.UtcNow.AddHours(-2)
            },
            new NewsArticle
            {
                Url = "https://news.com/tech-top",
                Title = "Top Tech Headline",
                Summary = "Summary",
                SourceName = "Source",
                Category = NewsCategory.Technology,
                CurationScore = 10.0,
                IsTopStory = true,
                PublishedAtUtc = DateTime.UtcNow.AddHours(-1)
            },
            new NewsArticle
            {
                Url = "https://news.com/science-top",
                Title = "Top Science Discovery",
                Summary = "Summary",
                SourceName = "Source",
                Category = NewsCategory.Science,
                CurationScore = 9.0,
                IsTopStory = true,
                PublishedAtUtc = DateTime.UtcNow
            });
        await db.SaveChangesAsync();

        var handler = new GetNewsArticlesQueryHandler(db);

        // Filter by Technology
        var techArticles = await handler.Handle(new GetNewsArticlesQuery(Category: NewsCategory.Technology), default);
        techArticles.Should().HaveCount(2);
        techArticles.First().Title.Should().Be("Top Tech Headline");

        // Filter by Top Stories
        var topArticles = await handler.Handle(new GetNewsArticlesQuery(TopStoriesOnly: true), default);
        topArticles.Should().HaveCount(2);
        topArticles.Select(a => a.Title).Should().Contain("Top Tech Headline");
        topArticles.Select(a => a.Title).Should().Contain("Top Science Discovery");
    }

    [Fact]
    public async Task IngestNewsArticle_ShouldThrow_WhenUrlIsEmpty()
    {
        var db = CreateDb();
        var handler = new IngestNewsArticleCommandHandler(db);

        var act = () => handler.Handle(
            new IngestNewsArticleCommand("", "Title", "Summary", null, "Source", null, NewsCategory.Technology, 1.0, false, DateTime.UtcNow),
            default);

        await act.Should().ThrowAsync<ArgumentException>().WithMessage("*Url*");
    }
}
