using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Nexora.Application.Chat.Commands.SendMessage;
using Nexora.Application.Chat.Queries.GetChatMessages;
using Nexora.Application.Common.Interfaces;
using Nexora.Domain.Couples;
using Nexora.Infrastructure.Persistence;
using Xunit;

namespace Nexora.UnitTests.Chat;

public class ChatCommandTests
{
    private static NexoraDbContext CreateDb() =>
        new(new DbContextOptionsBuilder<NexoraDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options);

    private static MockCurrentUserService UserOf(Guid userId) => new(userId);
    private static MockRealtimeNotificationService RealtimeOf() => new();

    [Fact]
    public async Task SendMessage_WhenInCouple_ShouldPersistAndNotify()
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

        var realtime = RealtimeOf();
        var handler = new SendMessageCommandHandler(db, UserOf(userA), realtime);

        var result = await handler.Handle(new SendMessageCommand("Hello love!"), default);

        result.Should().NotBeNull();
        result.Content.Should().Be("Hello love!");
        result.SenderId.Should().Be(userA);
        result.CoupleId.Should().Be(couple.Id);

        realtime.NotifiedCouples.Should().Contain(couple.Id);

        var messageInDb = await db.ChatMessages.SingleAsync();
        messageInDb.Content.Should().Be("Hello love!");
    }

    [Fact]
    public async Task SendMessage_WhenNotInCouple_ShouldThrow()
    {
        var db = CreateDb();
        var singleUser = Guid.NewGuid();
        var realtime = RealtimeOf();
        var handler = new SendMessageCommandHandler(db, UserOf(singleUser), realtime);

        var act = async () => await handler.Handle(new SendMessageCommand("Anyone there?"), default);

        await act.Should().ThrowAsync<InvalidOperationException>()
            .WithMessage("*must be in an active couple*");
    }

    [Fact]
    public async Task GetChatMessages_ShouldReturnMessagesChronologically()
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

        var realtime = RealtimeOf();
        var sendHandler = new SendMessageCommandHandler(db, UserOf(userA), realtime);
        await sendHandler.Handle(new SendMessageCommand("First message"), default);

        var sendHandlerB = new SendMessageCommandHandler(db, UserOf(userB), realtime);
        await sendHandlerB.Handle(new SendMessageCommand("Second response"), default);

        var queryHandler = new GetChatMessagesQueryHandler(db, UserOf(userA));
        var messages = await queryHandler.Handle(new GetChatMessagesQuery(), default);

        messages.Should().HaveCount(2);
        messages[0].Content.Should().Be("First message");
        messages[1].Content.Should().Be("Second response");
    }
}

internal sealed class MockCurrentUserService(Guid userId) : Nexora.Application.Common.Interfaces.ICurrentUserService
{
    public Guid? UserId => userId;
    public bool IsAuthenticated => true;
}

internal sealed class MockRealtimeNotificationService : IRealtimeNotificationService
{
    public List<Guid> NotifiedCouples { get; } = [];
    public List<Guid> NotifiedUsers { get; } = [];

    public Task NotifyCoupleAsync(Guid coupleId, string method, object payload, CancellationToken cancellationToken = default)
    {
        NotifiedCouples.Add(coupleId);
        return Task.CompletedTask;
    }

    public Task NotifyUserAsync(Guid userId, string method, object payload, CancellationToken cancellationToken = default)
    {
        NotifiedUsers.Add(userId);
        return Task.CompletedTask;
    }
}
