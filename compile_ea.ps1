# compile_ea.ps1
# FX自動売買EAをコンパイルするPowerShellスクリプト

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$metaEditorPath = "C:\Program Files\MetaTrader 4\metaeditor.exe"

# MetaEditorのパスを確認
if (-not (Test-Path $metaEditorPath)) {
    Write-Host "MetaEditorが見つかりません: $metaEditorPath" -ForegroundColor Red
    Write-Host "MetaEditorのパスを確認してください。" -ForegroundColor Red
    Write-Host "このスクリプトを編集して、正しいパスを設定してください。" -ForegroundColor Red
    Read-Host "何かキーを押して終了してください..."
    exit 1
}

# プロジェクトディレクトリのEAファイルを確認
$eaFiles = @(
    "FX_EA_Project\MQL4\Experts\SimpleMAcrossEA.mq4",
    "FX_EA_Project\MQL4\Experts\RSI_BB_EA.mq4",
    "FX_EA_Project\MQL4\Experts\MartingaleEA.mq4"
)

# EAファイルをコンパイル
Write-Host "FX自動売買EAをコンパイルします..." -ForegroundColor Cyan

$success = $true
foreach ($eaFile in $eaFiles) {
    $fullPath = Join-Path $scriptPath $eaFile
    if (Test-Path $fullPath) {
        Write-Host "コンパイル中: $eaFile" -ForegroundColor Yellow
        & $metaEditorPath /compile:"$fullPath" /log
        if ($LASTEXITCODE -ne 0) {
            Write-Host "コンパイルに失敗しました: $eaFile" -ForegroundColor Red
            $success = $false
        } else {
            Write-Host "コンパイル成功: $eaFile" -ForegroundColor Green
        }
    } else {
        Write-Host "ファイルが見つかりません: $eaFile" -ForegroundColor Red
        $success = $false
    }
}

# 実行結果を確認
if ($success) {
    Write-Host "すべてのEAのコンパイルが完了しました。" -ForegroundColor Green
} else {
    Write-Host "一部のEAのコンパイルに失敗しました。" -ForegroundColor Red
}

# 一時停止
Read-Host "何かキーを押して終了してください..."
