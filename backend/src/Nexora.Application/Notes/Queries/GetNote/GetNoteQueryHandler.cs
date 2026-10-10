using MediatR;
using Microsoft.EntityFrameworkCore;
using Nexora.Application.Common.Interfaces;
using Nexora.Application.Notes.Commands.CreateNote;
using Nexora.Application.Notes.DTOs;

namespace Nexora.Application.Notes.Queries.GetNote;

public sealed class GetNoteQueryHandler(
    INexoraDbContext dbContext,
    ICurrentUserService currentUser) : IRequestHandler<GetNoteQuery, NoteDto>
{
    public async Task<NoteDto> Handle(GetNoteQuery request, CancellationToken cancellationToken)
    {
        var userId = currentUser.UserId
            ?? throw new UnauthorizedAccessException("User is not authenticated.");

        // SECURITY: Fetch only if the note belongs to the requesting user.
        var note = await dbContext.Notes
            .AsNoTracking()
            .FirstOrDefaultAsync(n => n.Id == request.NoteId && n.OwnerId == userId, cancellationToken)
            ?? throw new KeyNotFoundException("Note not found or access denied.");

        return CreateNoteCommandHandler.MapToDto(note);
    }
}
