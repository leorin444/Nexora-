using Microsoft.AspNetCore.Mvc;

namespace Nexora.Api.Controllers;

/// <summary>
/// Simple health check controller providing system status information.
/// The /health endpoint registered via HealthChecks middleware is the primary check.
/// This provides an additional JSON status endpoint.
/// </summary>
[ApiController]
[Route("api/[controller]")]
public sealed class SystemController : ControllerBase
{
    /// <summary>
    /// Returns a basic API status response. Anonymous — no auth required.
    /// </summary>
    [HttpGet("status")]
    [ProducesResponseType(typeof(ApiStatusResponse), StatusCodes.Status200OK)]
    public IActionResult GetStatus()
    {
        return Ok(new ApiStatusResponse(
            Name: "Nexora API",
            Version: "1.0.0",
            Status: "Healthy",
            Timestamp: DateTimeOffset.UtcNow));
    }
}

public sealed record ApiStatusResponse(
    string Name,
    string Version,
    string Status,
    DateTimeOffset Timestamp);
