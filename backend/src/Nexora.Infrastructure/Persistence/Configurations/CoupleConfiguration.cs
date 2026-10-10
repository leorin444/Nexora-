using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Nexora.Domain.Couples;

namespace Nexora.Infrastructure.Persistence.Configurations;

public sealed class CoupleConfiguration : IEntityTypeConfiguration<Couple>
{
    public void Configure(EntityTypeBuilder<Couple> builder)
    {
        builder.ToTable("Couples");
        builder.HasKey(c => c.Id);

        builder.HasIndex(c => c.Partner1Id);
        builder.HasIndex(c => c.Partner2Id);
        builder.HasIndex(c => new { c.Partner1Id, c.Status });
        builder.HasIndex(c => new { c.Partner2Id, c.Status });
    }
}
