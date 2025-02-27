@echo off
echo FX自動売買EAプロジェクトのセットアップを開始します...

REM プロジェクトディレクトリの作成
mkdir FX_EA_Project
mkdir FX_EA_Project\MQL4
mkdir FX_EA_Project\MQL4\Experts
mkdir FX_EA_Project\MQL4\Include
mkdir FX_EA_Project\MQL4\Libraries
mkdir FX_EA_Project\MQL4\Scripts

REM ファイルの移動
copy SimpleMAcrossEA.mq4 FX_EA_Project\MQL4\Experts\
copy RSI_BB_EA.mq4 FX_EA_Project\MQL4\Experts\
copy MartingaleEA.mq4 FX_EA_Project\MQL4\Experts\
copy README.md FX_EA_Project\

echo プロジェクトディレクトリの構造を作成しました。

REM MT4のデータディレクトリを確認
echo.
echo MT4のデータディレクトリを確認してください。
echo 通常は以下のパスにあります:
echo %APPDATA%\MetaQuotes\Terminal\[ランダムな文字列]\MQL4\Experts
echo.
echo セットアップが完了しました。
echo FX_EA_Projectフォルダー内のファイルをMT4のデータディレクトリにコピーするか、
echo MetaEditorでファイルを開いてコンパイルしてください。
pause
