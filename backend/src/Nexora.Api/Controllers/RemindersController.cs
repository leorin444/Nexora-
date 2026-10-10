using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Nexora.Application.Reminders.Commands.CompleteReminder;
using Nexora.Application.Reminders.Commands.CreateReminder;
using Nexora.Application.Reminders.DTOs;
using Nexora.Application.Reminders.Queries.GetReminders;
using Nexora.Domain.Reminders;

namespace Nexora.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public sealed class RemindersController(IMediator mediator) : ControllerBase
{
    /// <summary>Get reminders for the authenticated user.</summary>
    [HttpGet]
    [ProducesResponseType(typeof(IList<ReminderDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetReminders(
        [FromQuery] bool includeCompleted = false,
        CancellationToken cancellationToken = default)
    {
        var reminders = await mediator.Send(new GetRemindersQuery(includeCompleted), cancellationToken);
        return Ok(reminders);
    }

    /// <summary>Create a new personal reminder.</summary>
    [HttpPost]
    [ProducesResponseType(typeof(ReminderDto), StatusCodes.Status201Created)]
    public async Task<IActionResult> CreateReminder(
        [FromBody] CreateReminderRequest request,
        CancellationToken cancellationToken)
    {
        var reminder = await mediator.Send(
            new CreateReminderCommand(request.Title, request.Description, request.DueAtUtc, request.Recurrence),
            cancellationToken);

        return Created($"/api/reminders/{reminder.Id}", reminder);
    }

    /// <summary>Mark a reminder as completed. Returns 404 if not owned by requester.</summary>
    [HttpPatch("{id:guid}/complete")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> CompleteReminder([FromRoute] Guid id, CancellationToken cancellationToken)
    {
        try
        {
            await mediator.Send(new CompleteReminderCommand(id), cancellationToken);
            return NoContent();
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { detail = ex.Message });
        }
    }
}

public sealed record CreateReminderRequest(
    string Title,
    string? Description,
    DateTime DueAtUtc,
    RecurrenceType Recurrence = RecurrenceType.None);
