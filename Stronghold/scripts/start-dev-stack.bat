@echo off
set SCRIPT_DIR=%~dp0
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%start-dev-stack.ps1"
if errorlevel 1 (
  echo.
  echo start-dev-stack failed. Press any key to close...
  pause >nul
)
