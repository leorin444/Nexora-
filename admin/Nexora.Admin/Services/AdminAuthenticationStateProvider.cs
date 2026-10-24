using System.Security.Claims;
using Microsoft.AspNetCore.Components.Authorization;
using Nexora.Admin.Models;

namespace Nexora.Admin.Services;

public sealed class AdminAuthenticationStateProvider : AuthenticationStateProvider
{
    private readonly NexoraApiClient _apiClient;
    private ClaimsPrincipal _currentPrincipal = new(new ClaimsIdentity());
    private UserProfile? _currentUser;

    public AdminAuthenticationStateProvider(NexoraApiClient apiClient)
    {
        _apiClient = apiClient;
    }

    public UserProfile? CurrentUser => _currentUser;
    public bool IsAuthenticated => _currentUser != null && (_currentPrincipal.Identity?.IsAuthenticated ?? false);

    public override Task<AuthenticationState> GetAuthenticationStateAsync()
    {
        return Task.FromResult(new AuthenticationState(_currentPrincipal));
    }

    public async Task<LoginResult> LoginAsync(string email, string password)
    {
        if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password))
        {
            return new LoginResult(false, "Email and password are required.");
        }

        try
        {
            var authResponse = await _apiClient.LoginAsync(email, password);

            if (authResponse == null)
            {
                return new LoginResult(false, "Invalid email or password. Please verify your credentials.");
            }

            // Enforce administrator role check
            var isUserAdmin = authResponse.User.Roles.Any(r => string.Equals(r, "Admin", StringComparison.OrdinalIgnoreCase));
            if (!isUserAdmin)
            {
                _apiClient.ClearAccessToken();
                return new LoginResult(false, "Access Denied: You do not have administrator permissions to access this portal.");
            }

            // Create claims identity for authenticated Admin
            var claims = new List<Claim>
            {
                new(ClaimTypes.NameIdentifier, authResponse.User.Id.ToString()),
                new(ClaimTypes.Name, string.IsNullOrWhiteSpace(authResponse.User.FullName) ? authResponse.User.Email : authResponse.User.FullName),
                new(ClaimTypes.Email, authResponse.User.Email)
            };

            foreach (var role in authResponse.User.Roles)
            {
                claims.Add(new Claim(ClaimTypes.Role, role));
            }

            var identity = new ClaimsIdentity(claims, "NexoraAdminAuth");
            _currentPrincipal = new ClaimsPrincipal(identity);
            _currentUser = authResponse.User;

            NotifyAuthenticationStateChanged(GetAuthenticationStateAsync());

            return new LoginResult(true, null, _currentUser);
        }
        catch (HttpRequestException)
        {
            return new LoginResult(false, "Cannot connect to the backend API server. Please ensure the backend is running.");
        }
        catch (Exception ex)
        {
            return new LoginResult(false, $"An unexpected error occurred during authentication: {ex.Message}");
        }
    }

    public Task LogoutAsync()
    {
        _apiClient.ClearAccessToken();
        _currentPrincipal = new ClaimsPrincipal(new ClaimsIdentity());
        _currentUser = null;

        NotifyAuthenticationStateChanged(GetAuthenticationStateAsync());
        return Task.CompletedTask;
    }
}
