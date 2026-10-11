# Multi-stage Dockerfile for Nexora Web API
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy solution and project definitions for optimized caching
COPY Nexora.slnx ./
COPY src/Nexora.Domain/Nexora.Domain.csproj src/Nexora.Domain/
COPY src/Nexora.Application/Nexora.Application.csproj src/Nexora.Application/
COPY src/Nexora.Infrastructure/Nexora.Infrastructure.csproj src/Nexora.Infrastructure/
COPY src/Nexora.Api/Nexora.Api.csproj src/Nexora.Api/

# Restore dependencies
RUN dotnet restore src/Nexora.Api/Nexora.Api.csproj

# Copy full source and publish
COPY src/ ./src/
WORKDIR /src/src/Nexora.Api
RUN dotnet publish -c Release -o /app/publish --no-restore

# Runtime image
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
EXPOSE 8080
EXPOSE 8443

# Non-root user for container security
USER $APP_UID

COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "Nexora.Api.dll"]
