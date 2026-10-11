using MediatR;
using Nexora.Application.AI;
using Nexora.Application.Common.Interfaces;

namespace Nexora.Application.AI.Queries.CommunicationCoach;

public sealed record CommunicationCoachQuery(string Message, string? Situation = null) : IRequest<CommunicationCoachResponse>;

public sealed record CommunicationCoachResponse(
    string Suggestion,
    string Provider,
    bool IsAvailable);

public sealed class CommunicationCoachQueryHandler(
    IAIProvider aiProvider,
    ICurrentUserService currentUser) : IRequestHandler<CommunicationCoachQuery, CommunicationCoachResponse>
{
    public async Task<CommunicationCoachResponse> Handle(CommunicationCoachQuery request, CancellationToken cancellationToken)
    {
        _ = currentUser.UserId
            ?? throw new UnauthorizedAccessException("User is not authenticated.");

        if (string.IsNullOrWhiteSpace(request.Message))
        {
            throw new ArgumentException("Message is required.");
        }

        var suggestion = await aiProvider.ImproveCommunicationAsync(
            request.Message,
            request.Situation ?? string.Empty,
            cancellationToken);

        return new CommunicationCoachResponse(suggestion, aiProvider.ProviderName, aiProvider.IsAvailable);
    }
}
