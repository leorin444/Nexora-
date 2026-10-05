using System.Net;
using System.Text.Json;
using Nexora.Application.Common.Exceptions;

namespace Nexora.Api.Middleware;

/// <summary>
/// Catches unhandled exceptions and returns a consistent JSON error response.
/// Sensitive exception details are hidden in non-development environments.
/// </summary>
public sealed class GlobalExceptionMiddleware(
    RequestDelegate next,
    ILogger<GlobalExceptionMiddleware> logger,
    IHostEnvironment env)
{
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (Exception ex)
        {
            await HandleExceptionAsync(context, ex);
        }
    }

    private async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        var (statusCode, title, detail) = exception switch
        {
            ValidationException ve => (
                HttpStatusCode.BadRequest,
                "Validation failed",
                string.Join("; ", ve.Errors.SelectMany(e => e.Value))),

            NotFoundException ne => (
                HttpStatusCode.NotFound,
                "Resource not found",
                ne.Message),

            ForbiddenAccessException => (
                HttpStatusCode.Forbidden,
                "Access denied",
                "You do not have permission to perform this action."),

            UnauthorizedAccessException => (
                HttpStatusCode.Unauthorized,
                "Unauthorized",
                "Authentication is required."),

            _ => (
                HttpStatusCode.InternalServerError,
                "An unexpected error occurred",
                env.IsDevelopment() ? exception.Message : "Please try again later.")
        };

        logger.LogError(exception,
            "Unhandled exception [{StatusCode}] {Title} — Path: {Path}",
            (int)statusCode, title, context.Request.Path);

        context.Response.ContentType = "application/problem+json";
        context.Response.StatusCode = (int)statusCode;

        var problem = new
        {
            type = $"https://httpstatuses.com/{(int)statusCode}",
            title,
            status = (int)statusCode,
            detail,
            instance = context.Request.Path.Value,
            traceId = context.TraceIdentifier
        };

        var json = JsonSerializer.Serialize(problem, new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase
        });

        await context.Response.WriteAsync(json);
    }
}
