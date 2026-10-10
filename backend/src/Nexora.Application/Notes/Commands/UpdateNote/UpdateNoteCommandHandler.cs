using MediatR;
using Microsoft.EntityFrameworkCore;
using Nexora.Application.Common.Interfaces;
using Nexora.Application.Notes.DTOs;

namespace Nexora.Application.Notes.Commands.UpdateNote;

public sealed class UpdateNoteCommandHandler(
    INexoraDbContext dbContext,
    ICurrentUserService currentUser) : IRequestHandler<UpdateNoteCommand, NoteDto>
{
    public async Task<NoteDto> Handle(UpdateNoteCommand request, CancellationToken cancellationToken)
    {
        var userId = currentUser.UserId
            ?? throw new UnauthorizedAccessException("User is not authenticated.");

        // SECURITY: Fetch note filtered by OwnerId to prevent cross-user access.
        // A user cannot modify another user's note by guessing/supplying a different NoteId.
        var note = await dbContext.Notes
            .FirstOrDefaultAsync(n => n.Id == request.NoteId && n.OwnerId == userId, cancellationToken)
            ?? throw new KeyNotFoundException("Note not found or access denied.");

        note.Title = request.Title;
        note.Content = request.Content;
        note.IsPinned = request.IsPinned;
        note.IsArchived = request.IsArchived;
        note.UpdatedAtUtc = DateTime.UtcNow;

        await dbContext.SaveChangesAsync(cancellationToken);

        return CreateNote.CreateNoteCommandHandler.MapToDto(note);
    }
}
