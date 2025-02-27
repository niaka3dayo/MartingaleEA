@echo off
echo FX自動売買EAのインストールを開始します...

REM MT4のデータディレクトリを入力
set /p MT4_DATA_DIR="MT4のデータディレクトリを入力してください（例: %APPDATA%\MetaQuotes\Terminal\XXXXXXXXXXXXXXXX）: "

REM 入力されたディレクトリが存在するか確認
if not exist "%MT4_DATA_DIR%" (
    echo 指定されたディレクトリが存在しません。
    echo MT4の「ファイル」→「データフォルダーを開く」で正しいパスを確認してください。
    pause
    exit /b 1
)

REM MQL4\Expertsディレクトリが存在するか確認
if not exist "%MT4_DATA_DIR%\MQL4\Experts" (
    echo 指定されたディレクトリにMQL4\Expertsフォルダーが見つかりません。
    echo 正しいMT4のデータディレクトリを指定してください。
    pause
    exit /b 1
)

REM コンパイル済みのEAファイルをコピー
echo コンパイル済みのEAファイルをMT4のExpertsフォルダーにコピーしています...

copy "FX_EA_Project\MQL4\Experts\SimpleMAcrossEA.ex4" "%MT4_DATA_DIR%\MQL4\Experts\" /Y
if %ERRORLEVEL% NEQ 0 (
    echo SimpleMAcrossEA.ex4のコピーに失敗しました。
    echo ファイルが存在するか確認してください。
) else (
    echo SimpleMAcrossEA.ex4をコピーしました。
)

copy "FX_EA_Project\MQL4\Experts\RSI_BB_EA.ex4" "%MT4_DATA_DIR%\MQL4\Experts\" /Y
if %ERRORLEVEL% NEQ 0 (
    echo RSI_BB_EA.ex4のコピーに失敗しました。
    echo ファイルが存在するか確認してください。
) else (
    echo RSI_BB_EA.ex4をコピーしました。
)

copy "FX_EA_Project\MQL4\Experts\MartingaleEA.ex4" "%MT4_DATA_DIR%\MQL4\Experts\" /Y
if %ERRORLEVEL% NEQ 0 (
    echo MartingaleEA.ex4のコピーに失敗しました。
    echo ファイルが存在するか確認してください。
) else (
    echo MartingaleEA.ex4をコピーしました。
)

echo.
echo インストールが完了しました。
echo MT4を再起動して、ナビゲーターウィンドウのExpert Advisorsセクションを確認してください。
pause
