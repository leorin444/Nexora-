using MediatR;
using Microsoft.EntityFrameworkCore;
using Nexora.Application.Chat.DTOs;
using Nexora.Application.Common.Interfaces;
using Nexora.Domain.Chat;
using Nexora.Domain.Couples;

namespace Nexora.Application.Chat.Commands.SendMessage;

public sealed record SendMessageCommand(
    string Content,
    string? AttachmentUrl = null,
    string? AttachmentType = null) : IRequest<ChatMessageDto>;

public sealed class SendMessageCommandHandler(
    INexoraDbContext dbContext,
    ICurrentUserService currentUser,
    IRealtimeNotificationService realtime) : IRequestHandler<SendMessageCommand, ChatMessageDto>
{
    public async Task<ChatMessageDto> Handle(SendMessageCommand request, CancellationToken cancellationToken)
    {
        var userId = currentUser.UserId
            ?? throw new UnauthorizedAccessException("User is not authenticated.");

        if (string.IsNullOrWhiteSpace(request.Content) && string.IsNullOrWhiteSpace(request.AttachmentUrl))
        {
            throw new ArgumentException("Message must have text content or an attachment.");
        }

        // Verify user is in an active couple
        var couple = await dbContext.Couples
            .AsNoTracking()
            .FirstOrDefaultAsync(c => (c.Partner1Id == userId || c.Partner2Id == userId) && c.Status == CoupleStatus.Active, cancellationToken)
            ?? throw new InvalidOperationException("User must be in an active couple to send chat messages.");

        var message = new ChatMessage
        {
            CoupleId = couple.Id,
            SenderId = userId,
            Content = request.Content,
            AttachmentUrl = request.AttachmentUrl,
            AttachmentType = request.AttachmentType,
            DeliveryStatus = MessageDeliveryStatus.Sent,
            SentAtUtc = DateTime.UtcNow
        };

        dbContext.ChatMessages.Add(message);
        await dbContext.SaveChangesAsync(cancellationToken);

        var dto = MapToDto(message);

        // Realtime broadcast to couple group
        await realtime.NotifyCoupleAsync(couple.Id, "ChatMessageReceived", dto, cancellationToken);

        return dto;
    }

    internal static ChatMessageDto MapToDto(ChatMessage m) => new(
        m.Id,
        m.CoupleId,
        m.SenderId,
        m.Content,
        m.AttachmentUrl,
        m.AttachmentType,
        m.DeliveryStatus,
        m.SentAtUtc,
        m.ReadAtUtc);
}
