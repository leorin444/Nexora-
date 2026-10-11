using Nexora.Domain.News;

namespace Nexora.Application.News.DTOs;

public sealed record NewsArticleDto(
    Guid Id,
    string Url,
    string Title,
    string Summary,
    string? Content,
    string SourceName,
    string? ImageUrl,
    NewsCategory Category,
    double CurationScore,
    bool IsTopStory,
    DateTime PublishedAtUtc,
    DateTime IngestedAtUtc);
