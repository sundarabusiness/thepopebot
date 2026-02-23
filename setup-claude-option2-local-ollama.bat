@echo off
REM Option 2: Local Ollama Setup
REM Installs Ollama, pulls Qwen model, sets up Claude Code

setlocal enabledelayedexpansion

echo.
echo ========================================
echo CLAUDE CODE - OPTION 2: Local Ollama
echo ========================================
echo.

echo [Step 1] Check if Ollama is installed...
where ollama >nul 2>&1
if errorlevel 1 (
    echo [!] Ollama not found. Installing...
    echo.
    echo [*] Downloading Ollama from https://ollama.com/download/windows
    echo [*] Starting installer...
    echo.

    REM Download and run Ollama installer
    powershell -Command "Invoke-WebRequest -Uri 'https://ollama.com/download/windows' -OutFile 'OllamaSetup.exe'; Start-Process 'OllamaSetup.exe'"

    echo [*] Installer launched. Please complete installation.
    echo [*] Ollama will run in your system tray.
    echo.
    pause
    echo [*] Continuing setup...
) else (
    echo [✓] Ollama found!
)

echo.
echo [Step 2] Check Ollama service...
tasklist | findstr /I ollama >nul 2>&1
if errorlevel 1 (
    echo [*] Ollama not running. Starting...
    start ollama serve
    timeout /t 3 /nobreak
) else (
    echo [✓] Ollama is running!
)

echo.
echo [Step 3] Pull Qwen2.5-Coder model (~4.7GB)...
echo [*] This may take a few minutes...
echo.

ollama pull qwen2.5-coder:7b

if errorlevel 1 (
    echo [!] Failed to pull model!
    pause
    exit /b 1
)

echo.
echo [✓] Model pulled successfully!
echo.

echo [Step 4] Verify model...
ollama list | findstr qwen2.5-coder
if errorlevel 1 (
    echo [!] Model verification failed!
    pause
    exit /b 1
)

echo [✓] Model verified!
echo.

echo [Step 5] Set environment variable...
set "ANTHROPIC_BASE_URL=http://localhost:11434/v1"
echo [✓] ANTHROPIC_BASE_URL set to: http://localhost:11434/v1
echo.

echo ========================================
echo [✓] Setup Complete!
echo ========================================
echo.
echo Launching Claude Code...
echo.

claude

if errorlevel 1 (
    echo Claude command not found. Trying npm exec...
    npm exec claude
)

endlocal
