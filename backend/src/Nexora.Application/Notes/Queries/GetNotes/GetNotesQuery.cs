using MediatR;
using Nexora.Application.Notes.DTOs;

namespace Nexora.Application.Notes.Queries.GetNotes;

/// <summary>Returns all notes belonging to the authenticated user.</summary>
public sealed record GetNotesQuery : IRequest<IList<NoteDto>>;
