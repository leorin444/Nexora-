using MediatR;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;
using Nexora.Application.Common.Exceptions;
using Nexora.Application.Common.Interfaces;
using Nexora.Application.Identity.DTOs;
using Nexora.Domain.Identity;

namespace Nexora.Application.Identity.Commands.Login;

public sealed class LoginCommandHandler(
    UserManager<ApplicationUser> userManager,
    ITokenService tokenService,
    ILogger<LoginCommandHandler> logger)
    : IRequestHandler<LoginCommand, AuthResponseDto>
{
    public async Task<AuthResponseDto> Handle(LoginCommand request, CancellationToken cancellationToken)
    {
        var user = await userManager.FindByEmailAsync(request.Email);

        // Use constant-time comparison pattern — same error whether user not found OR password wrong
        if (user is null || !await userManager.CheckPasswordAsync(user, request.Password))
        {
            logger.LogWarning("Failed login attempt for email: {Email}", request.Email);
            throw new ValidationException(
                [new FluentValidation.Results.ValidationFailure("Credentials", "Invalid email or password.")]);
        }

        if (!user.IsActive)
        {
            logger.LogWarning("Login attempt by inactive user: {UserId}", user.Id);
            throw new ForbiddenAccessException();
        }

        var roles = await userManager.GetRolesAsync(user);
        var accessToken = tokenService.GenerateAccessToken(user, roles);
        var (refreshToken, _) = tokenService.GenerateRefreshToken();

        logger.LogInformation("User logged in: {UserId}", user.Id);

        var expiresAt = DateTime.UtcNow.AddMinutes(15);
        return new AuthResponseDto(
            accessToken,
            refreshToken,
            expiresAt,
            new UserProfileDto(user.Id, user.Email!, user.FirstName, user.LastName, user.FullName, roles));
    }
}
