namespace Nexora.Application.Common.Exceptions;

/// <summary>
/// Thrown when an entity is not found. Maps to HTTP 404.
/// </summary>
public sealed class NotFoundException(string name, object key)
    : Exception($"Entity '{name}' with key '{key}' was not found.");
