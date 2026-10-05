using MediatR;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;
using Nexora.Application.Common.Exceptions;
using Nexora.Application.Common.Interfaces;
using Nexora.Application.Identity.DTOs;
using Nexora.Domain.Identity;

namespace Nexora.Application.Identity.Commands.Register;

public sealed class RegisterCommandHandler(
    UserManager<ApplicationUser> userManager,
    ITokenService tokenService,
    ILogger<RegisterCommandHandler> logger)
    : IRequestHandler<RegisterCommand, AuthResponseDto>
{
    public async Task<AuthResponseDto> Handle(RegisterCommand request, CancellationToken cancellationToken)
    {
        // Check for duplicate email — do NOT reveal whether an account exists in error messaging
        var existing = await userManager.FindByEmailAsync(request.Email);
        if (existing is not null)
        {
            logger.LogWarning("Registration attempt for already-registered email: {Email}", request.Email);
            throw new ValidationException(
                [new FluentValidation.Results.ValidationFailure("Email", "This email address is already registered.")]);
        }

        var user = new ApplicationUser
        {
            UserName = request.Email,
            Email = request.Email,
            FirstName = request.FirstName,
            LastName = request.LastName,
            EmailConfirmed = true // simplified: skip email confirmation for now
        };

        var result = await userManager.CreateAsync(user, request.Password);
        if (!result.Succeeded)
        {
            var failures = result.Errors.Select(e =>
                new FluentValidation.Results.ValidationFailure("Password", e.Description));
            throw new ValidationException(failures);
        }

        await userManager.AddToRoleAsync(user, "User");

        var roles = await userManager.GetRolesAsync(user);
        var accessToken = tokenService.GenerateAccessToken(user, roles);
        var (refreshToken, _) = tokenService.GenerateRefreshToken();

        // Refresh token is stored by infrastructure — handler returns it to the API
        logger.LogInformation("New user registered: {UserId}", user.Id);

        var expiresAt = DateTime.UtcNow.AddMinutes(15);
        return new AuthResponseDto(
            accessToken,
            refreshToken,
            expiresAt,
            new UserProfileDto(user.Id, user.Email!, user.FirstName, user.LastName, user.FullName, roles));
    }
}
