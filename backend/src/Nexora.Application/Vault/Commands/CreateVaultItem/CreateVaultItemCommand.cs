using MediatR;
using Microsoft.EntityFrameworkCore;
using Nexora.Application.Common.Interfaces;
using Nexora.Application.Vault.DTOs;
using Nexora.Domain.Common;
using Nexora.Domain.Couples;
using Nexora.Domain.Vault;

namespace Nexora.Application.Vault.Commands.CreateVaultItem;

public sealed record CreateVaultItemCommand(
    string Title,
    string? Description,
    VaultItemType ItemType,
    string EncryptedPayload,
    string? Tags,
    VisibilityLevel Visibility) : IRequest<VaultItemDto>;

public sealed class CreateVaultItemCommandHandler(
    INexoraDbContext dbContext,
    ICurrentUserService currentUser) : IRequestHandler<CreateVaultItemCommand, VaultItemDto>
{
    public async Task<VaultItemDto> Handle(CreateVaultItemCommand request, CancellationToken cancellationToken)
    {
        var userId = currentUser.UserId
            ?? throw new UnauthorizedAccessException("User is not authenticated.");

        if (string.IsNullOrWhiteSpace(request.Title))
        {
            throw new ArgumentException("Title is required.");
        }

        Guid? coupleId = null;
        if (request.Visibility != VisibilityLevel.Private)
        {
            var couple = await dbContext.Couples
                .AsNoTracking()
                .FirstOrDefaultAsync(c => (c.Partner1Id == userId || c.Partner2Id == userId) && c.Status == CoupleStatus.Active, cancellationToken);

            coupleId = couple?.Id;
        }

        var vaultItem = new VaultItem
        {
            OwnerId = userId,
            CoupleId = coupleId,
            Title = request.Title,
            Description = request.Description,
            ItemType = request.ItemType,
            EncryptedPayload = request.EncryptedPayload,
            Tags = request.Tags,
            Visibility = request.Visibility,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };

        dbContext.VaultItems.Add(vaultItem);
        await dbContext.SaveChangesAsync(cancellationToken);

        return MapToDto(vaultItem);
    }

    internal static VaultItemDto MapToDto(VaultItem item) => new(
        item.Id,
        item.OwnerId,
        item.CoupleId,
        item.Title,
        item.Description,
        item.ItemType,
        item.EncryptedPayload,
        item.Tags,
        item.Visibility,
        item.CreatedAtUtc,
        item.UpdatedAtUtc);
}
