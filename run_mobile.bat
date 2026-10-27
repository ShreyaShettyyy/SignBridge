@echo off
echo ==============================================
echo   Connecting Mobile Device to Backend (Port 5000)
echo ==============================================
"D:\Android\sdk\platform-tools\adb.exe" reverse tcp:5000 tcp:5000
echo.
echo ==============================================
echo   Launching SignBridge on Mobile Device
echo ==============================================
cd /d "%~dp0frontend"
"D:\flutter\bin\flutter.bat" run
pause
