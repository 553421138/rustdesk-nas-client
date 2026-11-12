@echo off
setlocal
chcp 65001 >nul
echo Close automatic updates for RemoteConnect Full and Customer.
echo Run this file locally as administrator. The apps will restart.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Windows-Maintenance.ps1" -Action DisableUpdates
set "RESULT=%ERRORLEVEL%"
echo.
if not "%RESULT%"=="0" echo Failed. Read the error above; settings may be partially applied.
pause
exit /b %RESULT%
