using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Nexora.Application.AI;
using Nexora.Infrastructure.AI;

namespace Nexora.Infrastructure;

/// <summary>
/// Registers all Infrastructure layer services into the DI container.
/// Called from the API and Admin startup.
/// </summary>
public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructureServices(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        // ─── AI Provider ──────────────────────────────────────────────────────
        // Register the appropriate AI provider based on configuration.
        // The application functions fully when AI is "None".
        var aiProvider = configuration.GetValue<string>("AI:Provider") ?? "None";
        services.AddAIProvider(aiProvider, configuration);

        // ─── Health check dependencies ─────────────────────────────────────────
        services.AddHealthChecks();

        return services;
    }

    private static IServiceCollection AddAIProvider(
        this IServiceCollection services,
        string providerName,
        IConfiguration configuration)
    {
        // Future: add Cloud and Ollama provider registrations here
        // based on providerName value ("Cloud", "Ollama", "None")
        services.AddSingleton<IAIProvider, NullAIProvider>();
        return services;
    }
}
