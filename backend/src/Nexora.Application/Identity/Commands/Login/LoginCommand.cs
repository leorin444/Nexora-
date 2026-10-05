using MediatR;
using Nexora.Application.Identity.DTOs;

namespace Nexora.Application.Identity.Commands.Login;

public sealed record LoginCommand(
    string Email,
    string Password,
    string? IpAddress) : IRequest<AuthResponseDto>;
