# init_project_en.ps1
# PowerShell script to initialize FX automated trading EA project

# Get script directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$setupScript = Join-Path $scriptPath "setup_project_en.ps1"

# Display initialization message
Write-Host "Initializing FX automated trading EA project..." -ForegroundColor Cyan

# Run setup_project_en.ps1
if (Test-Path $setupScript) {
    & $setupScript
} else {
    Write-Host "Setup script ($setupScript) not found." -ForegroundColor Red
}

# Next steps guidance
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Compile EA: compile_ea_en.ps1" -ForegroundColor Yellow
Write-Host "2. Install EA to MT4: install_to_mt4_en.ps1" -ForegroundColor Yellow
Write-Host ""

# Pause
$null = Read-Host "Press any key to exit"
