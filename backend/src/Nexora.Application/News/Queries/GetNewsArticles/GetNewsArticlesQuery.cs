using MediatR;
using Microsoft.EntityFrameworkCore;
using Nexora.Application.Common.Interfaces;
using Nexora.Application.News.Commands.IngestNewsArticle;
using Nexora.Application.News.DTOs;
using Nexora.Domain.News;

namespace Nexora.Application.News.Queries.GetNewsArticles;

public sealed record GetNewsArticlesQuery(
    NewsCategory? Category = null,
    bool TopStoriesOnly = false,
    int Limit = 20) : IRequest<IList<NewsArticleDto>>;

public sealed class GetNewsArticlesQueryHandler(
    INexoraDbContext dbContext) : IRequestHandler<GetNewsArticlesQuery, IList<NewsArticleDto>>
{
    public async Task<IList<NewsArticleDto>> Handle(GetNewsArticlesQuery request, CancellationToken cancellationToken)
    {
        var query = dbContext.NewsArticles.AsNoTracking();

        if (request.Category.HasValue)
        {
            query = query.Where(a => a.Category == request.Category.Value);
        }

        if (request.TopStoriesOnly)
        {
            query = query.Where(a => a.IsTopStory);
        }

        var limit = Math.Clamp(request.Limit, 1, 50);

        var articles = await query
            .OrderByDescending(a => a.IsTopStory)
            .ThenByDescending(a => a.CurationScore)
            .ThenByDescending(a => a.PublishedAtUtc)
            .Take(limit)
            .ToListAsync(cancellationToken);

        return articles.Select(IngestNewsArticleCommandHandler.MapToDto).ToList();
    }
}
