using Microsoft.AspNetCore.Http;
using Nexora.Application.Common.Interfaces;
using System.Security.Claims;

namespace Nexora.Infrastructure.Identity;

/// <summary>
/// Resolves the current user's identity from the HTTP request context.
/// Application layer uses ICurrentUserService — never HttpContext directly.
/// </summary>
internal sealed class CurrentUserService(IHttpContextAccessor httpContextAccessor) : ICurrentUserService
{
    public Guid? UserId
    {
        get
        {
            var value = httpContextAccessor.HttpContext?.User
                .FindFirstValue(ClaimTypes.NameIdentifier);
            return Guid.TryParse(value, out var id) ? id : null;
        }
    }

    public bool IsAuthenticated =>
        httpContextAccessor.HttpContext?.User.Identity?.IsAuthenticated == true;
}
