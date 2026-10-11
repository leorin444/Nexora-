using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Nexora.Domain.Chat;

namespace Nexora.Infrastructure.Persistence.Configurations;

public sealed class ChatMessageConfiguration : IEntityTypeConfiguration<ChatMessage>
{
    public void Configure(EntityTypeBuilder<ChatMessage> builder)
    {
        builder.ToTable("ChatMessages");
        builder.HasKey(m => m.Id);

        builder.Property(m => m.Content)
            .IsRequired()
            .HasMaxLength(4000);

        builder.Property(m => m.AttachmentUrl)
            .HasMaxLength(1000);

        builder.Property(m => m.AttachmentType)
            .HasMaxLength(50);

        builder.HasIndex(m => m.CoupleId);
        builder.HasIndex(m => m.SenderId);
        builder.HasIndex(m => new { m.CoupleId, m.SentAtUtc });
    }
}
