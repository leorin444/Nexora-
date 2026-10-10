using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Nexora.Domain.Couples;

namespace Nexora.Infrastructure.Persistence.Configurations;

public sealed class CoupleInvitationConfiguration : IEntityTypeConfiguration<CoupleInvitation>
{
    public void Configure(EntityTypeBuilder<CoupleInvitation> builder)
    {
        builder.ToTable("CoupleInvitations");
        builder.HasKey(i => i.Id);

        builder.Property(i => i.InvitationCode)
            .IsRequired()
            .HasMaxLength(20);

        builder.HasIndex(i => i.InvitationCode)
            .IsUnique();

        builder.HasIndex(i => i.SenderId);
        builder.HasIndex(i => new { i.SenderId, i.Status });
    }
}
