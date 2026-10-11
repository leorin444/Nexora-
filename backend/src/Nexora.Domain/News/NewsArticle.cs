namespace Nexora.Domain.News;

public enum NewsCategory
{
    Technology = 0,
    ArtificialIntelligence = 1,
    Business = 2,
    Science = 3,
    World = 4,
    Health = 5,
    Lifestyle = 6
}

public sealed class NewsArticle
{
    public Guid Id { get; set; } = Guid.NewGuid();

    /// <summary>Unique URL or canonical identifier to ensure deduplication.</summary>
    public string Url { get; set; } = string.Empty;

    public string Title { get; set; } = string.Empty;
    public string Summary { get; set; } = string.Empty;
    public string? Content { get; set; }

    public string SourceName { get; set; } = string.Empty;
    public string? ImageUrl { get; set; }

    public NewsCategory Category { get; set; } = NewsCategory.Technology;

    /// <summary>Calculated curation score (based on recency, relevance, engagement).</summary>
    public double CurationScore { get; set; } = 0.0;

    /// <summary>Whether this article is curated in the Top 10 digest.</summary>
    public bool IsTopStory { get; set; } = false;

    public DateTime PublishedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime IngestedAtUtc { get; set; } = DateTime.UtcNow;
}
