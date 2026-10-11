using MediatR;
using Nexora.Application.AI;
using Nexora.Application.Common.Interfaces;

namespace Nexora.Application.AI.Queries.AskAI;

public sealed record AskAIQuery(string Prompt, string? Context = null) : IRequest<AskAIResponse>;

public sealed record AskAIResponse(string Answer, string Provider, bool IsAvailable);

public sealed class AskAIQueryHandler(
    IAIProvider aiProvider,
    ICurrentUserService currentUser) : IRequestHandler<AskAIQuery, AskAIResponse>
{
    public async Task<AskAIResponse> Handle(AskAIQuery request, CancellationToken cancellationToken)
    {
        _ = currentUser.UserId
            ?? throw new UnauthorizedAccessException("User is not authenticated.");

        if (string.IsNullOrWhiteSpace(request.Prompt))
        {
            throw new ArgumentException("Prompt is required.");
        }

        var fullPrompt = string.IsNullOrWhiteSpace(request.Context)
            ? request.Prompt
            : $"Context: {request.Context}\n\nQuestion: {request.Prompt}";

        var answer = await aiProvider.CompleteAsync(fullPrompt, cancellationToken);

        return new AskAIResponse(answer, aiProvider.ProviderName, aiProvider.IsAvailable);
    }
}
