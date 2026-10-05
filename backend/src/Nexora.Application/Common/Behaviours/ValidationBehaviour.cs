using FluentValidation;
using MediatR;
using Microsoft.Extensions.Logging;
using Nexora.Application.Common.Exceptions;
using ValidationException = Nexora.Application.Common.Exceptions.ValidationException;

namespace Nexora.Application.Common.Behaviours;

/// <summary>
/// MediatR pipeline behaviour that runs FluentValidation validators before
/// the request handler is executed. Throws <see cref="ValidationException"/>
/// if any validator fails, which the global exception middleware maps to HTTP 400.
/// </summary>
public sealed class ValidationBehaviour<TRequest, TResponse>(
    IEnumerable<IValidator<TRequest>> validators,
    ILogger<ValidationBehaviour<TRequest, TResponse>> logger)
    : IPipelineBehavior<TRequest, TResponse>
    where TRequest : notnull
{
    public async Task<TResponse> Handle(
        TRequest request,
        RequestHandlerDelegate<TResponse> next,
        CancellationToken cancellationToken)
    {
        if (!validators.Any())
            return await next();

        var context = new ValidationContext<TRequest>(request);
        var results = await Task.WhenAll(
            validators.Select(v => v.ValidateAsync(context, cancellationToken)));

        var failures = results
            .SelectMany(r => r.Errors)
            .Where(f => f != null)
            .ToList();

        if (failures.Count > 0)
        {
            logger.LogWarning("Validation failed for {RequestType}: {Errors}",
                typeof(TRequest).Name,
                string.Join(", ", failures.Select(f => f.ErrorMessage)));

            throw new ValidationException(failures);
        }

        return await next();
    }
}
