using MediatR;
using Microsoft.Extensions.Logging;

namespace Nexora.Application.Common.Behaviours;

/// <summary>
/// MediatR pipeline behaviour that logs the start and completion of every
/// command and query. Slow requests (>500ms) are logged at Warning level.
/// </summary>
public sealed class LoggingBehaviour<TRequest, TResponse>(
    ILogger<LoggingBehaviour<TRequest, TResponse>> logger)
    : IPipelineBehavior<TRequest, TResponse>
    where TRequest : notnull
{
    private static readonly TimeSpan SlowRequestThreshold = TimeSpan.FromMilliseconds(500);

    public async Task<TResponse> Handle(
        TRequest request,
        RequestHandlerDelegate<TResponse> next,
        CancellationToken cancellationToken)
    {
        var requestName = typeof(TRequest).Name;
        logger.LogInformation("Nexora Request: {RequestName}", requestName);

        var start = System.Diagnostics.Stopwatch.GetTimestamp();

        var response = await next();

        var elapsed = System.Diagnostics.Stopwatch.GetElapsedTime(start);

        if (elapsed > SlowRequestThreshold)
        {
            logger.LogWarning(
                "Slow Nexora Request: {RequestName} took {ElapsedMs}ms",
                requestName, elapsed.TotalMilliseconds);
        }
        else
        {
            logger.LogInformation(
                "Nexora Request completed: {RequestName} in {ElapsedMs}ms",
                requestName, elapsed.TotalMilliseconds);
        }

        return response;
    }
}
