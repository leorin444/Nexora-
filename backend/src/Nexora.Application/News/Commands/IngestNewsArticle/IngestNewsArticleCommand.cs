using MediatR;
using Microsoft.EntityFrameworkCore;
using Nexora.Application.Common.Interfaces;
using Nexora.Application.News.DTOs;
using Nexora.Domain.News;

namespace Nexora.Application.News.Commands.IngestNewsArticle;

public sealed record IngestNewsArticleCommand(
    string Url,
    string Title,
    string Summary,
    string? Content,
    string SourceName,
    string? ImageUrl,
    NewsCategory Category,
    double CurationScore,
    bool IsTopStory,
    DateTime PublishedAtUtc) : IRequest<NewsArticleDto>;

public sealed class IngestNewsArticleCommandHandler(
    INexoraDbContext dbContext) : IRequestHandler<IngestNewsArticleCommand, NewsArticleDto>
{
    public async Task<NewsArticleDto> Handle(IngestNewsArticleCommand request, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.Url))
            throw new ArgumentException("Url is required.");

        if (string.IsNullOrWhiteSpace(request.Title))
            throw new ArgumentException("Title is required.");

        // Deduplication by URL
        var existing = await dbContext.NewsArticles
            .FirstOrDefaultAsync(a => a.Url == request.Url, cancellationToken);

        if (existing != null)
        {
            // Update curation score & top story flag if new data provides updates
            existing.CurationScore = Math.Max(existing.CurationScore, request.CurationScore);
            existing.IsTopStory = existing.IsTopStory || request.IsTopStory;
            await dbContext.SaveChangesAsync(cancellationToken);
            return MapToDto(existing);
        }

        var article = new NewsArticle
        {
            Url = request.Url,
            Title = request.Title,
            Summary = request.Summary,
            Content = request.Content,
            SourceName = request.SourceName,
            ImageUrl = request.ImageUrl,
            Category = request.Category,
            CurationScore = request.CurationScore,
            IsTopStory = request.IsTopStory,
            PublishedAtUtc = request.PublishedAtUtc,
            IngestedAtUtc = DateTime.UtcNow
        };

        dbContext.NewsArticles.Add(article);
        await dbContext.SaveChangesAsync(cancellationToken);

        return MapToDto(article);
    }

    internal static NewsArticleDto MapToDto(NewsArticle article) => new(
        article.Id,
        article.Url,
        article.Title,
        article.Summary,
        article.Content,
        article.SourceName,
        article.ImageUrl,
        article.Category,
        article.CurationScore,
        article.IsTopStory,
        article.PublishedAtUtc,
        article.IngestedAtUtc);
}
