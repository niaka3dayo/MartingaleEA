# install_to_mt4.ps1
# FX自動売買EAをMT4にインストールするPowerShellスクリプト

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# MT4のデータディレクトリを取得
$appDataPath = [Environment]::GetFolderPath("ApplicationData")
$mt4BasePath = Join-Path $appDataPath "MetaQuotes\Terminal"

# MT4のターミナルディレクトリを検索
$terminalDirs = Get-ChildItem -Path $mt4BasePath -Directory | Where-Object { $_.Name -match "^[0-9A-F]{32}$" }

if ($terminalDirs.Count -eq 0) {
    Write-Host "MT4のデータディレクトリが見つかりませんでした。" -ForegroundColor Red
    Write-Host "MT4がインストールされていることを確認してください。" -ForegroundColor Red
    Read-Host "何かキーを押して終了してください..."
    exit 1
}

# 複数のターミナルディレクトリがある場合は選択させる
$selectedDir = $null
if ($terminalDirs.Count -eq 1) {
    $selectedDir = $terminalDirs[0].FullName
    Write-Host "MT4のデータディレクトリを自動検出しました: $selectedDir" -ForegroundColor Green
} else {
    Write-Host "複数のMT4データディレクトリが見つかりました。使用するディレクトリを選択してください:" -ForegroundColor Yellow
    for ($i = 0; $i -lt $terminalDirs.Count; $i++) {
        Write-Host "[$i] $($terminalDirs[$i].FullName)"
    }

    $selection = Read-Host "番号を入力してください"
    if ($selection -ge 0 -and $selection -lt $terminalDirs.Count) {
        $selectedDir = $terminalDirs[$selection].FullName
        Write-Host "選択されたディレクトリ: $selectedDir" -ForegroundColor Green
    } else {
        Write-Host "無効な選択です。" -ForegroundColor Red
        Read-Host "何かキーを押して終了してください..."
        exit 1
    }
}

# MT4のExpertsディレクトリを確認
$mt4ExpertsDir = Join-Path $selectedDir "MQL4\Experts"
if (-not (Test-Path $mt4ExpertsDir)) {
    Write-Host "MT4のExpertsディレクトリが見つかりません: $mt4ExpertsDir" -ForegroundColor Red
    Write-Host "MT4のインストールを確認してください。" -ForegroundColor Red
    Read-Host "何かキーを押して終了してください..."
    exit 1
}

# コンパイル済みのEAファイルをコピー
Write-Host "FX自動売買EAをMT4にインストールします..." -ForegroundColor Cyan

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
        Write-Host "コピー中: $eaFile" -ForegroundColor Yellow
        Copy-Item -Path $sourcePath -Destination $destPath -Force
        if (Test-Path $destPath) {
            Write-Host "コピー成功: $eaFile" -ForegroundColor Green
        } else {
            Write-Host "コピーに失敗しました: $eaFile" -ForegroundColor Red
            $success = $false
        }
    } else {
        Write-Host "ファイルが見つかりません: $sourcePath" -ForegroundColor Red
        Write-Host "先にEAをコンパイルしてください（compile_ea.ps1を実行）。" -ForegroundColor Yellow
        $success = $false
    }
}

# 実行結果を確認
if ($success) {
    Write-Host "すべてのEAのインストールが完了しました。" -ForegroundColor Green
    Write-Host "MT4を再起動して、ナビゲーターウィンドウのExpert Advisorsセクションを確認してください。" -ForegroundColor Green
} else {
    Write-Host "一部のEAのインストールに失敗しました。" -ForegroundColor Red
}

# 一時停止
Read-Host "何かキーを押して終了してください..."
