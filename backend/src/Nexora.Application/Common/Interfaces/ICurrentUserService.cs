namespace Nexora.Application.Common.Interfaces;

/// <summary>
/// Provides identity information about the currently authenticated user.
/// Use this throughout the Application layer — never access HttpContext directly.
/// </summary>
public interface ICurrentUserService
{
    /// <summary>The authenticated user's ID, or null if not authenticated.</summary>
    Guid? UserId { get; }

    /// <summary>Whether the current request is authenticated.</summary>
    bool IsAuthenticated { get; }
}
