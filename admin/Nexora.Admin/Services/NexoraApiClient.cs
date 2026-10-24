using System.Net.Http.Headers;
using System.Net.Http.Json;
using Nexora.Admin.Models;

namespace Nexora.Admin.Services;

public sealed class NexoraApiClient(HttpClient httpClient)
{
    private string? _accessToken;

    public string? AccessToken => _accessToken;

    public void SetAccessToken(string token)
    {
        _accessToken = token;
        httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
    }

    public void ClearAccessToken()
    {
        _accessToken = null;
        httpClient.DefaultRequestHeaders.Authorization = null;
    }

    public async Task<AuthResponse?> LoginAsync(string email, string password)
    {
        try
        {
            var response = await httpClient.PostAsJsonAsync("/api/auth/login", new { email, password });
            if (response.IsSuccessStatusCode)
            {
                var auth = await response.Content.ReadFromJsonAsync<AuthResponse>();
                if (auth != null)
                {
                    SetAccessToken(auth.AccessToken);
                }
                return auth;
            }
        }
        catch (Exception)
        {
            // Network or connection exception handled upstream
        }
        return null;
    }

    public async Task<IDictionary<string, bool>?> GetFeatureFlagsAsync()
    {
        return await httpClient.GetFromJsonAsync<IDictionary<string, bool>>("/api/features");
    }

    public async Task<bool> UpdateFeatureFlagAsync(string name, bool isEnabled)
    {
        var response = await httpClient.PutAsJsonAsync($"/api/admin/features/{name}", new { isEnabled });
        return response.IsSuccessStatusCode;
    }

    public async Task<bool> CheckHealthAsync()
    {
        try
        {
            var response = await httpClient.GetAsync("/api/system/status");
            return response.IsSuccessStatusCode;
        }
        catch
        {
            return false;
        }
    }
}
