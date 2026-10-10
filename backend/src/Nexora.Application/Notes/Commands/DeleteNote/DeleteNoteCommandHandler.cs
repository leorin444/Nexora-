using MediatR;
using Microsoft.EntityFrameworkCore;
using Nexora.Application.Common.Interfaces;

namespace Nexora.Application.Notes.Commands.DeleteNote;

public sealed class DeleteNoteCommandHandler(
    INexoraDbContext dbContext,
    ICurrentUserService currentUser) : IRequestHandler<DeleteNoteCommand>
{
    public async Task Handle(DeleteNoteCommand request, CancellationToken cancellationToken)
    {
        var userId = currentUser.UserId
            ?? throw new UnauthorizedAccessException("User is not authenticated.");

        // SECURITY: OwnerId filter prevents deleting another user's note.
        var note = await dbContext.Notes
            .FirstOrDefaultAsync(n => n.Id == request.NoteId && n.OwnerId == userId, cancellationToken)
            ?? throw new KeyNotFoundException("Note not found or access denied.");

        dbContext.Notes.Remove(note);
        await dbContext.SaveChangesAsync(cancellationToken);
    }
}
