using MediatR;
using Nexora.Application.Notes.DTOs;
using Nexora.Domain.Common;

namespace Nexora.Application.Notes.Commands.CreateNote;

public sealed record CreateNoteCommand(
    string Title,
    string Content,
    bool IsPinned,
    VisibilityLevel Visibility) : IRequest<NoteDto>;
