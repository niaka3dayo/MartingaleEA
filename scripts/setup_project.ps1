# setup_project.ps1
# FX自動売買EAプロジェクトのセットアップスクリプト

Write-Host "FX自動売買EAプロジェクトのセットアップを開始します..." -ForegroundColor Cyan

# プロジェクトディレクトリの作成
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
        Write-Host "ディレクトリを作成します: $dir" -ForegroundColor Yellow
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    } else {
        Write-Host "ディレクトリは既に存在します: $dir" -ForegroundColor Yellow
    }
}

# ファイルのコピー
$filesToCopy = @{
    "SimpleMAcrossEA.mq4" = "FX_EA_Project\MQL4\Experts\SimpleMAcrossEA.mq4"
    "RSI_BB_EA.mq4" = "FX_EA_Project\MQL4\Experts\RSI_BB_EA.mq4"
    "MartingaleEA.mq4" = "FX_EA_Project\MQL4\Experts\MartingaleEA.mq4"
    "README.md" = "FX_EA_Project\README.md"
}

foreach ($file in $filesToCopy.Keys) {
    if (Test-Path $file) {
        Write-Host "ファイルをコピーします: $file -> $($filesToCopy[$file])" -ForegroundColor Yellow
        Copy-Item -Path $file -Destination $filesToCopy[$file] -Force
    } else {
        Write-Host "ファイルが見つかりません: $file" -ForegroundColor Red
    }
}

Write-Host "プロジェクトディレクトリの構造を作成しました。" -ForegroundColor Green

# MT4のデータディレクトリに関する情報
Write-Host ""
Write-Host "MT4のデータディレクトリを確認してください。" -ForegroundColor Cyan
Write-Host "通常は以下のパスにあります:" -ForegroundColor Cyan
Write-Host "$env:APPDATA\MetaQuotes\Terminal\[ランダムな文字列]\MQL4\Experts" -ForegroundColor Cyan
Write-Host ""
Write-Host "セットアップが完了しました。" -ForegroundColor Green
Write-Host "FX_EA_Projectフォルダー内のファイルをMT4のデータディレクトリにコピーするか、" -ForegroundColor Green
Write-Host "MetaEditorでファイルを開いてコンパイルしてください。" -ForegroundColor Green

# 一時停止
Read-Host "何かキーを押して終了してください..."
