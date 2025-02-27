@echo off
setlocal enabledelayedexpansion
rem ===== EURUSD_Trend_EA インストールバッチファイル =====
rem FX自動売買EAをMT4にインストールするバッチファイル

echo EURUSD_Trend_EA インストールツール
echo ======================================

rem MT4のデータディレクトリを検索
set APPDATA_PATH=%APPDATA%
set MT4_BASE_PATH=%APPDATA_PATH%\MetaQuotes\Terminal

if not exist "%MT4_BASE_PATH%" (
    echo MT4のデータディレクトリが見つかりませんでした: %MT4_BASE_PATH%
    echo MT4がインストールされていることを確認してください。
    pause
    exit /b 1
)

echo MT4ベースディレクトリを検出: %MT4_BASE_PATH%
echo.

rem MT4のターミナルディレクトリを検索
set TERMINAL_COUNT=0
set TERMINAL_LIST=

for /d %%d in ("%MT4_BASE_PATH%\*") do (
    set FOLDER_NAME=%%~nxd
    if "!FOLDER_NAME:~0,1!" NEQ "_" (
        if exist "%%d\MQL4\Experts" (
            set /a TERMINAL_COUNT+=1
            set TERMINAL_LIST=!TERMINAL_LIST!%%d;
            echo [!TERMINAL_COUNT!] %%d
        )
    )
)

if %TERMINAL_COUNT% EQU 0 (
    echo MT4のデータディレクトリが見つかりませんでした。
    echo MT4がインストールされていることを確認してください。
    pause
    exit /b 1
)

rem ターミナルディレクトリの選択
set SELECTED_DIR=
if %TERMINAL_COUNT% EQU 1 (
    for /f "tokens=1 delims=;" %%a in ("%TERMINAL_LIST%") do set SELECTED_DIR=%%a
    echo MT4のデータディレクトリを自動検出しました: %SELECTED_DIR%
) else (
    echo.
    echo 複数のMT4データディレクトリが見つかりました。使用するディレクトリを選択してください:
    set /p SELECTION=番号を入力してください:

    set INDEX=0
    for /f "tokens=1 delims=;" %%a in ("%TERMINAL_LIST%") do (
        set /a INDEX+=1
        if !INDEX! EQU %SELECTION% (
            set SELECTED_DIR=%%a
        )
    )

    if "%SELECTED_DIR%"=="" (
        echo 無効な選択です。
        pause
        exit /b 1
    )

    echo 選択されたディレクトリ: %SELECTED_DIR%
)

rem MT4のExpertsディレクトリを確認
set MT4_EXPERTS_DIR=%SELECTED_DIR%\MQL4\Experts
if not exist "%MT4_EXPERTS_DIR%" (
    echo MT4のExpertsディレクトリが見つかりません: %MT4_EXPERTS_DIR%
    echo MT4のインストールを確認してください。
    pause
    exit /b 1
)

echo.
echo FX自動売買EAをMT4にインストールします...
echo.

rem コンパイル済みのEAファイルをコピー
set SRC_DIR=%~dp0src
set SUCCESS=1

rem EX4ファイルを検索してコピー
for %%f in ("%SRC_DIR%\*.ex4") do (
    echo コピー中: %%~nxf
    copy "%%f" "%MT4_EXPERTS_DIR%\%%~nxf" /Y
    if errorlevel 1 (
        echo コピーに失敗しました: %%~nxf
        set SUCCESS=0
    ) else (
        echo コピー成功: %%~nxf
    )
)

rem 実行結果を確認
if %SUCCESS% EQU 1 (
    echo すべてのEAのインストールが完了しました。
    echo MT4を再起動して、ナビゲーターウィンドウのExpert Advisorsセクションを確認してください。
) else (
    echo 一部のEAのインストールに失敗しました。
    echo 先にEAをコンパイルしてください（compile_ea.batを実行）。
)

echo.
pause
