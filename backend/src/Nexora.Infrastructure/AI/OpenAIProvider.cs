using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Nexora.Application.AI;

namespace Nexora.Infrastructure.AI;

/// <summary>
/// OpenAI-compatible AI provider (works with OpenAI, Azure OpenAI, or any
/// compatible endpoint such as LM Studio / Ollama with OpenAI-compat mode).
/// </summary>
public sealed class OpenAIProvider : IAIProvider
{
    private readonly HttpClient _httpClient;
    private readonly string _model;
    private readonly ILogger<OpenAIProvider> _logger;

    public bool IsAvailable { get; }
    public string ProviderName => $"OpenAI ({_model})";

    public OpenAIProvider(IConfiguration configuration, IHttpClientFactory httpClientFactory, ILogger<OpenAIProvider> logger)
    {
        _logger = logger;
        _httpClient = httpClientFactory.CreateClient("AIProvider");

        var apiKey = configuration["AI:OpenAI:ApiKey"];
        var endpoint = configuration["AI:OpenAI:Endpoint"] ?? "https://api.openai.com/v1";
        _model = configuration["AI:OpenAI:Model"] ?? "gpt-4o-mini";

        if (string.IsNullOrWhiteSpace(apiKey))
        {
            _logger.LogWarning("OpenAI API key is not configured. AI features will use the fallback provider.");
            IsAvailable = false;
            return;
        }

        _httpClient.BaseAddress = new Uri(endpoint.TrimEnd('/') + "/");
        _httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {apiKey}");
        IsAvailable = true;
    }

    public async Task<string> CompleteAsync(string prompt, CancellationToken cancellationToken = default)
    {
        if (!IsAvailable) return "AI is not configured.";

        return await SendChatCompletionAsync(
            "You are Nexora AI, a helpful personal and relationship assistant. Be warm, empathetic, and concise.",
            prompt,
            cancellationToken);
    }

    public async Task<string> SummarizeAsync(string content, CancellationToken cancellationToken = default)
    {
        if (!IsAvailable) return string.Empty;

        return await SendChatCompletionAsync(
            "You are a concise summarizer. Provide a brief summary of the following text.",
            content,
            cancellationToken);
    }

    public async Task<IReadOnlyList<string>> TagAsync(string content, CancellationToken cancellationToken = default)
    {
        if (!IsAvailable) return [];

        var response = await SendChatCompletionAsync(
            "Generate 3-5 relevant comma-separated tags for the given text. Output only tags separated by commas.",
            content,
            cancellationToken);

        return response.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
    }

    public async Task<string> ImproveCommunicationAsync(string text, string context, CancellationToken cancellationToken = default)
    {
        if (!IsAvailable) return text;

        var system = "You are Nexora Communication Coach — an empathetic relationship communication expert. " +
                     "Suggest a kind, clear, empathetic improvement of the user's message to their partner. " +
                     (string.IsNullOrEmpty(context) ? "" : $"Context: {context}");

        return await SendChatCompletionAsync(system, text, cancellationToken);
    }

    private async Task<string> SendChatCompletionAsync(string systemPrompt, string userMessage, CancellationToken cancellationToken)
    {
        try
        {
            var requestBody = new
            {
                model = _model,
                messages = new object[]
                {
                    new { role = "system", content = systemPrompt },
                    new { role = "user", content = userMessage }
                },
                max_tokens = 1024,
                temperature = 0.7
            };

            var json = JsonSerializer.Serialize(requestBody);
            var content = new StringContent(json, Encoding.UTF8, "application/json");

            var response = await _httpClient.PostAsync("chat/completions", content, cancellationToken);
            if (!response.IsSuccessStatusCode)
            {
                var errorBody = await response.Content.ReadAsStringAsync(cancellationToken);
                _logger.LogError("OpenAI API error {StatusCode}: {Body}", response.StatusCode, errorBody);
                return "I'm having trouble connecting to the AI service right now. Please try again later.";
            }

            var result = await response.Content.ReadFromJsonAsync<OpenAIChatResponse>(cancellationToken: cancellationToken);
            return result?.Choices?.FirstOrDefault()?.Message?.Content ?? "I couldn't generate a response.";
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "OpenAI provider threw an exception");
            return "An error occurred while processing your request.";
        }
    }

    private sealed class OpenAIChatResponse
    {
        [JsonPropertyName("choices")]
        public List<Choice>? Choices { get; set; }
    }

    private sealed class Choice
    {
        [JsonPropertyName("message")]
        public ChatMsg? Message { get; set; }
    }

    private sealed class ChatMsg
    {
        [JsonPropertyName("content")]
        public string? Content { get; set; }
    }
}
