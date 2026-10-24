using System.ComponentModel.DataAnnotations;

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

public sealed class LoginModel
{
    [Required(ErrorMessage = "Email address is required")]
    [EmailAddress(ErrorMessage = "Please enter a valid email address")]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "Password is required")]
    [MinLength(6, ErrorMessage = "Password must be at least 6 characters")]
    public string Password { get; set; } = string.Empty;
}

public sealed record LoginResult(
    bool Success,
    string? ErrorMessage = null,
    UserProfile? User = null);
