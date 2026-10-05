using FluentValidation;
using MediatR;
using Microsoft.Extensions.DependencyInjection;
using Nexora.Application.Common.Behaviours;
using System.Reflection;

namespace Nexora.Application;

/// <summary>
/// Registers all Application layer services into the DI container.
/// Called from the API and Admin startup.
/// </summary>
public static class DependencyInjection
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        services.AddMediatR(cfg =>
        {
            cfg.RegisterServicesFromAssembly(Assembly.GetExecutingAssembly());
            cfg.AddBehavior(typeof(IPipelineBehavior<,>), typeof(ValidationBehaviour<,>));
            cfg.AddBehavior(typeof(IPipelineBehavior<,>), typeof(LoggingBehaviour<,>));
        });

        services.AddValidatorsFromAssembly(Assembly.GetExecutingAssembly());

        return services;
    }
}
