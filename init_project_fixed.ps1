# init_project_fixed.ps1
# FX自動売買EAプロジェクトを初期化するPowerShellスクリプト

# スクリプトのディレクトリを取得
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$setupScript = Join-Path $scriptPath "setup_project.ps1"

# プロジェクトの初期化メッセージを表示
Write-Host "FX自動売買EAプロジェクトを初期化します..." -ForegroundColor Cyan

# setup_project.ps1を実行
if (Test-Path $setupScript) {
    & $setupScript
} else {
    Write-Host "セットアップスクリプト ($setupScript) が見つかりません。" -ForegroundColor Red
}

# 次のステップの案内
Write-Host ""
Write-Host "次のステップ:" -ForegroundColor Yellow
Write-Host "1. EAをコンパイルする: compile_ea.ps1" -ForegroundColor Yellow
Write-Host "2. EAをMT4にインストールする: install_to_mt4.ps1" -ForegroundColor Yellow
Write-Host ""

# 一時停止
$null = Read-Host "終了するには何かキーを押してください"
