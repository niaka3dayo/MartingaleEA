# compile_ea_en.ps1
# PowerShell script to compile FX automated trading EA

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$metaEditorPath = "C:\Program Files (x86)\MetaTrader 4\metaeditor.exe"

# Check MetaEditor path
if (-not (Test-Path $metaEditorPath)) {
    Write-Host "MetaEditor not found: $metaEditorPath" -ForegroundColor Red
    Write-Host "Please check the MetaEditor path." -ForegroundColor Red
    Write-Host "Edit this script to set the correct path." -ForegroundColor Red
    $null = Read-Host "Press any key to exit"
    exit 1
}

# Check EA files in project directory
$eaFiles = @(
    "FX_EA_Project\MQL4\Experts\SimpleMAcrossEA.mq4",
    "FX_EA_Project\MQL4\Experts\RSI_BB_EA.mq4",
    "FX_EA_Project\MQL4\Experts\MartingaleEA.mq4"
)

# Compile EA files
Write-Host "Compiling FX automated trading EA..." -ForegroundColor Cyan

$success = $true
foreach ($eaFile in $eaFiles) {
    $fullPath = Join-Path $scriptPath $eaFile
    if (Test-Path $fullPath) {
        Write-Host "Compiling: $eaFile" -ForegroundColor Yellow
        & $metaEditorPath /compile:"$fullPath" /log
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Compilation failed: $eaFile" -ForegroundColor Red
            $success = $false
        } else {
            Write-Host "Compilation successful: $eaFile" -ForegroundColor Green
        }
    } else {
        Write-Host "File not found: $eaFile" -ForegroundColor Red
        $success = $false
    }
}

# Check execution result
if ($success) {
    Write-Host "All EA compilations completed successfully." -ForegroundColor Green
} else {
    Write-Host "Some EA compilations failed." -ForegroundColor Red
}

# Pause
$null = Read-Host "Press any key to exit"
