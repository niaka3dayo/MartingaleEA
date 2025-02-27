@echo off
rem ===== EURUSD_Trend_EA コンパイルバッチファイル =====
rem FX自動売買EAをコンパイルするバッチファイル

echo EURUSD_Trend_EA コンパイルツール
echo ======================================

rem MetaEditorの一般的なパスを確認
set FOUND_METAEDITOR=0
set METAEDITOR_PATHS=^
"C:\Program Files\MetaTrader 4\metaeditor.exe" ^
"C:\Program Files (x86)\MetaTrader 4\metaeditor.exe" ^
"C:\Program Files\MetaTrader 4 Terminal\metaeditor.exe" ^
"C:\Program Files (x86)\MetaTrader 4 Terminal\metaeditor.exe"

for %%p in (%METAEDITOR_PATHS%) do (
    if exist %%p (
        set METAEDITOR_PATH=%%p
        set FOUND_METAEDITOR=1
        echo MetaEditorが見つかりました: %%p
        goto METAEDITOR_FOUND
    )
)

:METAEDITOR_NOT_FOUND
if %FOUND_METAEDITOR% EQU 0 (
    echo MetaEditorが見つかりませんでした。
    echo 以下のパスを確認しました:
    for %%p in (%METAEDITOR_PATHS%) do echo - %%p

    echo.
    echo MetaEditorの正確なパスを入力してください:
    set /p METAEDITOR_PATH=

    if exist "%METAEDITOR_PATH%" (
        echo MetaEditorが見つかりました: %METAEDITOR_PATH%
    ) else (
        echo 指定されたパスにMetaEditorが見つかりません: %METAEDITOR_PATH%
        echo このバッチファイルを編集して、正しいパスを設定してください。
        pause
        exit /b 1
    )
)

:METAEDITOR_FOUND
echo.
echo FX自動売買EAをコンパイルします...
echo.

rem srcディレクトリのEAファイルをコンパイル
set SRC_DIR=%~dp0src
set SUCCESS=1

for %%f in ("%SRC_DIR%\*.mq4") do (
    echo コンパイル中: %%~nxf
    "%METAEDITOR_PATH%" /compile:"%%f" /log
    if errorlevel 1 (
        echo コンパイルに失敗しました: %%~nxf
        set SUCCESS=0
    ) else (
        echo コンパイル成功: %%~nxf
    )
    echo.
)

rem 実行結果を確認
if %SUCCESS% EQU 1 (
    echo すべてのEAのコンパイルが完了しました。
) else (
    echo 一部のEAのコンパイルに失敗しました。
)

echo.
echo コンパイルされたEX4ファイルはsrcディレクトリに生成されています。
echo MT4にインストールするには install_to_mt4.bat を実行してください。
echo.

pause
