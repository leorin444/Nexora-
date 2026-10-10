using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Nexora.Application.Common.Interfaces;

namespace Nexora.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public sealed class FeaturesController(IFeatureFlagService featureFlagService) : ControllerBase
{
    /// <summary>
    /// Get evaluated status of all platform feature flags.
    /// Public endpoint for clients to adapt UI dynamically.
    /// </summary>
    [HttpGet]
    [AllowAnonymous]
    [ProducesResponseType(typeof(IDictionary<string, bool>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetFeatures(CancellationToken cancellationToken)
    {
        var features = await featureFlagService.GetAllFeatureFlagsAsync(cancellationToken);
        return Ok(features);
    }
}
