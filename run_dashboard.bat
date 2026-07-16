@echo off
title SignBridge Offline Dashboard Launcher
echo ===================================================
echo   SignBridge Offline Dashboard Launcher
echo ===================================================
echo.
echo Starting local offline dashboard server...
cd /d "%~dp0dashboard"

:: Verify node_modules exists
if not exist "node_modules\" (
    echo ERROR: node_modules directory not found!
    echo Please make sure this script is located in the root project folder.
    pause
    exit /b
)

:: Start Vite dev server in the background
start "" /b cmd.exe /c "npm.cmd run dev"

echo.
echo Waiting 3 seconds for server to initialize...
timeout /t 3 /nobreak >nul

echo.
echo Launching web dashboard in your default browser...
start http://localhost:5173/

echo.
echo ===================================================
echo   SignBridge is live!
echo   You can minimize this window.
echo   To stop the server, simply close this window.
echo ===================================================
echo.
pause
