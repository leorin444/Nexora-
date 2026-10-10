using MediatR;
using Nexora.Application.Notes.DTOs;

namespace Nexora.Application.Notes.Queries.GetNote;

/// <summary>Returns a single note by ID — enforces ownership.</summary>
public sealed record GetNoteQuery(Guid NoteId) : IRequest<NoteDto>;
