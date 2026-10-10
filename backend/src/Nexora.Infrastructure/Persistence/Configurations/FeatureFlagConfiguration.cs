using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Nexora.Domain.Features;

namespace Nexora.Infrastructure.Persistence.Configurations;

public sealed class FeatureFlagConfiguration : IEntityTypeConfiguration<FeatureFlag>
{
    public void Configure(EntityTypeBuilder<FeatureFlag> builder)
    {
        builder.ToTable("FeatureFlags");
        builder.HasKey(f => f.Name);

        builder.Property(f => f.Name)
            .HasMaxLength(100);

        builder.Property(f => f.Description)
            .HasMaxLength(250);

        builder.Property(f => f.UpdatedBy)
            .HasMaxLength(256);
    }
}
