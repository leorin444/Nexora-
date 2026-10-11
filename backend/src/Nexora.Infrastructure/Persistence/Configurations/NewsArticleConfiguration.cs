using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Nexora.Domain.News;

namespace Nexora.Infrastructure.Persistence.Configurations;

public sealed class NewsArticleConfiguration : IEntityTypeConfiguration<NewsArticle>
{
    public void Configure(EntityTypeBuilder<NewsArticle> builder)
    {
        builder.ToTable("NewsArticles");
        builder.HasKey(a => a.Id);

        builder.Property(a => a.Url)
            .IsRequired()
            .HasMaxLength(1000);

        builder.Property(a => a.Title)
            .IsRequired()
            .HasMaxLength(500);

        builder.Property(a => a.Summary)
            .HasMaxLength(2000);

        builder.Property(a => a.SourceName)
            .IsRequired()
            .HasMaxLength(150);

        builder.Property(a => a.ImageUrl)
            .HasMaxLength(1000);

        builder.HasIndex(a => a.Url).IsUnique();
        builder.HasIndex(a => a.Category);
        builder.HasIndex(a => a.IsTopStory);
        builder.HasIndex(a => new { a.IsTopStory, a.CurationScore, a.PublishedAtUtc });
    }
}
