namespace Nexora.Domain.Chat;

public enum MessageDeliveryStatus
{
    Sent = 0,
    Delivered = 1,
    Read = 2
}

public sealed class ChatMessage
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid CoupleId { get; set; }
    public Guid SenderId { get; set; }

    public string Content { get; set; } = string.Empty;
    public string? AttachmentUrl { get; set; }
    public string? AttachmentType { get; set; }

    public MessageDeliveryStatus DeliveryStatus { get; set; } = MessageDeliveryStatus.Sent;

    public DateTime SentAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime? ReadAtUtc { get; set; }
}
