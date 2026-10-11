using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Nexora.Application.Vault.Commands.CreateVaultItem;
using Nexora.Application.Vault.DTOs;
using Nexora.Application.Vault.Queries.GetVaultItems;
using Nexora.Domain.Common;
using Nexora.Domain.Vault;

namespace Nexora.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public sealed class VaultController(IMediator mediator) : ControllerBase
{
    /// <summary>Get vault items visible to the authenticated user.</summary>
    [HttpGet]
    [ProducesResponseType(typeof(IList<VaultItemDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetItems(
        [FromQuery] string? search = null,
        CancellationToken cancellationToken = default)
    {
        var items = await mediator.Send(new GetVaultItemsQuery(search), cancellationToken);
        return Ok(items);
    }

    /// <summary>Create a new vault document or secret.</summary>
    [HttpPost]
    [ProducesResponseType(typeof(VaultItemDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> CreateItem(
        [FromBody] CreateVaultItemRequest request,
        CancellationToken cancellationToken)
    {
        try
        {
            var result = await mediator.Send(
                new CreateVaultItemCommand(
                    request.Title,
                    request.Description,
                    request.ItemType,
                    request.EncryptedPayload,
                    request.Tags,
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

public sealed record CreateVaultItemRequest(
    string Title,
    string? Description,
    VaultItemType ItemType,
    string EncryptedPayload,
    string? Tags,
    VisibilityLevel Visibility = VisibilityLevel.Private);
