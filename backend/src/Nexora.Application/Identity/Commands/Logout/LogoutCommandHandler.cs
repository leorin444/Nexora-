using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Nexora.Application.Common.Interfaces;
using System.Security.Cryptography;
using System.Text;

namespace Nexora.Application.Identity.Commands.Logout;

public sealed class LogoutCommandHandler(
    INexoraDbContext dbContext,
    ILogger<LogoutCommandHandler> logger)
    : IRequestHandler<LogoutCommand>
{
    public async Task Handle(LogoutCommand request, CancellationToken cancellationToken)
    {
        var hash = HashToken(request.RefreshToken);
        var token = await dbContext.RefreshTokens
            .FirstOrDefaultAsync(t => t.TokenHash == hash && t.RevokedAtUtc == null, cancellationToken);

        if (token is not null)
        {
            token.RevokedAtUtc = DateTime.UtcNow;
            token.RevokedByIp = request.IpAddress;
            await dbContext.SaveChangesAsync(cancellationToken);
            logger.LogInformation("Refresh token revoked for user {UserId}", token.UserId);
        }
        // Silently succeed even if token wasn't found — prevents enumeration
    }

    private static string HashToken(string token)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(token));
        return Convert.ToBase64String(bytes);
    }
}
