# setup_project.ps1
# FX自動売買EAプロジェクトをセットアップするショートカットスクリプト

# scriptsディレクトリ内の実際のスクリプトを呼び出す
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$actualScript = Join-Path $scriptPath "scripts\setup_project.ps1"

if (Test-Path $actualScript) {
    & $actualScript
} else {
    Write-Host "エラー: スクリプトが見つかりません: $actualScript" -ForegroundColor Red
    Read-Host "何かキーを押して終了してください..."
}
