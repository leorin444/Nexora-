using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Nexora.Application.Calendar.Commands.CreateCalendarEvent;
using Nexora.Application.Calendar.DTOs;
using Nexora.Application.Calendar.Queries.GetCalendarEvents;
using Nexora.Domain.Common;

namespace Nexora.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public sealed class CalendarController(IMediator mediator) : ControllerBase
{
    /// <summary>Get calendar events within a date range (defaults to current month).</summary>
    [HttpGet]
    [ProducesResponseType(typeof(IList<CalendarEventDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetEvents(
        [FromQuery] DateTime? startUtc,
        [FromQuery] DateTime? endUtc,
        CancellationToken cancellationToken)
    {
        var start = startUtc ?? DateTime.UtcNow.Date.AddDays(-7);
        var end = endUtc ?? DateTime.UtcNow.Date.AddDays(30);

        var events = await mediator.Send(new GetCalendarEventsQuery(start, end), cancellationToken);
        return Ok(events);
    }

    /// <summary>Create a calendar event (personal or couple-visible).</summary>
    [HttpPost]
    [ProducesResponseType(typeof(CalendarEventDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> CreateEvent(
        [FromBody] CreateCalendarEventRequest request,
        CancellationToken cancellationToken)
    {
        try
        {
            var result = await mediator.Send(
                new CreateCalendarEventCommand(
                    request.Title,
                    request.Description,
                    request.Location,
                    request.StartTimeUtc,
                    request.EndTimeUtc,
                    request.IsAllDay,
                    request.Visibility),
                cancellationToken);

            return StatusCode(StatusCodes.Status201Created, result);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { detail = ex.Message });
        }
    }
}

public sealed record CreateCalendarEventRequest(
    string Title,
    string? Description,
    string? Location,
    DateTime StartTimeUtc,
    DateTime EndTimeUtc,
    bool IsAllDay = false,
    VisibilityLevel Visibility = VisibilityLevel.Private);
