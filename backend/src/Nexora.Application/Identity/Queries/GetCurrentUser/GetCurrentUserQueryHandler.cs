using MediatR;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;
using Nexora.Application.Common.Exceptions;
using Nexora.Application.Common.Interfaces;
using Nexora.Application.Identity.DTOs;
using Nexora.Domain.Identity;

namespace Nexora.Application.Identity.Queries.GetCurrentUser;

public sealed class GetCurrentUserQueryHandler(
    UserManager<ApplicationUser> userManager,
    ICurrentUserService currentUserService,
    ILogger<GetCurrentUserQueryHandler> logger)
    : IRequestHandler<GetCurrentUserQuery, UserProfileDto>
{
    public async Task<UserProfileDto> Handle(GetCurrentUserQuery request, CancellationToken cancellationToken)
    {
        if (!currentUserService.IsAuthenticated || currentUserService.UserId is null)
            throw new ForbiddenAccessException();

        var user = await userManager.FindByIdAsync(currentUserService.UserId.Value.ToString());
        if (user is null)
            throw new NotFoundException("User", currentUserService.UserId.Value);

        var roles = await userManager.GetRolesAsync(user);

        logger.LogDebug("Profile fetched for user {UserId}", user.Id);
        return new UserProfileDto(user.Id, user.Email!, user.FirstName, user.LastName, user.FullName, roles);
    }
}
