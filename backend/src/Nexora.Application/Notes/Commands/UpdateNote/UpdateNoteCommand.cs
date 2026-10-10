using MediatR;
using Nexora.Application.Notes.DTOs;

namespace Nexora.Application.Notes.Commands.UpdateNote;

public sealed record UpdateNoteCommand(
    Guid NoteId,
    string Title,
    string Content,
    bool IsPinned,
    bool IsArchived) : IRequest<NoteDto>;
