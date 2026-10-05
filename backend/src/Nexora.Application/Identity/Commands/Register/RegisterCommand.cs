using MediatR;
using Nexora.Application.Identity.DTOs;

namespace Nexora.Application.Identity.Commands.Register;

public sealed record RegisterCommand(
    string Email,
    string Password,
    string FirstName,
    string LastName) : IRequest<AuthResponseDto>;
