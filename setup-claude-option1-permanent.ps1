# Option 1: Permanent Setup (Set Environment Variable System-Wide)
# Run as Administrator

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "CLAUDE CODE - OPTION 1: Permanent Setup" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsIdentity]::GetCurrent().Groups -contains 'S-1-5-32-544')
if (-not $isAdmin) {
    Write-Host "[!] This script must run as Administrator!" -ForegroundColor Red
    Write-Host "[*] Right-click PowerShell, select 'Run as administrator'" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "[*] Setting ANTHROPIC_BASE_URL system-wide..." -ForegroundColor Yellow
Write-Host ""

# Set system environment variable
[System.Environment]::SetEnvironmentVariable(
    "ANTHROPIC_BASE_URL",
    "http://100.111.3.59:3456",
    "User"
)

Write-Host "[✓] Environment variable set!" -ForegroundColor Green
Write-Host ""
Write-Host "Variable: ANTHROPIC_BASE_URL" -ForegroundColor Cyan
Write-Host "Value:    http://100.111.3.59:3456" -ForegroundColor Cyan
Write-Host ""

Write-Host "[*] Testing connection to VPS LiteLLM..." -ForegroundColor Yellow
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri "http://100.111.3.59:3456/models" -TimeoutSec 5 -ErrorAction Stop
    Write-Host "[✓] LiteLLM proxy is reachable!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Available models:" -ForegroundColor Cyan
    Write-Host "  - claude-opus-4-6" -ForegroundColor Green
    Write-Host "  - claude-sonnet-4-6" -ForegroundColor Green
    Write-Host "  - claude-haiku-4-5-20251001" -ForegroundColor Green
} catch {
    Write-Host "[!] Cannot reach LiteLLM!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "  1. Is Tailscale running? Check Windows system tray"
    Write-Host "  2. Can you reach VPS? Try: ping 100.111.3.59"
    Write-Host "  3. Is VPS service running? ssh root@100.111.3.59 systemctl status goat-autopilot"
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "[✓] Setup Complete!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. CLOSE and REOPEN PowerShell (to load new environment variable)"
Write-Host "  2. Run: claude"
Write-Host ""

Read-Host "Press Enter to continue"
