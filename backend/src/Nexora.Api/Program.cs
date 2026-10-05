using Nexora.Api.Middleware;
using Nexora.Application;
using Nexora.Infrastructure;
using Serilog;

// ─── Bootstrap logger (captures startup errors) ─────────────────────────────
Log.Logger = new LoggerConfiguration()
    .WriteTo.Console()
    .CreateBootstrapLogger();

try
{
    Log.Information("Starting Nexora API");

    var builder = WebApplication.CreateBuilder(args);

    // ─── Serilog ─────────────────────────────────────────────────────────────
    builder.Host.UseSerilog((ctx, services, config) => config
        .ReadFrom.Configuration(ctx.Configuration)
        .ReadFrom.Services(services)
        .Enrich.FromLogContext()
        .WriteTo.Console()
        .WriteTo.File("logs/nexora-.log", rollingInterval: RollingInterval.Day));

    // ─── CORS ─────────────────────────────────────────────────────────────────
    var allowedOrigins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>()
                         ?? [];
    builder.Services.AddCors(options =>
    {
        options.AddPolicy("NexoraPolicy", policy =>
            policy.WithOrigins(allowedOrigins)
                  .AllowAnyHeader()
                  .AllowAnyMethod()
                  .AllowCredentials());
    });

    // ─── Application layer ────────────────────────────────────────────────────
    builder.Services.AddApplicationServices();

    // ─── Infrastructure layer ─────────────────────────────────────────────────
    builder.Services.AddInfrastructureServices(builder.Configuration);

    // ─── Controllers ──────────────────────────────────────────────────────────
    builder.Services.AddControllers();

    // ─── Health checks ────────────────────────────────────────────────────────
    builder.Services.AddHealthChecks()
        .AddSqlServer(
            builder.Configuration.GetConnectionString("DefaultConnection")!,
            name: "sql-server",
            tags: ["db", "sql"]);

    // ─── OpenAPI (Swagger) ────────────────────────────────────────────────────
    builder.Services.AddEndpointsApiExplorer();
    builder.Services.AddSwaggerGen(c =>
    {
        c.SwaggerDoc("v1", new Microsoft.OpenApi.OpenApiInfo { Title = "Nexora API", Version = "v1" });
    });

    // ─── SignalR ──────────────────────────────────────────────────────────────
    builder.Services.AddSignalR();

    var app = builder.Build();

    // ─── Global exception handler ─────────────────────────────────────────────
    app.UseMiddleware<GlobalExceptionMiddleware>();

    // ─── Request logging ──────────────────────────────────────────────────────
    app.UseSerilogRequestLogging();

    if (app.Environment.IsDevelopment())
    {
        app.UseSwagger();
        app.UseSwaggerUI();
    }

    app.UseHttpsRedirection();
    app.UseCors("NexoraPolicy");
    app.UseAuthentication();
    app.UseAuthorization();

    app.MapControllers();

    // ─── Health endpoint ──────────────────────────────────────────────────────
    app.MapHealthChecks("/health");

    app.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, "Nexora API terminated unexpectedly");
}
finally
{
    Log.CloseAndFlush();
}
