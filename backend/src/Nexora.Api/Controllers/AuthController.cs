using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Nexora.Application.Identity.Commands.Login;
using Nexora.Application.Identity.Commands.Logout;
using Nexora.Application.Identity.Commands.RefreshToken;
using Nexora.Application.Identity.Commands.Register;
using Nexora.Application.Identity.DTOs;

namespace Nexora.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public sealed class AuthController(ISender sender) : ControllerBase
{
    /// <summary>
    /// Register a new user account.
    /// </summary>
    [HttpPost("register")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(AuthResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Register(
        [FromBody] RegisterRequest request,
        CancellationToken cancellationToken)
    {
        var command = new RegisterCommand(
            request.Email,
            request.Password,
            request.FirstName,
            request.LastName);

        var result = await sender.Send(command, cancellationToken);
        return Ok(result);
    }

    /// <summary>
    /// Authenticate and retrieve access & refresh tokens.
    /// </summary>
    [HttpPost("login")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(AuthResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Login(
        [FromBody] LoginRequest request,
        CancellationToken cancellationToken)
    {
        var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString();
        var command = new LoginCommand(request.Email, request.Password, ipAddress);

        var result = await sender.Send(command, cancellationToken);
        return Ok(result);
    }

    /// <summary>
    /// Rotate tokens using a valid refresh token.
    /// </summary>
    [HttpPost("refresh")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(AuthResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> RefreshToken(
        [FromBody] RefreshTokenRequest request,
        CancellationToken cancellationToken)
    {
        var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString();
        var command = new RefreshTokenCommand(request.AccessToken, request.RefreshToken, ipAddress);

        var result = await sender.Send(command, cancellationToken);
        return Ok(result);
    }

    /// <summary>
    /// Revoke a refresh token on logout.
    /// </summary>
    [HttpPost("logout")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> Logout(
        [FromBody] LogoutRequest request,
        CancellationToken cancellationToken)
    {
        var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString();
        var command = new LogoutCommand(request.RefreshToken, ipAddress);

        await sender.Send(command, cancellationToken);
        return NoContent();
    }
}

public sealed record RegisterRequest(
    string Email,
    string Password,
    string FirstName,
    string LastName);

public sealed record LoginRequest(
    string Email,
    string Password);

public sealed record RefreshTokenRequest(
    string AccessToken,
    string RefreshToken);

public sealed record LogoutRequest(
    string RefreshToken);
