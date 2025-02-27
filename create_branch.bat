@echo off
echo FX自動売買EAプロジェクトの開発ブランチを作成します...

REM ブランチ名の入力
set /p BRANCH_NAME="作成するブランチ名を入力してください（例: feature/add-new-ea）: "

REM Gitリポジトリが初期化されているか確認
if not exist ".git" (
    echo Gitリポジトリが初期化されていません。初期化します...
    git init
    git add .
    git commit -m "初期コミット：FX自動売買EAプロジェクトの基本構造"
)

REM 新しいブランチを作成して切り替え
git checkout -b %BRANCH_NAME%

echo.
echo ブランチ '%BRANCH_NAME%' を作成し、切り替えました。
echo 開発作業を行った後、以下のコマンドでコミットしてください:
echo git add .
echo git commit -m "変更内容の説明"
echo.
echo 注意: このプロジェクトではリモートリポジトリを使用しません。
echo ローカルでの開発のみを行います。
pause
