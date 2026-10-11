namespace Nexora.Application.Search.DTOs;

public enum SearchResultType
{
    Note = 0,
    Reminder = 1,
    CalendarEvent = 2,
    VaultItem = 3,
    NewsArticle = 4
}

public sealed record SearchResultDto(
    Guid Id,
    string Title,
    string? Snippet,
    SearchResultType ResultType,
    string? CategoryOrTag,
    DateTime TimestampUtc);

public sealed record UnifiedSearchResponse(
    string Query,
    int TotalCount,
    IList<SearchResultDto> Results);
