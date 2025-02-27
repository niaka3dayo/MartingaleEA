# install_to_mt4_en.ps1
# PowerShell script to install FX automated trading EA to MT4

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# Get MT4 data directory
$appDataPath = [Environment]::GetFolderPath("ApplicationData")
$mt4BasePath = Join-Path $appDataPath "MetaQuotes\Terminal"

# Search for MT4 terminal directories
$terminalDirs = Get-ChildItem -Path $mt4BasePath -Directory | Where-Object { $_.Name -match "^[0-9A-F]{32}$" }

if ($terminalDirs.Count -eq 0) {
    Write-Host "MT4 data directory not found." -ForegroundColor Red
    Write-Host "Please make sure MT4 is installed." -ForegroundColor Red
    $null = Read-Host "Press any key to exit"
    exit 1
}

# If multiple terminal directories, let user select one
$selectedDir = $null
if ($terminalDirs.Count -eq 1) {
    $selectedDir = $terminalDirs[0].FullName
    Write-Host "MT4 data directory automatically detected: $selectedDir" -ForegroundColor Green
} else {
    Write-Host "Multiple MT4 data directories found. Please select the directory to use:" -ForegroundColor Yellow
    for ($i = 0; $i -lt $terminalDirs.Count; $i++) {
        Write-Host "[$i] $($terminalDirs[$i].FullName)"
    }

    $selection = Read-Host "Enter number"
    if ($selection -ge 0 -and $selection -lt $terminalDirs.Count) {
        $selectedDir = $terminalDirs[$selection].FullName
        Write-Host "Selected directory: $selectedDir" -ForegroundColor Green
    } else {
        Write-Host "Invalid selection." -ForegroundColor Red
        $null = Read-Host "Press any key to exit"
        exit 1
    }
}

# Check MT4 Experts directory
$mt4ExpertsDir = Join-Path $selectedDir "MQL4\Experts"
if (-not (Test-Path $mt4ExpertsDir)) {
    Write-Host "MT4 Experts directory not found: $mt4ExpertsDir" -ForegroundColor Red
    Write-Host "Please check your MT4 installation." -ForegroundColor Red
    $null = Read-Host "Press any key to exit"
    exit 1
}

# Copy compiled EA files
Write-Host "Installing FX automated trading EA to MT4..." -ForegroundColor Cyan

$eaFiles = @(
    "SimpleMAcrossEA.ex4",
    "RSI_BB_EA.ex4",
    "MartingaleEA.ex4"
)

$success = $true
foreach ($eaFile in $eaFiles) {
    $sourcePath = Join-Path $scriptPath "FX_EA_Project\MQL4\Experts\$eaFile"
    $destPath = Join-Path $mt4ExpertsDir $eaFile

    if (Test-Path $sourcePath) {
        Write-Host "Copying: $eaFile" -ForegroundColor Yellow
        Copy-Item -Path $sourcePath -Destination $destPath -Force
        if (Test-Path $destPath) {
            Write-Host "Copy successful: $eaFile" -ForegroundColor Green
        } else {
            Write-Host "Copy failed: $eaFile" -ForegroundColor Red
            $success = $false
        }
    } else {
        Write-Host "File not found: $sourcePath" -ForegroundColor Red
        Write-Host "Please compile the EA first (run compile_ea_en.ps1)." -ForegroundColor Yellow
        $success = $false
    }
}

# Check execution result
if ($success) {
    Write-Host "All EA installations completed successfully." -ForegroundColor Green
    Write-Host "Restart MT4 and check the Expert Advisors section in the Navigator window." -ForegroundColor Green
} else {
    Write-Host "Some EA installations failed." -ForegroundColor Red
}

# Pause
$null = Read-Host "Press any key to exit"
