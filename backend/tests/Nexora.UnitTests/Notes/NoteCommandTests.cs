using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Nexora.Application.Notes.Commands.CreateNote;
using Nexora.Application.Notes.Commands.DeleteNote;
using Nexora.Application.Notes.Commands.UpdateNote;
using Nexora.Application.Notes.Queries.GetNote;
using Nexora.Application.Notes.Queries.GetNotes;
using Nexora.Domain.Common;
using Nexora.Infrastructure.Identity;
using Nexora.Infrastructure.Persistence;
using Xunit;

namespace Nexora.UnitTests.Notes;

public class NoteCommandTests
{
    private static NexoraDbContext CreateDb() =>
        new(new DbContextOptionsBuilder<NexoraDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options);

    private static MockCurrentUserService UserOf(Guid userId) => new(userId);

    [Fact]
    public async Task CreateNote_ShouldPersistWithOwner()
    {
        var db = CreateDb();
        var userId = Guid.NewGuid();
        var handler = new CreateNoteCommandHandler(db, UserOf(userId));

        var result = await handler.Handle(
            new CreateNoteCommand("Test Note", "Content here", false, VisibilityLevel.Private),
            CancellationToken.None);

        result.Title.Should().Be("Test Note");
        db.Notes.Single().OwnerId.Should().Be(userId);
    }

    [Fact]
    public async Task GetNotes_ShouldOnlyReturnOwnNotes()
    {
        var db = CreateDb();
        var userAId = Guid.NewGuid();
        var userBId = Guid.NewGuid();

        var handlerA = new CreateNoteCommandHandler(db, UserOf(userAId));
        var handlerB = new CreateNoteCommandHandler(db, UserOf(userBId));

        await handlerA.Handle(new CreateNoteCommand("Note A", "", false, VisibilityLevel.Private), default);
        await handlerB.Handle(new CreateNoteCommand("Note B", "", false, VisibilityLevel.Private), default);

        var queryHandler = new GetNotesQueryHandler(db, UserOf(userAId));
        var notes = await queryHandler.Handle(new GetNotesQuery(), default);

        notes.Should().HaveCount(1);
        notes[0].Title.Should().Be("Note A");
    }

    [Fact]
    public async Task GetNote_WhenOtherUserTriesToAccess_ShouldThrow()
    {
        var db = CreateDb();
        var ownerIdA = Guid.NewGuid();
        var attackerIdB = Guid.NewGuid();

        var createHandler = new CreateNoteCommandHandler(db, UserOf(ownerIdA));
        var note = await createHandler.Handle(
            new CreateNoteCommand("Private Note", "Secret", false, VisibilityLevel.Private), default);

        // User B tries to access User A's note by supplying the known note ID
        var getHandler = new GetNoteQueryHandler(db, UserOf(attackerIdB));

        var act = async () => await getHandler.Handle(new GetNoteQuery(note.Id), default);
        await act.Should().ThrowAsync<KeyNotFoundException>();
    }

    [Fact]
    public async Task UpdateNote_WhenOtherUserAttempts_ShouldThrow()
    {
        var db = CreateDb();
        var ownerId = Guid.NewGuid();
        var attackerId = Guid.NewGuid();

        var createHandler = new CreateNoteCommandHandler(db, UserOf(ownerId));
        var note = await createHandler.Handle(
            new CreateNoteCommand("Original", "Content", false, VisibilityLevel.Private), default);

        var updateHandler = new UpdateNoteCommandHandler(db, UserOf(attackerId));
        var act = async () => await updateHandler.Handle(
            new UpdateNoteCommand(note.Id, "Tampered", "Tampered", false, false), default);

        await act.Should().ThrowAsync<KeyNotFoundException>();
        db.Notes.Single().Title.Should().Be("Original"); // Untouched
    }

    [Fact]
    public async Task DeleteNote_WhenOtherUserAttempts_ShouldThrow()
    {
        var db = CreateDb();
        var ownerId = Guid.NewGuid();
        var attackerId = Guid.NewGuid();

        var createHandler = new CreateNoteCommandHandler(db, UserOf(ownerId));
        var note = await createHandler.Handle(
            new CreateNoteCommand("Keep Me", "", false, VisibilityLevel.Private), default);

        var deleteHandler = new DeleteNoteCommandHandler(db, UserOf(attackerId));
        var act = async () => await deleteHandler.Handle(new DeleteNoteCommand(note.Id), default);

        await act.Should().ThrowAsync<KeyNotFoundException>();
        db.Notes.Should().HaveCount(1); // Note survives
    }
}

/// <summary>Minimal test stub for ICurrentUserService.</summary>
internal sealed class MockCurrentUserService(Guid userId) : Nexora.Application.Common.Interfaces.ICurrentUserService
{
    public Guid? UserId => userId;
    public bool IsAuthenticated => true;
}
