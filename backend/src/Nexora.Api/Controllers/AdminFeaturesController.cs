using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Nexora.Application.Common.Interfaces;

namespace Nexora.Api.Controllers;

[ApiController]
[Route("api/admin/features")]
[Authorize(Policy = "AdminOnly")]
public sealed class AdminFeaturesController(
    IFeatureFlagService featureFlagService,
    IAuditLogService auditLogService,
    ICurrentUserService currentUserService) : ControllerBase
{
    /// <summary>
    /// Update feature flag state (Admin only).
    /// Enforces server-side feature toggle & records audit log.
    /// </summary>
    [HttpPut("{name}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> UpdateFeature(
        [FromRoute] string name,
        [FromBody] UpdateFeatureRequest request,
        CancellationToken cancellationToken)
    {
        var adminIdentifier = currentUserService.UserId?.ToString() ?? "Admin";

        await featureFlagService.SetFeatureStateAsync(name, request.IsEnabled, adminIdentifier, cancellationToken);

        await auditLogService.LogAsync(
            action: "UPDATE_FEATURE_FLAG",
            domain: "FeatureManagement",
            entityName: "FeatureFlag",
            entityId: name,
            details: $"Feature '{name}' set to {request.IsEnabled}",
            cancellationToken: cancellationToken);

        return NoContent();
    }
}

public sealed record UpdateFeatureRequest(bool IsEnabled);
