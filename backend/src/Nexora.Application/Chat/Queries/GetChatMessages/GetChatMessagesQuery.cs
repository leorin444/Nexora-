using MediatR;
using Microsoft.EntityFrameworkCore;
using Nexora.Application.Chat.Commands.SendMessage;
using Nexora.Application.Chat.DTOs;
using Nexora.Application.Common.Interfaces;
using Nexora.Domain.Couples;

namespace Nexora.Application.Chat.Queries.GetChatMessages;

public sealed record GetChatMessagesQuery(
    int Limit = 50,
    DateTime? BeforeUtc = null) : IRequest<IList<ChatMessageDto>>;

public sealed class GetChatMessagesQueryHandler(
    INexoraDbContext dbContext,
    ICurrentUserService currentUser) : IRequestHandler<GetChatMessagesQuery, IList<ChatMessageDto>>
{
    public async Task<IList<ChatMessageDto>> Handle(GetChatMessagesQuery request, CancellationToken cancellationToken)
    {
        var userId = currentUser.UserId
            ?? throw new UnauthorizedAccessException("User is not authenticated.");

        var couple = await dbContext.Couples
            .AsNoTracking()
            .FirstOrDefaultAsync(c => (c.Partner1Id == userId || c.Partner2Id == userId) && c.Status == CoupleStatus.Active, cancellationToken)
            ?? throw new InvalidOperationException("User must be in an active couple to retrieve chat messages.");

        var query = dbContext.ChatMessages
            .AsNoTracking()
            .Where(m => m.CoupleId == couple.Id);

        if (request.BeforeUtc.HasValue)
        {
            query = query.Where(m => m.SentAtUtc < request.BeforeUtc.Value);
        }

        var messages = await query
            .OrderByDescending(m => m.SentAtUtc)
            .Take(Math.Clamp(request.Limit, 1, 100))
            .ToListAsync(cancellationToken);

        // Return chronological
        messages.Reverse();

        return messages.Select(SendMessageCommandHandler.MapToDto).ToList();
    }
}
