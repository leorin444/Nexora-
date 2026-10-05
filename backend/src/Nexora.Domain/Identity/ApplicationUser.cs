using Microsoft.AspNetCore.Identity;

namespace Nexora.Domain.Identity;

/// <summary>
/// The platform's primary user entity.
/// Extends IdentityUser so we get secure password hashing,
/// claims, roles, and lockout from ASP.NET Core Identity.
/// </summary>
public sealed class ApplicationUser : IdentityUser<Guid>
{
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string? ProfilePictureUrl { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAtUtc { get; set; }

    /// <summary>Full display name derived from first + last name.</summary>
    public string FullName => $"{FirstName} {LastName}".Trim();

    // Navigation
    public ICollection<RefreshToken> RefreshTokens { get; set; } = [];
}
