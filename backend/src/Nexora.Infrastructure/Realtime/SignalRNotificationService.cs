using Microsoft.AspNetCore.SignalR;
using Nexora.Application.Common.Interfaces;

namespace Nexora.Infrastructure.Realtime;

public sealed class SignalRNotificationService(IHubContext<NexoraHub> hubContext) : IRealtimeNotificationService
{
    public async Task NotifyUserAsync(Guid userId, string method, object payload, CancellationToken cancellationToken = default)
    {
        await hubContext.Clients.Group($"user_{userId}").SendAsync(method, payload, cancellationToken);
    }

    public async Task NotifyCoupleAsync(Guid coupleId, string method, object payload, CancellationToken cancellationToken = default)
    {
        await hubContext.Clients.Group($"couple_{coupleId}").SendAsync(method, payload, cancellationToken);
    }
}
