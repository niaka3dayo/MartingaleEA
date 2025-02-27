@echo off
echo FX自動売買EAのコンパイルを開始します...

REM MetaEditorのパスを設定（インストール場所に合わせて変更してください）
set METAEDITOR_PATH="C:\Program Files\MetaTrader 4\metaeditor.exe"

REM MetaEditorが存在するか確認
if not exist %METAEDITOR_PATH% (
    echo MetaEditorが見つかりません。
    echo MT4のインストールディレクトリを確認し、このスクリプトのMETAEDITOR_PATHを修正してください。
    pause
    exit /b 1
)

REM EAファイルをコンパイル
echo SimpleMAcrossEA.mq4をコンパイルしています...
%METAEDITOR_PATH% /compile:"FX_EA_Project\MQL4\Experts\SimpleMAcrossEA.mq4" /log

echo RSI_BB_EA.mq4をコンパイルしています...
%METAEDITOR_PATH% /compile:"FX_EA_Project\MQL4\Experts\RSI_BB_EA.mq4" /log

echo MartingaleEA.mq4をコンパイルしています...
%METAEDITOR_PATH% /compile:"FX_EA_Project\MQL4\Experts\MartingaleEA.mq4" /log

echo.
echo コンパイルが完了しました。
echo コンパイルログを確認して、エラーがないことを確認してください。
echo 生成された.ex4ファイルはMT4のExpertsフォルダーにコピーされています。
pause
