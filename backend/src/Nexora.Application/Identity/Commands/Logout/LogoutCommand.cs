using MediatR;

namespace Nexora.Application.Identity.Commands.Logout;

/// <summary>Revokes the user's current refresh token, effectively logging them out.</summary>
public sealed record LogoutCommand(
    string RefreshToken,
    string? IpAddress) : IRequest;
