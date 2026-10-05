using Nexora.Domain.Identity;

namespace Nexora.Application.Common.Interfaces;

/// <summary>
/// Generates and validates JWT access tokens and refresh tokens.
/// Defined in Application so use cases can depend on it without
/// referencing the Infrastructure JWT implementation directly.
/// </summary>
public interface ITokenService
{
    /// <summary>Generates a short-lived JWT access token for the given user.</summary>
    string GenerateAccessToken(ApplicationUser user, IList<string> roles);

    /// <summary>
    /// Generates a cryptographically random refresh token string.
    /// Returns both the plaintext token (to send to client) and its hash (to persist).
    /// </summary>
    (string Token, string Hash) GenerateRefreshToken();

    /// <summary>
    /// Validates an expired access token and returns the principal.
    /// Used during token refresh to extract the user ID from the old token.
    /// Returns null if the token cannot be validated structurally.
    /// </summary>
    System.Security.Claims.ClaimsPrincipal? GetPrincipalFromExpiredToken(string token);
}
