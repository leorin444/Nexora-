using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Nexora.Application.Search.DTOs;
using Nexora.Application.Search.Queries.UnifiedSearch;

namespace Nexora.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public sealed class SearchController(IMediator mediator) : ControllerBase
{
    /// <summary>Unified global search across personal notes, reminders, events, vault, and news.</summary>
    [HttpGet]
    [ProducesResponseType(typeof(UnifiedSearchResponse), StatusCodes.Status200OK)]
    public async Task<IActionResult> Search(
        [FromQuery] string q,
        [FromQuery] int limit = 5,
        CancellationToken cancellationToken = default)
    {
        var response = await mediator.Send(new UnifiedSearchQuery(q, limit), cancellationToken);
        return Ok(response);
    }
}
