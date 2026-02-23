@echo off
REM Claude Code Setup - Choose Your Option

setlocal enabledelayedexpansion

:menu
cls
echo.
echo ========================================
echo   CLAUDE CODE SETUP - Choose Option
echo ========================================
echo.
echo [1] Option 1: VPS Ollama (EASIEST, Recommended)
echo     - Setup time: 2 minutes
echo     - Speed: 5-10 seconds per response
echo     - Requires: Tailscale running
echo     - Offline: NO
echo.
echo [2] Option 2: Local Ollama (Good)
echo     - Setup time: 10 minutes
echo     - Speed: 1-5 seconds per response
echo     - Requires: 4GB+ RAM, 5GB disk
echo     - Offline: YES
echo.
echo [3] Option 3: Local LiteLLM (FAST, Full Setup)
echo     - Setup time: 15 minutes
echo     - Speed: <1 second per response
echo     - Requires: Option 2 + LiteLLM
echo     - Offline: YES
echo.
echo [Q] Quit
echo.
set /p choice="Enter choice (1, 2, 3, or Q): "

if /i "%choice%"=="1" goto option1
if /i "%choice%"=="2" goto option2
if /i "%choice%"=="3" goto option3
if /i "%choice%"=="Q" goto quit
if /i "%choice%"=="q" goto quit

echo Invalid choice. Try again.
timeout /t 2 /nobreak
goto menu

:option1
echo.
echo Launching Option 1 setup...
call setup-claude-option1.bat
goto end

:option2
echo.
echo Launching Option 2 setup...
call setup-claude-option2-local-ollama.bat
goto end

:option3
echo.
echo Launching Option 3 setup...
call setup-claude-option3-local-litellm.bat
goto end

:quit
echo Goodbye!
exit /b 0

:end
echo.
echo Setup completed. Goodbye!
timeout /t 3 /nobreak

endlocal
