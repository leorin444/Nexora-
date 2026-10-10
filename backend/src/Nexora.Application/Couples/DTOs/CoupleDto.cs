using Nexora.Domain.Couples;

namespace Nexora.Application.Couples.DTOs;

public sealed record CoupleDto(
    Guid Id,
    Guid Partner1Id,
    Guid Partner2Id,
    CoupleStatus Status,
    DateTime ConnectedAtUtc,
    PartnerDto Partner);

public sealed record PartnerDto(
    Guid Id,
    string Email,
    string FullName);

public sealed record CoupleInvitationDto(
    Guid Id,
    string InvitationCode,
    InvitationStatus Status,
    DateTime ExpiresAtUtc,
    DateTime CreatedAtUtc);
