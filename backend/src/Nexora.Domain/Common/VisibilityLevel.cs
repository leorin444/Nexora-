namespace Nexora.Domain.Common;

/// <summary>
/// Defines explicit ownership/visibility level for resources.
/// Security rule: Backend MUST enforce this policy on every access request.
/// </summary>
public enum VisibilityLevel
{
    /// <summary>Only the resource owner can access/modify.</summary>
    Private = 0,

    /// <summary>Explicitly shared with couple context.</summary>
    Shared = 1,

    /// <summary>Connected partner can view/access, but unrelated users cannot.</summary>
    PartnerVisible = 2
}
