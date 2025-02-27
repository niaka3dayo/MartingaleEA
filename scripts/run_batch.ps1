# バッチファイルを実行するためのPowerShellスクリプト

param (
    [Parameter(Mandatory=$true)]
    [string]$BatchFile
)

# バッチファイルが存在するか確認
if (-not (Test-Path $BatchFile)) {
    Write-Error "指定されたバッチファイル '$BatchFile' が見つかりません。"
    exit 1
}

# バッチファイルを実行
Write-Host "バッチファイル '$BatchFile' を実行します..."
& cmd.exe /c $BatchFile

# 実行結果を確認
if ($LASTEXITCODE -eq 0) {
    Write-Host "バッチファイルの実行が完了しました。" -ForegroundColor Green
} else {
    Write-Host "バッチファイルの実行中にエラーが発生しました。終了コード: $LASTEXITCODE" -ForegroundColor Red
}

# 一時停止
Write-Host "続行するには何かキーを押してください..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
