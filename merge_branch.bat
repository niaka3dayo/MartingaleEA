@echo off
echo FX自動売買EAプロジェクトのブランチマージを実行します...

REM 現在のブランチ名を取得
for /f "tokens=*" %%a in ('git rev-parse --abbrev-ref HEAD') do set CURRENT_BRANCH=%%a

REM マージ先のブランチ名を入力
set /p TARGET_BRANCH="マージ先のブランチ名を入力してください（通常はmain）: "

REM 変更内容の説明を入力
set /p COMMIT_MESSAGE="コミットメッセージを入力してください: "

REM 変更をコミット
git add .
git commit -m "%COMMIT_MESSAGE%"

REM マージ先ブランチに切り替え
echo %TARGET_BRANCH%ブランチに切り替えます...
git checkout %TARGET_BRANCH%

REM 開発ブランチをマージ
echo %CURRENT_BRANCH%ブランチをマージします...
git merge --no-ff %CURRENT_BRANCH% -m "マージ: %CURRENT_BRANCH% を %TARGET_BRANCH% にマージ"

echo.
echo マージが完了しました。
echo 現在のブランチ: %TARGET_BRANCH%
echo.
echo 注意: このプロジェクトではリモートリポジトリを使用しません。
echo ローカルでの開発のみを行います。
pause
