using MediatR;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Nexora.Application.Common.Exceptions;
using Nexora.Application.Common.Interfaces;
using Nexora.Application.Identity.DTOs;
using Nexora.Domain.Identity;
using System.Security.Cryptography;
using System.Text;

namespace Nexora.Application.Identity.Commands.RefreshToken;

public sealed class RefreshTokenCommandHandler(
    UserManager<ApplicationUser> userManager,
    ITokenService tokenService,
    INexoraDbContext dbContext,
    ILogger<RefreshTokenCommandHandler> logger)
    : IRequestHandler<RefreshTokenCommand, AuthResponseDto>
{
    public async Task<AuthResponseDto> Handle(RefreshTokenCommand request, CancellationToken cancellationToken)
    {
        var principal = tokenService.GetPrincipalFromExpiredToken(request.AccessToken);
        if (principal is null)
            throw new ValidationException(
                [new FluentValidation.Results.ValidationFailure("AccessToken", "Invalid access token.")]);

        var userIdClaim = principal.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
        if (!Guid.TryParse(userIdClaim, out var userId))
            throw new ValidationException(
                [new FluentValidation.Results.ValidationFailure("AccessToken", "Invalid access token.")]);

        var user = await userManager.FindByIdAsync(userId.ToString());
        if (user is null || !user.IsActive)
            throw new ForbiddenAccessException();

        // Hash the incoming refresh token and look it up
        var incomingHash = HashToken(request.RefreshToken);
        var storedToken = await dbContext.RefreshTokens
            .FirstOrDefaultAsync(t => t.UserId == userId && t.TokenHash == incomingHash, cancellationToken);

        if (storedToken is null || !storedToken.IsActive)
        {
            logger.LogWarning("Invalid/expired refresh token used by user {UserId}", userId);
            throw new ValidationException(
                [new FluentValidation.Results.ValidationFailure("RefreshToken", "Refresh token is invalid or expired.")]);
        }

        // Rotate: revoke old token, issue new pair
        var (newRefreshToken, newHash) = tokenService.GenerateRefreshToken();

        storedToken.RevokedAtUtc = DateTime.UtcNow;
        storedToken.RevokedByIp = request.IpAddress;
        storedToken.ReplacedByTokenHash = newHash;

        var newToken = new Domain.Identity.RefreshToken
        {
            UserId = userId,
            TokenHash = newHash,
            ExpiresAtUtc = DateTime.UtcNow.AddDays(7),
            CreatedByIp = request.IpAddress
        };
        dbContext.RefreshTokens.Add(newToken);
        await dbContext.SaveChangesAsync(cancellationToken);

        var roles = await userManager.GetRolesAsync(user);
        var accessToken = tokenService.GenerateAccessToken(user, roles);
        var expiresAt = DateTime.UtcNow.AddMinutes(15);

        logger.LogInformation("Tokens refreshed for user {UserId}", userId);
        return new AuthResponseDto(
            accessToken,
            newRefreshToken,
            expiresAt,
            new UserProfileDto(user.Id, user.Email!, user.FirstName, user.LastName, user.FullName, roles));
    }

    private static string HashToken(string token)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(token));
        return Convert.ToBase64String(bytes);
    }
}
