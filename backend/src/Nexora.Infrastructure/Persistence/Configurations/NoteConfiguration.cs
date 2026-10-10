using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Nexora.Domain.Notes;

namespace Nexora.Infrastructure.Persistence.Configurations;

public sealed class NoteConfiguration : IEntityTypeConfiguration<Note>
{
    public void Configure(EntityTypeBuilder<Note> builder)
    {
        builder.ToTable("Notes");
        builder.HasKey(n => n.Id);

        builder.Property(n => n.Title)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(n => n.Content)
            .HasMaxLength(10000);

        builder.Property(n => n.Visibility)
            .IsRequired();

        builder.HasIndex(n => n.OwnerId);
        builder.HasIndex(n => new { n.OwnerId, n.IsArchived });
    }
}
