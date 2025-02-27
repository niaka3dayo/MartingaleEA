# compile_ea.ps1
# FX自動売買EAをコンパイルするPowerShellスクリプト

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootPath = Split-Path -Parent $scriptPath

# MetaEditorの一般的なパスのリスト
$metaEditorPaths = @(
    "C:\Program Files\MetaTrader 4\metaeditor.exe",
    "C:\Program Files (x86)\MetaTrader 4\metaeditor.exe",
    "C:\Program Files\MetaTrader 4 Terminal\metaeditor.exe",
    "C:\Program Files (x86)\MetaTrader 4 Terminal\metaeditor.exe"
)

# MetaEditorのパスを自動検出
$metaEditorPath = $null
foreach ($path in $metaEditorPaths) {
    if (Test-Path $path) {
        $metaEditorPath = $path
        Write-Host "MetaEditorが見つかりました: $metaEditorPath" -ForegroundColor Green
        break
    }
}

# MetaEditorのパスを確認
if (-not $metaEditorPath) {
    Write-Host "MetaEditorが見つかりません。以下のパスを確認しました:" -ForegroundColor Red
    foreach ($path in $metaEditorPaths) {
        Write-Host "- $path" -ForegroundColor Red
    }

    # ユーザーに正しいパスの入力を求める
    Write-Host "MetaEditorの正確なパスを入力してください:" -ForegroundColor Yellow
    $userPath = Read-Host

    if (Test-Path $userPath) {
        $metaEditorPath = $userPath
        Write-Host "MetaEditorが見つかりました: $metaEditorPath" -ForegroundColor Green
    } else {
        Write-Host "指定されたパスにMetaEditorが見つかりません: $userPath" -ForegroundColor Red
        Write-Host "このスクリプトを編集して、正しいパスを設定してください。" -ForegroundColor Red
        Read-Host "何かキーを押して終了してください..."
        exit 1
    }
}

# srcディレクトリのEAファイルを確認
$srcPath = Join-Path $rootPath "src"
$eaFiles = Get-ChildItem -Path $srcPath -Filter "*.mq4" | Select-Object -ExpandProperty FullName

# プロジェクトディレクトリのEAファイルも確認
$projectEAFiles = @(
    "FX_EA_Project\MQL4\Experts\SimpleMAcrossEA.mq4",
    "FX_EA_Project\MQL4\Experts\RSI_BB_EA.mq4",
    "FX_EA_Project\MQL4\Experts\MartingaleEA.mq4"
)

foreach ($eaFile in $projectEAFiles) {
    $fullPath = Join-Path $rootPath $eaFile
    if (Test-Path $fullPath) {
        $eaFiles += $fullPath
    }
}

# EAファイルをコンパイル
Write-Host "FX自動売買EAをコンパイルします..." -ForegroundColor Cyan

$success = $true
foreach ($eaFile in $eaFiles) {
    if (Test-Path $eaFile) {
        $fileName = Split-Path -Leaf $eaFile
        Write-Host "コンパイル中: $fileName" -ForegroundColor Yellow
        & $metaEditorPath /compile:"$eaFile" /log
        if ($LASTEXITCODE -ne 0) {
            Write-Host "コンパイルに失敗しました: $fileName" -ForegroundColor Red
            $success = $false
        } else {
            Write-Host "コンパイル成功: $fileName" -ForegroundColor Green
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
