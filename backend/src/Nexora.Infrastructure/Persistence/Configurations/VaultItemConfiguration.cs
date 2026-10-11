using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Nexora.Domain.Vault;

namespace Nexora.Infrastructure.Persistence.Configurations;

public sealed class VaultItemConfiguration : IEntityTypeConfiguration<VaultItem>
{
    public void Configure(EntityTypeBuilder<VaultItem> builder)
    {
        builder.ToTable("VaultItems");
        builder.HasKey(v => v.Id);

        builder.Property(v => v.Title)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(v => v.Description)
            .HasMaxLength(2000);

        builder.Property(v => v.EncryptedPayload)
            .IsRequired();

        builder.Property(v => v.Tags)
            .HasMaxLength(500);

        builder.HasIndex(v => v.OwnerId);
        builder.HasIndex(v => v.CoupleId);
        builder.HasIndex(v => new { v.OwnerId, v.UpdatedAtUtc });
    }
}
