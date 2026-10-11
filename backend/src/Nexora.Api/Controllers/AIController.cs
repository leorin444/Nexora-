using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Nexora.Application.AI;
using Nexora.Application.AI.Queries.AskAI;
using Nexora.Application.AI.Queries.CommunicationCoach;

namespace Nexora.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public sealed class AIController(IMediator mediator, IAIProvider aiProvider) : ControllerBase
{
    /// <summary>Get current AI provider status.</summary>
    [HttpGet("status")]
    [ProducesResponseType(typeof(object), StatusCodes.Status200OK)]
    public IActionResult GetStatus()
    {
        return Ok(new
        {
            provider = aiProvider.ProviderName,
            isAvailable = aiProvider.IsAvailable
        });
    }

    /// <summary>Ask the Nexora AI assistant a question.</summary>
    [HttpPost("ask")]
    [ProducesResponseType(typeof(AskAIResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Ask(
        [FromBody] AskAIRequest request,
        CancellationToken cancellationToken)
    {
        try
        {
            var result = await mediator.Send(
                new AskAIQuery(request.Prompt, request.Context),
                cancellationToken);
            return Ok(result);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { detail = ex.Message });
        }
    }

    /// <summary>Get communication coaching for a message you want to send to your partner.</summary>
    [HttpPost("coach")]
    [ProducesResponseType(typeof(CommunicationCoachResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Coach(
        [FromBody] CoachRequest request,
        CancellationToken cancellationToken)
    {
        try
        {
            var result = await mediator.Send(
                new CommunicationCoachQuery(request.Message, request.Situation),
                cancellationToken);
            return Ok(result);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { detail = ex.Message });
        }
    }
}

public sealed record AskAIRequest(string Prompt, string? Context = null);
public sealed record CoachRequest(string Message, string? Situation = null);
