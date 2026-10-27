@echo off
echo ==============================================
echo   Starting SignBridge FastAPI Backend Server
echo ==============================================
cd /d "%~dp0backend"
python -m uvicorn app.main:app --host 0.0.0.0 --port 5000 --reload
pause
