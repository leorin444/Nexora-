namespace Nexora.Application.Common.Exceptions;

/// <summary>
/// Thrown when a user attempts to access a resource they are not authorized for.
/// Maps to HTTP 403.
/// </summary>
public sealed class ForbiddenAccessException()
    : Exception("Access to this resource is forbidden.");
