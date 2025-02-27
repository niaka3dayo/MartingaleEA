@echo off
echo FX自動売買EAプロジェクトを初期化します...

REM Gitリポジトリが初期化されているか確認
if not exist ".git" (
    echo Gitリポジトリを初期化します...
    git init
)

REM .gitignoreファイルが存在するか確認
if not exist ".gitignore" (
    echo .gitignoreファイルを作成します...
    (
        echo # MT4コンパイル済みファイル
        echo *.ex4
        echo # MT4バックアップファイル
        echo *.mq4.bak
        echo # FX_EA_Projectフォルダ（セットアップスクリプトで生成される）
        echo /FX_EA_Project/
        echo # Windows固有のファイル
        echo Thumbs.db
        echo ehthumbs.db
        echo Desktop.ini
        echo $RECYCLE.BIN/
        echo # Visual Studio Code設定
        echo .vscode/
        echo # その他の一時ファイル
        echo *.log
        echo *.tmp
    ) > .gitignore
)

REM プロジェクトディレクトリの作成
echo プロジェクトディレクトリを作成します...
call setup_project.bat

REM 初期コミット
echo 初期コミットを作成します...
git add .
git commit -m "初期コミット：FX自動売買EAプロジェクトの基本構造"

echo.
echo プロジェクトの初期化が完了しました。
echo 次のステップ:
echo 1. 開発用のブランチを作成:
echo    create_branch.bat
echo.
echo 注意: このプロジェクトではリモートリポジトリを使用しません。
echo ローカルでの開発のみを行います。
pause
