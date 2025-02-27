# setup_project_en.ps1
# PowerShell script to setup FX automated trading EA project

Write-Host "Starting setup for FX automated trading EA project..." -ForegroundColor Cyan

# Create project directories
$directories = @(
    "FX_EA_Project",
    "FX_EA_Project\MQL4",
    "FX_EA_Project\MQL4\Experts",
    "FX_EA_Project\MQL4\Include",
    "FX_EA_Project\MQL4\Libraries",
    "FX_EA_Project\MQL4\Scripts"
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        Write-Host "Creating directory: $dir" -ForegroundColor Yellow
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    } else {
        Write-Host "Directory already exists: $dir" -ForegroundColor Yellow
    }
}

# Copy files
$filesToCopy = @{
    "SimpleMAcrossEA.mq4" = "FX_EA_Project\MQL4\Experts\SimpleMAcrossEA.mq4"
    "RSI_BB_EA.mq4" = "FX_EA_Project\MQL4\Experts\RSI_BB_EA.mq4"
    "MartingaleEA.mq4" = "FX_EA_Project\MQL4\Experts\MartingaleEA.mq4"
    "README.md" = "FX_EA_Project\README.md"
}

foreach ($file in $filesToCopy.Keys) {
    if (Test-Path $file) {
        Write-Host "Copying file: $file -> $($filesToCopy[$file])" -ForegroundColor Yellow
        Copy-Item -Path $file -Destination $filesToCopy[$file] -Force
    } else {
        Write-Host "File not found: $file" -ForegroundColor Red
    }
}

Write-Host "Project directory structure created." -ForegroundColor Green

# MT4 data directory information
Write-Host ""
Write-Host "Please check your MT4 data directory." -ForegroundColor Cyan
Write-Host "It is usually located at:" -ForegroundColor Cyan
Write-Host "$env:APPDATA\MetaQuotes\Terminal\[random string]\MQL4\Experts" -ForegroundColor Cyan
Write-Host ""
Write-Host "Setup completed." -ForegroundColor Green
Write-Host "Copy files from FX_EA_Project folder to your MT4 data directory," -ForegroundColor Green
Write-Host "or open files in MetaEditor and compile them." -ForegroundColor Green

# Pause
$null = Read-Host "Press any key to exit"
