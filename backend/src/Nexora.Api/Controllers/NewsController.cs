using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Nexora.Application.News.Commands.IngestNewsArticle;
using Nexora.Application.News.DTOs;
using Nexora.Application.News.Queries.GetNewsArticles;
using Nexora.Domain.News;

namespace Nexora.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public sealed class NewsController(IMediator mediator) : ControllerBase
{
    /// <summary>Get curated news articles with optional category and top-stories filters.</summary>
    [HttpGet]
    [ProducesResponseType(typeof(IList<NewsArticleDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetArticles(
        [FromQuery] NewsCategory? category = null,
        [FromQuery] bool topStoriesOnly = false,
        [FromQuery] int limit = 20,
        CancellationToken cancellationToken = default)
    {
        var articles = await mediator.Send(
            new GetNewsArticlesQuery(category, topStoriesOnly, limit),
            cancellationToken);

        return Ok(articles);
    }

    /// <summary>Ingest a new article (Admin or Background Ingestion Worker).</summary>
    [HttpPost("ingest")]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(typeof(NewsArticleDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> IngestArticle(
        [FromBody] IngestArticleRequest request,
        CancellationToken cancellationToken)
    {
        try
        {
            var result = await mediator.Send(
                new IngestNewsArticleCommand(
                    request.Url,
                    request.Title,
                    request.Summary,
                    request.Content,
                    request.SourceName,
                    request.ImageUrl,
                    request.Category,
                    request.CurationScore,
                    request.IsTopStory,
                    request.PublishedAtUtc ?? DateTime.UtcNow),
                cancellationToken);

            return StatusCode(StatusCodes.Status201Created, result);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { detail = ex.Message });
        }
    }
}

public sealed record IngestArticleRequest(
    string Url,
    string Title,
    string Summary,
    string? Content,
    string SourceName,
    string? ImageUrl,
    NewsCategory Category = NewsCategory.Technology,
    double CurationScore = 1.0,
    bool IsTopStory = false,
    DateTime? PublishedAtUtc = null);
