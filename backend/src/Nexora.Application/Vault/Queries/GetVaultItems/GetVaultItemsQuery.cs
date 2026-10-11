using MediatR;
using Microsoft.EntityFrameworkCore;
using Nexora.Application.Common.Interfaces;
using Nexora.Application.Vault.Commands.CreateVaultItem;
using Nexora.Application.Vault.DTOs;
using Nexora.Domain.Common;
using Nexora.Domain.Couples;

namespace Nexora.Application.Vault.Queries.GetVaultItems;

public sealed record GetVaultItemsQuery(string? Search = null) : IRequest<IList<VaultItemDto>>;

public sealed class GetVaultItemsQueryHandler(
    INexoraDbContext dbContext,
    ICurrentUserService currentUser) : IRequestHandler<GetVaultItemsQuery, IList<VaultItemDto>>
{
    public async Task<IList<VaultItemDto>> Handle(GetVaultItemsQuery request, CancellationToken cancellationToken)
    {
        var userId = currentUser.UserId
            ?? throw new UnauthorizedAccessException("User is not authenticated.");

        var couple = await dbContext.Couples
            .AsNoTracking()
            .FirstOrDefaultAsync(c => (c.Partner1Id == userId || c.Partner2Id == userId) && c.Status == CoupleStatus.Active, cancellationToken);

        var partnerId = couple?.GetOtherPartnerId(userId);

        var query = dbContext.VaultItems
            .AsNoTracking()
            .Where(v =>
                v.OwnerId == userId ||
                (partnerId.HasValue && v.OwnerId == partnerId.Value && v.Visibility != VisibilityLevel.Private));

        if (!string.IsNullOrWhiteSpace(request.Search))
        {
            var search = request.Search.Trim().ToLower();
            query = query.Where(v =>
                v.Title.ToLower().Contains(search) ||
                (v.Description != null && v.Description.ToLower().Contains(search)) ||
                (v.Tags != null && v.Tags.ToLower().Contains(search)));
        }

        var items = await query
            .OrderByDescending(v => v.UpdatedAtUtc)
            .ToListAsync(cancellationToken);

        return items.Select(CreateVaultItemCommandHandler.MapToDto).ToList();
    }
}
