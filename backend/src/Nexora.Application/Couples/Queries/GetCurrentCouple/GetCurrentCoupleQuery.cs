using MediatR;
using Microsoft.EntityFrameworkCore;
using Nexora.Application.Common.Interfaces;
using Nexora.Application.Couples.DTOs;
using Nexora.Domain.Couples;

namespace Nexora.Application.Couples.Queries.GetCurrentCouple;

public sealed record GetCurrentCoupleQuery : IRequest<CoupleDto?>;

public sealed class GetCurrentCoupleQueryHandler(
    INexoraDbContext dbContext,
    ICurrentUserService currentUser) : IRequestHandler<GetCurrentCoupleQuery, CoupleDto?>
{
    public async Task<CoupleDto?> Handle(GetCurrentCoupleQuery request, CancellationToken cancellationToken)
    {
        var userId = currentUser.UserId
            ?? throw new UnauthorizedAccessException("User is not authenticated.");

        var couple = await dbContext.Couples
            .AsNoTracking()
            .FirstOrDefaultAsync(c => (c.Partner1Id == userId || c.Partner2Id == userId) && c.Status == CoupleStatus.Active, cancellationToken);

        if (couple is null) return null;

        var partnerId = couple.GetOtherPartnerId(userId);

        return new CoupleDto(
            couple.Id,
            couple.Partner1Id,
            couple.Partner2Id,
            couple.Status,
            couple.ConnectedAtUtc,
            new PartnerDto(partnerId, "partner@nexora.local", "Partner"));
    }
}
