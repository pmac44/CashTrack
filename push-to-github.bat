@echo off
setlocal

:: ═════════════════════════════════════════════════════════════════════════════
:: SAFETY NOTE:
:: This script runs git ONLY inside the github-deploy folder.
:: It CANNOT see or push CashTrack.json, transactions, CSVs, or anything
:: outside this folder. Do not "fix" this by changing the cd line below.
:: ═════════════════════════════════════════════════════════════════════════════

:: Navigate into the github-deploy folder (where this .bat lives)
cd /d "%~dp0"

:: Check if git is installed
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Git is not installed or not in your PATH.
    echo Download it from https://git-scm.com/downloads
    pause
    exit /b 1
)

:: Initialise repo if needed
if not exist ".git" (
    echo Initialising git repository inside github-deploy...
    git init
    git branch -M main
)

:: Set remote
git remote get-url origin >nul 2>nul
if %errorlevel% neq 0 (
    git remote add origin "https://github.com/pmac44/CashTrack.git"
) else (
    git remote set-url origin "https://github.com/pmac44/CashTrack.git"
)

:: Stage all changes (scoped to this folder only — see safety note above)
git add -A

:: Check if there's anything to commit
git diff --cached --quiet
if %errorlevel% equ 0 (
    echo Nothing new to push — everything is up to date.
    pause
    exit /b 0
)

:: Commit with a timestamp
set TIMESTAMP=%date% %time:~0,8%
git commit -m "Update CashTrack — %TIMESTAMP%"

:: Push
echo.
echo Pushing to GitHub...
git push -u origin main
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Push failed. You may need to sign in to GitHub first.
    echo Try running: git push -u origin main
    pause
    exit /b 1
)

echo.
echo Done! Changes pushed to GitHub.
pause
