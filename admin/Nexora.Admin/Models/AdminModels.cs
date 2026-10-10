namespace Nexora.Admin.Models;

public sealed record AuthResponse(
    string AccessToken,
    string RefreshToken,
    DateTime AccessTokenExpiresAt,
    UserProfile User);

public sealed record UserProfile(
    Guid Id,
    string Email,
    string FirstName,
    string LastName,
    string FullName,
    IList<string> Roles);

public sealed record FeatureFlagItem(
    string Name,
    bool IsEnabled);
