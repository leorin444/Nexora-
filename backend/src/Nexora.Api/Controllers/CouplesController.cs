using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Nexora.Application.Couples.Commands.AcceptInvitation;
using Nexora.Application.Couples.Commands.CreateInvitation;
using Nexora.Application.Couples.DTOs;
using Nexora.Application.Couples.Queries.GetCurrentCouple;

namespace Nexora.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public sealed class CouplesController(IMediator mediator) : ControllerBase
{
    /// <summary>Get current active couple profile for authenticated user, or 404 if not connected.</summary>
    [HttpGet("current")]
    [ProducesResponseType(typeof(CoupleDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetCurrentCouple(CancellationToken cancellationToken)
    {
        var couple = await mediator.Send(new GetCurrentCoupleQuery(), cancellationToken);
        if (couple is null)
        {
            return NotFound(new { detail = "User does not have an active couple relationship." });
        }
        return Ok(couple);
    }

    /// <summary>Generate a single-use couple invitation code (expires in 48h).</summary>
    [HttpPost("invitations")]
    [ProducesResponseType(typeof(CoupleInvitationDto), StatusCodes.Status201Created)]
    public async Task<IActionResult> CreateInvitation(CancellationToken cancellationToken)
    {
        try
        {
            var invitation = await mediator.Send(new CreateInvitationCommand(), cancellationToken);
            return StatusCode(StatusCodes.Status201Created, invitation);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { detail = ex.Message });
        }
    }

    /// <summary>Accept an invitation using an 8-character invitation code to form a couple.</summary>
    [HttpPost("invitations/accept")]
    [ProducesResponseType(typeof(CoupleDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> AcceptInvitation(
        [FromBody] AcceptInvitationRequest request,
        CancellationToken cancellationToken)
    {
        try
        {
            var couple = await mediator.Send(new AcceptInvitationCommand(request.InvitationCode), cancellationToken);
            return Ok(couple);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { detail = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { detail = ex.Message });
        }
    }
}

public sealed record AcceptInvitationRequest(string InvitationCode);
