using MediatR;
using Nexora.Application.Common.Interfaces;
using Nexora.Application.Notes.DTOs;
using Nexora.Domain.Notes;

namespace Nexora.Application.Notes.Commands.CreateNote;

public sealed class CreateNoteCommandHandler(
    INexoraDbContext dbContext,
    ICurrentUserService currentUser) : IRequestHandler<CreateNoteCommand, NoteDto>
{
    public async Task<NoteDto> Handle(CreateNoteCommand request, CancellationToken cancellationToken)
    {
        // SECURITY: OwnerId comes from authenticated JWT claims via ICurrentUserService.
        // It is never read from client-supplied input.
        var userId = currentUser.UserId
            ?? throw new UnauthorizedAccessException("User is not authenticated.");

        var note = new Note
        {
            OwnerId = userId,
            Title = request.Title,
            Content = request.Content,
            IsPinned = request.IsPinned,
            Visibility = request.Visibility,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };

        dbContext.Notes.Add(note);
        await dbContext.SaveChangesAsync(cancellationToken);

        return MapToDto(note);
    }

    internal static NoteDto MapToDto(Note n) => new(
        n.Id, n.Title, n.Content, n.IsPinned, n.Visibility,
        n.IsArchived, n.CreatedAtUtc, n.UpdatedAtUtc);
}
