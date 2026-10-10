using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Nexora.Application.Couples.Commands.AcceptInvitation;
using Nexora.Application.Couples.Commands.CreateInvitation;
using Nexora.Application.Couples.Queries.GetCurrentCouple;
using Nexora.Domain.Couples;
using Nexora.Infrastructure.Persistence;
using Xunit;

namespace Nexora.UnitTests.Couples;

public class CoupleCommandTests
{
    private static NexoraDbContext CreateDb() =>
        new(new DbContextOptionsBuilder<NexoraDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options);

    private static MockCurrentUserService UserOf(Guid userId) => new(userId);

    [Fact]
    public async Task CreateInvitation_ShouldGeneratePendingInvitation()
    {
        var db = CreateDb();
        var userA = Guid.NewGuid();
        var handler = new CreateInvitationCommandHandler(db, UserOf(userA));

        var result = await handler.Handle(new CreateInvitationCommand(), default);

        result.Should().NotBeNull();
        result.InvitationCode.Should().HaveLength(8);
        result.Status.Should().Be(InvitationStatus.Pending);

        var savedInvite = await db.CoupleInvitations.SingleAsync();
        savedInvite.SenderId.Should().Be(userA);
    }

    [Fact]
    public async Task CreateInvitation_WhenAlreadyInCouple_ShouldThrow()
    {
        var db = CreateDb();
        var userA = Guid.NewGuid();
        var userB = Guid.NewGuid();

        db.Couples.Add(new Couple
        {
            Partner1Id = userA,
            Partner2Id = userB,
            Status = CoupleStatus.Active
        });
        await db.SaveChangesAsync();

        var handler = new CreateInvitationCommandHandler(db, UserOf(userA));
        var act = async () => await handler.Handle(new CreateInvitationCommand(), default);

        await act.Should().ThrowAsync<InvalidOperationException>()
            .WithMessage("*already in an active couple*");
    }

    [Fact]
    public async Task AcceptInvitation_ValidFlow_ShouldFormCouple()
    {
        var db = CreateDb();
        var userA = Guid.NewGuid();
        var userB = Guid.NewGuid();

        var createHandler = new CreateInvitationCommandHandler(db, UserOf(userA));
        var invite = await createHandler.Handle(new CreateInvitationCommand(), default);

        var acceptHandler = new AcceptInvitationCommandHandler(db, UserOf(userB));
        var couple = await acceptHandler.Handle(new AcceptInvitationCommand(invite.InvitationCode), default);

        couple.Should().NotBeNull();
        couple.Partner1Id.Should().Be(userA);
        couple.Partner2Id.Should().Be(userB);

        var dbInvite = await db.CoupleInvitations.SingleAsync(i => i.Id == invite.Id);
        dbInvite.Status.Should().Be(InvitationStatus.Accepted);
        dbInvite.AcceptedByUserId.Should().Be(userB);

        // Verification query
        var queryHandler = new GetCurrentCoupleQueryHandler(db, UserOf(userB));
        var currentCouple = await queryHandler.Handle(new GetCurrentCoupleQuery(), default);
        currentCouple.Should().NotBeNull();
        currentCouple!.Partner.Id.Should().Be(userA);
    }

    [Fact]
    public async Task AcceptInvitation_SelfAccept_ShouldThrow()
    {
        var db = CreateDb();
        var userA = Guid.NewGuid();

        var createHandler = new CreateInvitationCommandHandler(db, UserOf(userA));
        var invite = await createHandler.Handle(new CreateInvitationCommand(), default);

        var acceptHandler = new AcceptInvitationCommandHandler(db, UserOf(userA));
        var act = async () => await acceptHandler.Handle(new AcceptInvitationCommand(invite.InvitationCode), default);

        await act.Should().ThrowAsync<InvalidOperationException>()
            .WithMessage("*cannot accept your own*");
    }

    [Fact]
    public async Task AcceptInvitation_ReusedCode_ShouldThrow()
    {
        var db = CreateDb();
        var userA = Guid.NewGuid();
        var userB = Guid.NewGuid();
        var userC = Guid.NewGuid();

        var createHandler = new CreateInvitationCommandHandler(db, UserOf(userA));
        var invite = await createHandler.Handle(new CreateInvitationCommand(), default);

        var acceptHandlerB = new AcceptInvitationCommandHandler(db, UserOf(userB));
        await acceptHandlerB.Handle(new AcceptInvitationCommand(invite.InvitationCode), default);

        // User C attempts to use the same invitation code
        var acceptHandlerC = new AcceptInvitationCommandHandler(db, UserOf(userC));
        var act = async () => await acceptHandlerC.Handle(new AcceptInvitationCommand(invite.InvitationCode), default);

        await act.Should().ThrowAsync<InvalidOperationException>()
            .WithMessage("*already been used*");
    }
}

internal sealed class MockCurrentUserService(Guid userId) : Nexora.Application.Common.Interfaces.ICurrentUserService
{
    public Guid? UserId => userId;
    public bool IsAuthenticated => true;
}
