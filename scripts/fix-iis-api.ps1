# Run this script as Administrator
# Right-click PowerShell -> Run as administrator, then: .\fix-iis-api.ps1

Write-Host "=== Nexora API IIS Fix Script ===" -ForegroundColor Cyan

# 1. Import IIS module
Import-Module WebAdministration

# 2. Change AppPool identity to LocalSystem (avoids all permission issues)
Write-Host "Setting NexoraApiPool identity to LocalSystem..." -ForegroundColor Yellow
Set-ItemProperty "IIS:\AppPools\NexoraApiPool" -Name processModel.identityType -Value 0
Write-Host "  Done." -ForegroundColor Green

# 3. Create logs folder
Write-Host "Creating logs folder..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "C:\inetpub\wwwroot\Nexora.Api\logs" -Force | Out-Null
Write-Host "  Done." -ForegroundColor Green

# 4. Verify appsettings.json has correct connection string
$settings = Get-Content "C:\inetpub\wwwroot\Nexora.Api\appsettings.json" -Raw
if ($settings -match "localdb") {
    Write-Host "FIXING appsettings.json - replacing LocalDB with SQLEXPRESS..." -ForegroundColor Yellow
    $fixed = $settings -replace '"DefaultConnection":\s*"[^"]*"', '"DefaultConnection": "Server=.\\SQLEXPRESS;Database=NexoraDb;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=true;"'
    [System.IO.File]::WriteAllText("C:\inetpub\wwwroot\Nexora.Api\appsettings.json", $fixed)
    Write-Host "  Done." -ForegroundColor Green
} else {
    Write-Host "  appsettings.json already has SQLEXPRESS." -ForegroundColor Green
}

# 5. Verify web.config is correct
$webconfig = Get-Content "C:\inetpub\wwwroot\Nexora.Api\web.config" -Raw
if ($webconfig -notmatch "AspNetCoreModuleV2") {
    Write-Host "FIXING web.config..." -ForegroundColor Yellow
    $correctWebConfig = @'
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <location path="." inheritInChildApplications="false">
    <system.webServer>
      <handlers>
        <add name="aspNetCore" path="*" verb="*" modules="AspNetCoreModuleV2" resourceType="Unspecified" />
      </handlers>
      <aspNetCore processPath="dotnet"
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
    [System.IO.File]::WriteAllText("C:\inetpub\wwwroot\Nexora.Api\web.config", $correctWebConfig)
    Write-Host "  Done." -ForegroundColor Green
} else {
    Write-Host "  web.config already correct." -ForegroundColor Green
}

# 6. Reset IIS
Write-Host "Restarting IIS..." -ForegroundColor Yellow
iisreset /restart
Write-Host "  Done." -ForegroundColor Green

Write-Host ""
Write-Host "=== Fix Complete! ===" -ForegroundColor Cyan
Write-Host "Now open: http://localhost:7070/health" -ForegroundColor White
Write-Host "Expected response: Healthy" -ForegroundColor Green
