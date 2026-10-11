namespace Nexora.Application.Common.Interfaces;

public interface IRealtimeNotificationService
{
    Task NotifyUserAsync(Guid userId, string method, object payload, CancellationToken cancellationToken = default);
    Task NotifyCoupleAsync(Guid coupleId, string method, object payload, CancellationToken cancellationToken = default);
}
