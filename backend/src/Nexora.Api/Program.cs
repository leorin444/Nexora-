using Hangfire;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.AspNetCore.Identity;
using Microsoft.IdentityModel.Tokens;
using Nexora.Api.Middleware;
using Nexora.Application;
using Nexora.Domain.Identity;
using Nexora.Infrastructure;
using Nexora.Infrastructure.Persistence;
using Serilog;
using System.Text;

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
    var allowedOrigins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? [];
    builder.Services.AddCors(options =>
    {
        options.AddPolicy("NexoraPolicy", policy =>
            policy.WithOrigins(allowedOrigins)
                  .AllowAnyHeader()
                  .AllowAnyMethod()
                  .AllowCredentials());
    });

    // ─── Application + Infrastructure layers ─────────────────────────────────
    builder.Services.AddApplicationServices();
    builder.Services.AddInfrastructureServices(builder.Configuration);

    // ─── JWT Authentication ───────────────────────────────────────────────────
    var jwtKey = builder.Configuration["Jwt:SecretKey"]
        ?? throw new InvalidOperationException("Jwt:SecretKey is not configured.");

    builder.Services.AddAuthentication(options =>
    {
        options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
        options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
    })
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"] ?? "NexoraApi",
            ValidAudience = builder.Configuration["Jwt:Audience"] ?? "NexoraClients",
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
            ClockSkew = TimeSpan.FromSeconds(30)
        };

        // SignalR: allow token from query string for WebSocket connections
        options.Events = new JwtBearerEvents
        {
            OnMessageReceived = ctx =>
            {
                var accessToken = ctx.Request.Query["access_token"];
                var path = ctx.HttpContext.Request.Path;
                if (!string.IsNullOrEmpty(accessToken) && path.StartsWithSegments("/hubs"))
                    ctx.Token = accessToken;
                return Task.CompletedTask;
            }
        };
    });

    builder.Services.AddAuthorization(options =>
    {
        options.AddPolicy("AdminOnly", p => p.RequireRole("Admin"));
        options.AddPolicy("UserOrAdmin", p => p.RequireRole("User", "Admin"));
    });

    // ─── Controllers ──────────────────────────────────────────────────────────
    builder.Services.AddControllers();

    // ─── OpenAPI (Swagger) ────────────────────────────────────────────────────
    builder.Services.AddEndpointsApiExplorer();
    builder.Services.AddSwaggerGen(c =>
    {
        c.SwaggerDoc("v1", new Microsoft.OpenApi.OpenApiInfo { Title = "Nexora API", Version = "v1" });
    });

    // ─── SignalR ──────────────────────────────────────────────────────────────
    builder.Services.AddSignalR();

    // ─────────────────────────────────────────────────────────────────────────
    var app = builder.Build();

    // ─── Database migration + seeding on startup ──────────────────────────────
    using (var scope = app.Services.CreateScope())
    {
        var db = scope.ServiceProvider.GetRequiredService<NexoraDbContext>();
        var userManager = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();
        var roleManager = scope.ServiceProvider.GetRequiredService<RoleManager<IdentityRole<Guid>>>();
        var seederLogger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
        await DatabaseSeeder.SeedAsync(db, userManager, roleManager, seederLogger);
    }

    // ─── Middleware pipeline ──────────────────────────────────────────────────
    app.UseMiddleware<GlobalExceptionMiddleware>();
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
    app.MapHub<Nexora.Infrastructure.Realtime.NexoraHub>("/hubs/nexora");
    app.MapHealthChecks("/health");
    app.MapHangfireDashboard("/hangfire", new DashboardOptions
    {
        Authorization = [] // locked down — no anonymous access in production
    });

    app.Run();
}
catch (Exception ex) when (ex.GetType().Name != "HostAbortedException")
{
    Log.Fatal(ex, "Nexora API terminated unexpectedly");
}
finally
{
    Log.CloseAndFlush();
}
