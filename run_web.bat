@echo off
echo ==============================================
echo   Launching SignBridge on Chrome (Web)
echo ==============================================
cd /d "%~dp0frontend"
"D:\flutter\bin\flutter.bat" run -d chrome
pause
