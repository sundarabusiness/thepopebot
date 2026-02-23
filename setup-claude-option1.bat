@echo off
REM Option 1: Use VPS Ollama via LiteLLM (EASIEST)
REM This sets environment variable and launches Claude Code

setlocal enabledelayedexpansion

echo.
echo ========================================
echo CLAUDE CODE - OPTION 1: VPS Ollama Setup
echo ========================================
echo.

REM Set environment variable for current session
set "ANTHROPIC_BASE_URL=http://100.111.3.59:3456"

echo [✓] ANTHROPIC_BASE_URL set to: http://100.111.3.59:3456
echo.
echo [*] Testing connection to VPS LiteLLM proxy...
echo.

REM Test connection
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://100.111.3.59:3456/models' -TimeoutSec 5 -ErrorAction Stop; Write-Host '[✓] LiteLLM proxy is reachable!' -ForegroundColor Green } catch { Write-Host '[✗] Cannot reach LiteLLM. Ensure Tailscale is running and VPS is accessible.' -ForegroundColor Red; exit 1 }"

if errorlevel 1 (
    echo.
    echo [!] Connection test failed!
    echo.
    echo Troubleshooting:
    echo 1. Is Tailscale running? Check system tray.
    echo 2. Can you reach VPS? Try: ping 100.111.3.59
    echo 3. Is VPS LiteLLM service running? ssh root@100.111.3.59 systemctl status goat-autopilot
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo [✓] Setup Complete!
echo ========================================
echo.
echo Launching Claude Code...
echo.

REM Launch Claude Code
claude

REM If claude not found globally, try npm
if errorlevel 1 (
    echo.
    echo Claude command not found. Trying npm exec...
    npm exec claude
)

endlocal
