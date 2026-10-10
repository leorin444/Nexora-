using MediatR;
using Microsoft.EntityFrameworkCore;
using Nexora.Application.Common.Interfaces;
using Nexora.Application.Couples.DTOs;
using Nexora.Domain.Couples;
using System.Security.Cryptography;

namespace Nexora.Application.Couples.Commands.CreateInvitation;

public sealed record CreateInvitationCommand : IRequest<CoupleInvitationDto>;

public sealed class CreateInvitationCommandHandler(
    INexoraDbContext dbContext,
    ICurrentUserService currentUser) : IRequestHandler<CreateInvitationCommand, CoupleInvitationDto>
{
    public async Task<CoupleInvitationDto> Handle(CreateInvitationCommand request, CancellationToken cancellationToken)
    {
        var userId = currentUser.UserId
            ?? throw new UnauthorizedAccessException("User is not authenticated.");

        // SECURITY: Check if user already has an active couple relationship
        var hasActiveCouple = await dbContext.Couples
            .AnyAsync(c => (c.Partner1Id == userId || c.Partner2Id == userId) && c.Status == CoupleStatus.Active, cancellationToken);

        if (hasActiveCouple)
        {
            throw new InvalidOperationException("User is already in an active couple relationship.");
        }

        // Revoke any existing pending invitations for this user
        var pendingInvites = await dbContext.CoupleInvitations
            .Where(i => i.SenderId == userId && i.Status == InvitationStatus.Pending)
            .ToListAsync(cancellationToken);

        foreach (var inv in pendingInvites)
        {
            inv.Status = InvitationStatus.Revoked;
        }

        // Generate cryptographically secure invitation code
        var code = GenerateInvitationCode();

        var invitation = new CoupleInvitation
        {
            SenderId = userId,
            InvitationCode = code,
            Status = InvitationStatus.Pending,
            ExpiresAtUtc = DateTime.UtcNow.AddHours(48), // 48-hour expiration
            CreatedAtUtc = DateTime.UtcNow
        };

        dbContext.CoupleInvitations.Add(invitation);
        await dbContext.SaveChangesAsync(cancellationToken);

        return new CoupleInvitationDto(
            invitation.Id,
            invitation.InvitationCode,
            invitation.Status,
            invitation.ExpiresAtUtc,
            invitation.CreatedAtUtc);
    }

    private static string GenerateInvitationCode()
    {
        const string chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
        var buffer = new byte[8];
        RandomNumberGenerator.Fill(buffer);
        var result = new char[8];
        for (int i = 0; i < 8; i++)
        {
            result[i] = chars[buffer[i] % chars.Length];
        }
        return new string(result);
    }
}
