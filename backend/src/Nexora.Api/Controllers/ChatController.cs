using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Nexora.Application.Chat.Commands.SendMessage;
using Nexora.Application.Chat.DTOs;
using Nexora.Application.Chat.Queries.GetChatMessages;

namespace Nexora.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public sealed class ChatController(IMediator mediator) : ControllerBase
{
    /// <summary>Get recent chat messages within the couple space.</summary>
    [HttpGet]
    [ProducesResponseType(typeof(IList<ChatMessageDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> GetMessages(
        [FromQuery] int limit = 50,
        [FromQuery] DateTime? beforeUtc = null,
        CancellationToken cancellationToken = default)
    {
        try
        {
            var messages = await mediator.Send(new GetChatMessagesQuery(limit, beforeUtc), cancellationToken);
            return Ok(messages);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { detail = ex.Message });
        }
    }

    /// <summary>Send a chat message to your partner.</summary>
    [HttpPost]
    [ProducesResponseType(typeof(ChatMessageDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> SendMessage(
        [FromBody] SendMessageRequest request,
        CancellationToken cancellationToken)
    {
        try
        {
            var result = await mediator.Send(
                new SendMessageCommand(request.Content, request.AttachmentUrl, request.AttachmentType),
                cancellationToken);

            return StatusCode(StatusCodes.Status201Created, result);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { detail = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { detail = ex.Message });
        }
    }
}

public sealed record SendMessageRequest(
    string Content,
    string? AttachmentUrl = null,
    string? AttachmentType = null);
