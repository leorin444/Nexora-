using MediatR;

namespace Nexora.Application.Notes.Commands.DeleteNote;

public sealed record DeleteNoteCommand(Guid NoteId) : IRequest;
