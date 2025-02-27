@echo off
rem ===== EURUSD_Trend_EA ワンクリックセットアップ =====
rem FX自動売買EAをコンパイルしてMT4にインストールするバッチファイル

echo EURUSD_Trend_EA ワンクリックセットアップ
echo ======================================
echo.
echo このバッチファイルは以下の処理を行います:
echo 1. EAのコンパイル
echo 2. MT4へのインストール
echo.
echo 処理を開始するには何かキーを押してください...
pause > nul

echo.
echo ステップ1: EAのコンパイル
echo ======================================
call "%~dp0compile_ea.bat"

echo.
echo ステップ2: MT4へのインストール
echo ======================================
call "%~dp0install_to_mt4.bat"

echo.
echo セットアップが完了しました。
echo MT4を起動して、ナビゲーターウィンドウのExpert Advisorsセクションを確認してください。
echo.
pause
