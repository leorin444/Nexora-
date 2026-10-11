using Nexora.Domain.Chat;

namespace Nexora.Application.Chat.DTOs;

public sealed record ChatMessageDto(
    Guid Id,
    Guid CoupleId,
    Guid SenderId,
    string Content,
    string? AttachmentUrl,
    string? AttachmentType,
    MessageDeliveryStatus DeliveryStatus,
    DateTime SentAtUtc,
    DateTime? ReadAtUtc);
