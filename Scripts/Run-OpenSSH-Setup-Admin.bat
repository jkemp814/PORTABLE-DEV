@echo off
setlocal
set SCRIPT_PATH=H:\PORTABLE-DEV\Scripts\enable-openssh-server.ps1

if not exist "%SCRIPT_PATH%" (
  echo Script not found: %SCRIPT_PATH%
  pause
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process PowerShell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%SCRIPT_PATH%""'"
if errorlevel 1 (
  echo Could not start Administrator PowerShell.
  pause
  exit /b 1
)

echo Administrator window launched. Approve UAC if prompted.
