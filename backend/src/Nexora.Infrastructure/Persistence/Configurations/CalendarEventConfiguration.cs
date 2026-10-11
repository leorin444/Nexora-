using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Nexora.Domain.Calendar;

namespace Nexora.Infrastructure.Persistence.Configurations;

public sealed class CalendarEventConfiguration : IEntityTypeConfiguration<CalendarEvent>
{
    public void Configure(EntityTypeBuilder<CalendarEvent> builder)
    {
        builder.ToTable("CalendarEvents");
        builder.HasKey(e => e.Id);

        builder.Property(e => e.Title)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(e => e.Description)
            .HasMaxLength(2000);

        builder.Property(e => e.Location)
            .HasMaxLength(300);

        builder.HasIndex(e => e.OwnerId);
        builder.HasIndex(e => e.CoupleId);
        builder.HasIndex(e => new { e.StartTimeUtc, e.EndTimeUtc });
        builder.HasIndex(e => new { e.OwnerId, e.StartTimeUtc });
    }
}
