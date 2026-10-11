using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using System.Security.Claims;

namespace Nexora.Infrastructure.Realtime;

[Authorize]
public sealed class NexoraHub : Hub
{
    public override async Task OnConnectedAsync()
    {
        var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (!string.IsNullOrEmpty(userId))
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, $"user_{userId}");
        }
        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (!string.IsNullOrEmpty(userId))
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"user_{userId}");
        }
        await base.OnDisconnectedAsync(exception);
    }

    public async Task JoinCoupleGroup(string coupleId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, $"couple_{coupleId}");
    }

    public async Task LeaveCoupleGroup(string coupleId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"couple_{coupleId}");
    }
}
