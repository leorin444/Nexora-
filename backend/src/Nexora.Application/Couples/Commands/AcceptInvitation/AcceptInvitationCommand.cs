using MediatR;
using Microsoft.EntityFrameworkCore;
using Nexora.Application.Common.Interfaces;
using Nexora.Application.Couples.DTOs;
using Nexora.Domain.Couples;

namespace Nexora.Application.Couples.Commands.AcceptInvitation;

public sealed record AcceptInvitationCommand(string InvitationCode) : IRequest<CoupleDto>;

public sealed class AcceptInvitationCommandHandler(
    INexoraDbContext dbContext,
    ICurrentUserService currentUser) : IRequestHandler<AcceptInvitationCommand, CoupleDto>
{
    public async Task<CoupleDto> Handle(AcceptInvitationCommand request, CancellationToken cancellationToken)
    {
        var acceptingUserId = currentUser.UserId
            ?? throw new UnauthorizedAccessException("User is not authenticated.");

        // Clean code input
        var code = request.InvitationCode.Trim().ToUpperInvariant();

        // 1. Validate invitation
        var invitation = await dbContext.CoupleInvitations
            .FirstOrDefaultAsync(i => i.InvitationCode == code, cancellationToken)
            ?? throw new KeyNotFoundException("Invalid invitation code.");

        if (invitation.Status != InvitationStatus.Pending)
        {
            throw new InvalidOperationException("This invitation has already been used or revoked.");
        }

        if (DateTime.UtcNow >= invitation.ExpiresAtUtc)
        {
            invitation.Status = InvitationStatus.Expired;
            await dbContext.SaveChangesAsync(cancellationToken);
            throw new InvalidOperationException("This invitation has expired.");
        }

        if (invitation.SenderId == acceptingUserId)
        {
            throw new InvalidOperationException("You cannot accept your own couple invitation.");
        }

        // 2. Ensure neither user is already in an active couple
        var senderHasCouple = await dbContext.Couples
            .AnyAsync(c => (c.Partner1Id == invitation.SenderId || c.Partner2Id == invitation.SenderId) && c.Status == CoupleStatus.Active, cancellationToken);

        if (senderHasCouple)
        {
            invitation.Status = InvitationStatus.Revoked;
            await dbContext.SaveChangesAsync(cancellationToken);
            throw new InvalidOperationException("The user who invited you is already in an active couple.");
        }

        var acceptingHasCouple = await dbContext.Couples
            .AnyAsync(c => (c.Partner1Id == acceptingUserId || c.Partner2Id == acceptingUserId) && c.Status == CoupleStatus.Active, cancellationToken);

        if (acceptingHasCouple)
        {
            throw new InvalidOperationException("You are already in an active couple relationship.");
        }

        // 3. Mark invitation as accepted (single-use)
        invitation.Status = InvitationStatus.Accepted;
        invitation.AcceptedAtUtc = DateTime.UtcNow;
        invitation.AcceptedByUserId = acceptingUserId;

        // 4. Create new Couple
        var couple = new Couple
        {
            Partner1Id = invitation.SenderId,
            Partner2Id = acceptingUserId,
            Status = CoupleStatus.Active,
            ConnectedAtUtc = DateTime.UtcNow,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };

        dbContext.Couples.Add(couple);
        await dbContext.SaveChangesAsync(cancellationToken);

        return new CoupleDto(
            couple.Id,
            couple.Partner1Id,
            couple.Partner2Id,
            couple.Status,
            couple.ConnectedAtUtc,
            new PartnerDto(invitation.SenderId, "partner@nexora.local", "Partner"));
    }
}
