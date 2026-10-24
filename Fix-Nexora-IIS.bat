@echo off
title Nexora - Full Deploy & Rebuild
setlocal

:: ============================================================
:: Auto-elevate if not running as Administrator
:: ============================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Requesting Administrator permissions...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo.
echo ====================================================
echo     NEXORA FULL DEPLOY TO IIS
echo ====================================================

:: ---- STEP 1: Stop the App Pool to release DLL locks ----
echo [1/6] Stopping NexoraApiPool...
%SystemRoot%\System32\inetsrv\appcmd stop apppool /apppool.name:"NexoraApiPool" >nul 2>&1
timeout /t 2 /nobreak >nul

:: ---- STEP 2: Copy all published files to IIS folder ----
echo [2/6] Copying published API files to IIS...
robocopy "A:\Projects\Nexora\publish\api" "C:\inetpub\wwwroot\Nexora.Api" /E /IS /IT /XD logs
if %errorlevel% geq 8 (
    echo [ERROR] robocopy failed with error code %errorlevel%
    goto :error
)
echo [OK] Files copied!

:: ---- STEP 3: Ensure logs folder exists with permissions ----
echo [3/6] Creating logs folder...
if not exist "C:\inetpub\wwwroot\Nexora.Api\logs" mkdir "C:\inetpub\wwwroot\Nexora.Api\logs"
icacls "C:\inetpub\wwwroot\Nexora.Api\logs" /grant "IIS_IUSRS:(OI)(CI)F" /T >nul 2>&1
icacls "C:\inetpub\wwwroot\Nexora.Api\logs" /grant "Everyone:(OI)(CI)F" /T >nul 2>&1

:: ---- STEP 4: Set AppPool identity to LocalSystem ----
echo [4/6] Setting AppPool identity to LocalSystem...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Import-Module WebAdministration; Set-ItemProperty 'IIS:\AppPools\NexoraApiPool' -Name processModel.identityType -Value 0"

:: ---- STEP 5: Also deploy Admin settings ----
echo [5/6] Updating Admin portal configuration...
copy /Y "A:\Projects\Nexora\publish\admin\appsettings.json" "C:\inetpub\wwwroot\Nexora.Admin\appsettings.json" >nul 2>&1
echo [OK] Admin config updated!

:: ---- STEP 6: Restart IIS ----
echo [6/6] Restarting IIS...
iisreset /restart

echo.
echo ====================================================
echo Waiting 5 seconds for IIS to come back up...
timeout /t 5 /nobreak >nul

:: ---- Verify health endpoint ----
echo Testing http://localhost:7070/health ...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "try { $res = Invoke-RestMethod -Uri 'http://localhost:7070/health' -TimeoutSec 15; Write-Host '  STATUS:' $res -ForegroundColor Green } catch { Write-Host '  ERROR:' $_.Exception.Message -ForegroundColor Red }"

echo.
echo ====================================================
echo Swagger UI: http://localhost:7070/swagger
echo Admin Portal: http://localhost:6060
echo ====================================================
echo.
goto :end

:error
echo [FAILED] Deploy encountered an error. Check output above.

:end
echo Press any key to close...
pause >nul
