using MediatR;
using Microsoft.EntityFrameworkCore;
using Nexora.Application.Common.Interfaces;
using Nexora.Application.Search.DTOs;
using Nexora.Domain.Common;
using Nexora.Domain.Couples;

namespace Nexora.Application.Search.Queries.UnifiedSearch;

public sealed record UnifiedSearchQuery(string Query, int LimitPerCategory = 5) : IRequest<UnifiedSearchResponse>;

public sealed class UnifiedSearchQueryHandler(
    INexoraDbContext dbContext,
    ICurrentUserService currentUser) : IRequestHandler<UnifiedSearchQuery, UnifiedSearchResponse>
{
    public async Task<UnifiedSearchResponse> Handle(UnifiedSearchQuery request, CancellationToken cancellationToken)
    {
        var userId = currentUser.UserId
            ?? throw new UnauthorizedAccessException("User is not authenticated.");

        if (string.IsNullOrWhiteSpace(request.Query))
        {
            return new UnifiedSearchResponse(string.Empty, 0, []);
        }

        var term = request.Query.Trim().ToLower();
        var limit = Math.Clamp(request.LimitPerCategory, 1, 20);

        // Find active couple for partner visibility scoping
        var couple = await dbContext.Couples
            .AsNoTracking()
            .FirstOrDefaultAsync(c => (c.Partner1Id == userId || c.Partner2Id == userId) && c.Status == CoupleStatus.Active, cancellationToken);
        var partnerId = couple?.GetOtherPartnerId(userId);

        var results = new List<SearchResultDto>();

        // 1. Search Notes (personal or shared/partner-visible)
        var notes = await dbContext.Notes
            .AsNoTracking()
            .Where(n => n.OwnerId == userId && (n.Title.ToLower().Contains(term) || n.Content.ToLower().Contains(term)))
            .OrderByDescending(n => n.UpdatedAtUtc)
            .Take(limit)
            .Select(n => new SearchResultDto(
                n.Id,
                n.Title,
                n.Content.Length > 120 ? n.Content.Substring(0, 120) + "..." : n.Content,
                SearchResultType.Note,
                n.Visibility.ToString(),
                n.UpdatedAtUtc))
            .ToListAsync(cancellationToken);
        results.AddRange(notes);

        // 2. Search Reminders
        var reminders = await dbContext.Reminders
            .AsNoTracking()
            .Where(r => r.OwnerId == userId && (r.Title.ToLower().Contains(term) || (r.Description != null && r.Description.ToLower().Contains(term))))
            .OrderByDescending(r => r.DueAtUtc)
            .Take(limit)
            .Select(r => new SearchResultDto(
                r.Id,
                r.Title,
                r.Description,
                SearchResultType.Reminder,
                r.IsCompleted ? "Completed" : "Pending",
                r.DueAtUtc))
            .ToListAsync(cancellationToken);
        results.AddRange(reminders);

        // 3. Search Calendar Events (personal or partner-visible/shared)
        var events = await dbContext.CalendarEvents
            .AsNoTracking()
            .Where(e => (e.OwnerId == userId || (partnerId.HasValue && e.OwnerId == partnerId.Value && e.Visibility != VisibilityLevel.Private)) &&
                        (e.Title.ToLower().Contains(term) || (e.Description != null && e.Description.ToLower().Contains(term))))
            .OrderByDescending(e => e.StartTimeUtc)
            .Take(limit)
            .Select(e => new SearchResultDto(
                e.Id,
                e.Title,
                e.Description,
                SearchResultType.CalendarEvent,
                e.Visibility.ToString(),
                e.StartTimeUtc))
            .ToListAsync(cancellationToken);
        results.AddRange(events);

        // 4. Search Knowledge Vault (personal or partner-visible/shared)
        var vaultItems = await dbContext.VaultItems
            .AsNoTracking()
            .Where(v => (v.OwnerId == userId || (partnerId.HasValue && v.OwnerId == partnerId.Value && v.Visibility != VisibilityLevel.Private)) &&
                        (v.Title.ToLower().Contains(term) || (v.Description != null && v.Description.ToLower().Contains(term)) || (v.Tags != null && v.Tags.ToLower().Contains(term))))
            .OrderByDescending(v => v.UpdatedAtUtc)
            .Take(limit)
            .Select(v => new SearchResultDto(
                v.Id,
                v.Title,
                v.Description,
                SearchResultType.VaultItem,
                v.Tags,
                v.UpdatedAtUtc))
            .ToListAsync(cancellationToken);
        results.AddRange(vaultItems);

        // 5. Search Public News Articles
        var news = await dbContext.NewsArticles
            .AsNoTracking()
            .Where(a => a.Title.ToLower().Contains(term) || a.Summary.ToLower().Contains(term))
            .OrderByDescending(a => a.PublishedAtUtc)
            .Take(limit)
            .Select(a => new SearchResultDto(
                a.Id,
                a.Title,
                a.Summary,
                SearchResultType.NewsArticle,
                a.Category.ToString(),
                a.PublishedAtUtc))
            .ToListAsync(cancellationToken);
        results.AddRange(news);

        return new UnifiedSearchResponse(
            request.Query,
            results.Count,
            results.OrderByDescending(r => r.TimestampUtc).ToList());
    }
}
