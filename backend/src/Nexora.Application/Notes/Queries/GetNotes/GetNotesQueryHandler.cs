using MediatR;
using Microsoft.EntityFrameworkCore;
using Nexora.Application.Common.Interfaces;
using Nexora.Application.Notes.Commands.CreateNote;
using Nexora.Application.Notes.DTOs;

namespace Nexora.Application.Notes.Queries.GetNotes;

public sealed class GetNotesQueryHandler(
    INexoraDbContext dbContext,
    ICurrentUserService currentUser) : IRequestHandler<GetNotesQuery, IList<NoteDto>>
{
    public async Task<IList<NoteDto>> Handle(GetNotesQuery request, CancellationToken cancellationToken)
    {
        var userId = currentUser.UserId
            ?? throw new UnauthorizedAccessException("User is not authenticated.");

        // SECURITY: Always filter by OwnerId derived from JWT. Never expose other users' notes.
        return await dbContext.Notes
            .AsNoTracking()
            .Where(n => n.OwnerId == userId && !n.IsArchived)
            .OrderByDescending(n => n.IsPinned)
            .ThenByDescending(n => n.UpdatedAtUtc)
            .Select(n => CreateNoteCommandHandler.MapToDto(n))
            .ToListAsync(cancellationToken);
    }
}
