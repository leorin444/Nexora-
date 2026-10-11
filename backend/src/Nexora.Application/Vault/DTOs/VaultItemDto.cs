using Nexora.Domain.Common;
using Nexora.Domain.Vault;

namespace Nexora.Application.Vault.DTOs;

public sealed record VaultItemDto(
    Guid Id,
    Guid OwnerId,
    Guid? CoupleId,
    string Title,
    string? Description,
    VaultItemType ItemType,
    string EncryptedPayload,
    string? Tags,
    VisibilityLevel Visibility,
    DateTime CreatedAtUtc,
    DateTime UpdatedAtUtc);
