@echo off
REM Option 3: Local LiteLLM Proxy Setup
REM Requires: Local Ollama already running

setlocal enabledelayedexpansion

echo.
echo ========================================
echo CLAUDE CODE - OPTION 3: Local LiteLLM
echo ========================================
echo.

echo [Check] Is Ollama running?
tasklist | findstr /I ollama >nul 2>&1
if errorlevel 1 (
    echo [!] Ollama is not running!
    echo.
    echo Option 3 requires Option 2 (Local Ollama) to be set up first.
    echo Please run: setup-claude-option2-local-ollama.bat
    echo.
    pause
    exit /b 1
)

echo [✓] Ollama is running!
echo.

echo [Step 1] Check if LiteLLM is installed...
pip show litellm >nul 2>&1
if errorlevel 1 (
    echo [*] LiteLLM not found. Installing via pip...
    pip install litellm
    if errorlevel 1 (
        echo [!] Failed to install LiteLLM!
        echo [*] Make sure pip and Python are installed: https://www.python.org/downloads/
        pause
        exit /b 1
    )
    echo [✓] LiteLLM installed!
) else (
    echo [✓] LiteLLM already installed!
)

echo.
echo [Step 2] Create LiteLLM config directory...
if not exist "%USERPROFILE%\.litellm\" (
    mkdir "%USERPROFILE%\.litellm\"
    echo [✓] Directory created: %USERPROFILE%\.litellm\
) else (
    echo [✓] Directory already exists
)

echo.
echo [Step 3] Create LiteLLM config file...

REM Create config.yaml
(
    echo model_list:
    echo   - model_name: claude-opus-4-6
    echo     litellm_params:
    echo       model: ollama/qwen2.5-coder
    echo       api_base: http://localhost:11434
    echo.
    echo   - model_name: claude-sonnet-4-6
    echo     litellm_params:
    echo       model: ollama/qwen2.5-coder
    echo       api_base: http://localhost:11434
    echo.
    echo   - model_name: claude-haiku-4-5-20251001
    echo     litellm_params:
    echo       model: ollama/qwen2.5-coder
    echo       api_base: http://localhost:11434
) > "%USERPROFILE%\.litellm\config.yaml"

echo [✓] Config created: %USERPROFILE%\.litellm\config.yaml
echo.

echo [Step 4] Set environment variable...
set "ANTHROPIC_BASE_URL=http://localhost:3456"
echo [✓] ANTHROPIC_BASE_URL set to: http://localhost:3456
echo.

echo.
echo ========================================
echo [✓] Setup Complete!
echo ========================================
echo.
echo Next steps:
echo   1. IMPORTANT: Open a NEW PowerShell terminal
echo   2. Run: litellm --config %USERPROFILE%\.litellm\config.yaml --port 3456
echo   3. You should see: ✓ LiteLLM proxy server is running
echo   4. THEN open another terminal and run: claude
echo.
echo NOTE: You need 3 terminals running:
echo   Terminal 1: ollama serve (or Ollama system tray)
echo   Terminal 2: litellm --config... (proxy)
echo   Terminal 3: claude (your code assistant)
echo.

pause

echo.
echo Launching LiteLLM proxy...
echo.

REM Start LiteLLM in new window
start "LiteLLM Proxy" cmd /k "litellm --config %USERPROFILE%\.litellm\config.yaml --port 3456"

timeout /t 3 /nobreak

echo.
echo [*] LiteLLM should be running in the new window.
echo [*] Opening new terminal for Claude Code...
echo.

set "ANTHROPIC_BASE_URL=http://localhost:3456"

REM Launch Claude in new terminal
start "Claude Code" cmd /k "claude"

endlocal
