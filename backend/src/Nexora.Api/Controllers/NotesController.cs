using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Nexora.Application.Notes.Commands.CreateNote;
using Nexora.Application.Notes.Commands.DeleteNote;
using Nexora.Application.Notes.Commands.UpdateNote;
using Nexora.Application.Notes.DTOs;
using Nexora.Application.Notes.Queries.GetNote;
using Nexora.Application.Notes.Queries.GetNotes;
using Nexora.Domain.Common;

namespace Nexora.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public sealed class NotesController(IMediator mediator) : ControllerBase
{
    /// <summary>List all personal notes for the authenticated user.</summary>
    [HttpGet]
    [ProducesResponseType(typeof(IList<NoteDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetNotes(CancellationToken cancellationToken)
    {
        var notes = await mediator.Send(new GetNotesQuery(), cancellationToken);
        return Ok(notes);
    }

    /// <summary>Get a single note by ID. Returns 404 if not owned by requester.</summary>
    [HttpGet("{id:guid}")]
    [ProducesResponseType(typeof(NoteDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetNote([FromRoute] Guid id, CancellationToken cancellationToken)
    {
        try
        {
            var note = await mediator.Send(new GetNoteQuery(id), cancellationToken);
            return Ok(note);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { detail = ex.Message });
        }
    }

    /// <summary>Create a new personal note.</summary>
    [HttpPost]
    [ProducesResponseType(typeof(NoteDto), StatusCodes.Status201Created)]
    public async Task<IActionResult> CreateNote(
        [FromBody] CreateNoteRequest request,
        CancellationToken cancellationToken)
    {
        var note = await mediator.Send(
            new CreateNoteCommand(request.Title, request.Content, request.IsPinned, request.Visibility),
            cancellationToken);

        return CreatedAtAction(nameof(GetNote), new { id = note.Id }, note);
    }

    /// <summary>Update a note. Returns 404 if note not owned by requester.</summary>
    [HttpPut("{id:guid}")]
    [ProducesResponseType(typeof(NoteDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateNote(
        [FromRoute] Guid id,
        [FromBody] UpdateNoteRequest request,
        CancellationToken cancellationToken)
    {
        try
        {
            var note = await mediator.Send(
                new UpdateNoteCommand(id, request.Title, request.Content, request.IsPinned, request.IsArchived),
                cancellationToken);
            return Ok(note);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { detail = ex.Message });
        }
    }

    /// <summary>Delete a note. Returns 404 if note not owned by requester.</summary>
    [HttpDelete("{id:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> DeleteNote([FromRoute] Guid id, CancellationToken cancellationToken)
    {
        try
        {
            await mediator.Send(new DeleteNoteCommand(id), cancellationToken);
            return NoContent();
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { detail = ex.Message });
        }
    }
}

public sealed record CreateNoteRequest(
    string Title,
    string Content,
    bool IsPinned = false,
    VisibilityLevel Visibility = VisibilityLevel.Private);

public sealed record UpdateNoteRequest(
    string Title,
    string Content,
    bool IsPinned = false,
    bool IsArchived = false);
