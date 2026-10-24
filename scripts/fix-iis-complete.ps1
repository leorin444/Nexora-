# ============================================================
# NEXORA API - COMPLETE IIS FIX
# Run this as Administrator in PowerShell
# ============================================================

Write-Host "Starting Nexora API IIS Fix..." -ForegroundColor Cyan

# STEP 1: Change AppPool identity to LocalSystem
Import-Module WebAdministration
Write-Host "[1/6] Setting AppPool identity to LocalSystem..."
Set-ItemProperty "IIS:\AppPools\NexoraApiPool" processModel.identityType LocalSystem
Write-Host "      OK" -ForegroundColor Green

# STEP 2: Create logs folder with full permissions
Write-Host "[2/6] Creating logs folder..."
$logsPath = "C:\inetpub\wwwroot\Nexora.Api\logs"
New-Item -ItemType Directory -Path $logsPath -Force | Out-Null
icacls $logsPath /grant "Everyone:(OI)(CI)F" /T | Out-Null
Write-Host "      OK" -ForegroundColor Green

# STEP 3: Write correct web.config
Write-Host "[3/6] Writing web.config..."
$webconfig = @'
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <location path="." inheritInChildApplications="false">
    <system.webServer>
      <handlers>
        <add name="aspNetCore" path="*" verb="*" modules="AspNetCoreModuleV2" resourceType="Unspecified" />
      </handlers>
      <aspNetCore processPath="C:\Program Files\dotnet\dotnet.exe"
                  arguments=".\Nexora.Api.dll"
                  stdoutLogEnabled="true"
                  stdoutLogFile=".\logs\stdout"
                  hostingModel="inprocess">
        <environmentVariables>
          <environmentVariable name="ASPNETCORE_ENVIRONMENT" value="Development" />
        </environmentVariables>
      </aspNetCore>
    </system.webServer>
  </location>
</configuration>
'@
[System.IO.File]::WriteAllText("C:\inetpub\wwwroot\Nexora.Api\web.config", $webconfig)
Write-Host "      OK" -ForegroundColor Green

# STEP 4: Write correct appsettings.json
Write-Host "[4/6] Writing appsettings.json..."
$appsettings = @'
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "Hangfire": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "DefaultConnection": "Server=.\SQLEXPRESS;Database=NexoraDb;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=true;"
  },
  "Jwt": {
    "Issuer": "Nexora",
    "Audience": "NexoraClients",
    "AccessTokenExpiryMinutes": 15,
    "RefreshTokenExpiryDays": 7,
    "SecretKey": "gqS9sABARfK9SRwfMyFjEdyu9rhwRt/a8zaOOgk4dvE="
  },
  "Cors": {
    "AllowedOrigins": [
      "http://localhost:5173",
      "http://localhost:3000",
      "http://localhost:6060",
      "http://localhost:7070"
    ]
  },
  "Features": {
    "Chat": true,
    "KnowledgeVault": true,
    "News": true,
    "AI": true,
    "Music": true,
    "CommunicationCoach": true,
    "Countdown": true,
    "MenstrualCalendar": true
  },
  "Hangfire": {
    "DashboardPath": "/admin/hangfire"
  },
  "AI": {
    "Provider": "None"
  }
}
'@
[System.IO.File]::WriteAllText("C:\inetpub\wwwroot\Nexora.Api\appsettings.json", $appsettings)
Write-Host "      OK" -ForegroundColor Green

# STEP 5: Grant SQL Server access to LocalSystem (it already has it, but just in case)
Write-Host "[5/6] Verifying SQL Server is running..."
$sql = Get-Service | Where-Object { $_.Name -eq 'MSSQL$SQLEXPRESS' }
if ($sql.Status -ne 'Running') {
    Write-Host "      Starting SQL Server..." -ForegroundColor Yellow
    Start-Service 'MSSQL$SQLEXPRESS'
    Start-Sleep 5
}
Write-Host "      SQL Server: $($sql.Status)" -ForegroundColor Green

# STEP 6: Reset IIS
Write-Host "[6/6] Restarting IIS..."
iisreset /restart
Write-Host "      OK" -ForegroundColor Green

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Fix complete! Test: http://localhost:7070/health" -ForegroundColor White
Write-Host "============================================" -ForegroundColor Cyan

# Show stdout log after 5 seconds
Start-Sleep -Seconds 5
Write-Host ""
Write-Host "Checking startup log..." -ForegroundColor Yellow
$logFiles = Get-ChildItem "C:\inetpub\wwwroot\Nexora.Api\logs" -ErrorAction SilentlyContinue
if ($logFiles) {
    Get-Content ($logFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName -Tail 30
} else {
    Write-Host "No log file yet (app may not have started)" -ForegroundColor Red
    Write-Host "Check Event Viewer > Windows Logs > Application for errors" -ForegroundColor Yellow
}
