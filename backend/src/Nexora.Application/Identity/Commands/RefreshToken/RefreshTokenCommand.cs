using MediatR;
using Nexora.Application.Identity.DTOs;

namespace Nexora.Application.Identity.Commands.RefreshToken;

public sealed record RefreshTokenCommand(
    string AccessToken,
    string RefreshToken,
    string? IpAddress) : IRequest<AuthResponseDto>;
