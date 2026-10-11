using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Nexora.Application.Common.Interfaces;
using Nexora.Application.Vault.Commands.CreateVaultItem;
using Nexora.Application.Vault.Queries.GetVaultItems;
using Nexora.Domain.Common;
using Nexora.Domain.Couples;
using Nexora.Domain.Vault;
using Nexora.Infrastructure.Persistence;
using Xunit;

namespace Nexora.UnitTests.Vault;

public class VaultCommandTests
{
    private static NexoraDbContext CreateDb() =>
        new(new DbContextOptionsBuilder<NexoraDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options);

    private static MockCurrentUserService UserOf(Guid userId) => new(userId);

    [Fact]
    public async Task CreateVaultItem_Personal_ShouldSaveWithOwnerId()
    {
        var db = CreateDb();
        var user = Guid.NewGuid();
        var handler = new CreateVaultItemCommandHandler(db, UserOf(user));

        var result = await handler.Handle(
            new CreateVaultItemCommand("Passport", "Scanned copy", VaultItemType.Document, "encrypted-data-blob", "docs,travel", VisibilityLevel.Private),
            default);

        result.Should().NotBeNull();
        result.Title.Should().Be("Passport");
        result.OwnerId.Should().Be(user);
        result.CoupleId.Should().BeNull();
        result.Visibility.Should().Be(VisibilityLevel.Private);

        var saved = await db.VaultItems.SingleAsync();
        saved.EncryptedPayload.Should().Be("encrypted-data-blob");
    }

    [Fact]
    public async Task CreateVaultItem_Shared_ShouldLinkToActiveCouple()
    {
        var db = CreateDb();
        var userA = Guid.NewGuid();
        var userB = Guid.NewGuid();
        var couple = new Couple
        {
            Partner1Id = userA,
            Partner2Id = userB,
            Status = CoupleStatus.Active
        };
        db.Couples.Add(couple);
        await db.SaveChangesAsync();

        var handler = new CreateVaultItemCommandHandler(db, UserOf(userA));
        var result = await handler.Handle(
            new CreateVaultItemCommand("WiFi Password", "Home network", VaultItemType.Secret, "super-secret-key", "wifi", VisibilityLevel.Shared),
            default);

        result.CoupleId.Should().Be(couple.Id);
        result.Visibility.Should().Be(VisibilityLevel.Shared);
    }

    [Fact]
    public async Task GetVaultItems_ShouldIsolatePartnerPrivateSecrets()
    {
        var db = CreateDb();
        var userA = Guid.NewGuid();
        var userB = Guid.NewGuid();
        var couple = new Couple
        {
            Partner1Id = userA,
            Partner2Id = userB,
            Status = CoupleStatus.Active
        };
        db.Couples.Add(couple);

        // User A's private vault item
        db.VaultItems.Add(new VaultItem
        {
            OwnerId = userA,
            Title = "User A Private Journal",
            EncryptedPayload = "blob1",
            Visibility = VisibilityLevel.Private
        });

        // User B's private secret
        db.VaultItems.Add(new VaultItem
        {
            OwnerId = userB,
            Title = "User B Secret Bank PIN",
            EncryptedPayload = "blob2",
            Visibility = VisibilityLevel.Private
        });

        // User B's shared document
        db.VaultItems.Add(new VaultItem
        {
            OwnerId = userB,
            CoupleId = couple.Id,
            Title = "Apartment Lease Agreement",
            EncryptedPayload = "blob3",
            Visibility = VisibilityLevel.Shared
        });

        await db.SaveChangesAsync();

        var handler = new GetVaultItemsQueryHandler(db, UserOf(userA));
        var items = await handler.Handle(new GetVaultItemsQuery(), default);

        items.Should().HaveCount(2);
        items.Select(i => i.Title).Should().Contain("User A Private Journal");
        items.Select(i => i.Title).Should().Contain("Apartment Lease Agreement");
        items.Select(i => i.Title).Should().NotContain("User B Secret Bank PIN");
    }
}

internal sealed class MockCurrentUserService(Guid userId) : Nexora.Application.Common.Interfaces.ICurrentUserService
{
    public Guid? UserId => userId;
    public bool IsAuthenticated => true;
}
