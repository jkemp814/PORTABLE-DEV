@echo off
REM VS Code Portable Setup Script for Windows


REM Set variables
set ROOT_DIR=%~dp0
set VSCODE_DIR=%ROOT_DIR%VSCodePortable-Windows
set VSCODE_DATA=%VSCODE_DIR%\data
set PROJECTS_DIR=%ROOT_DIR%Projects
set VSCODE_ZIP=VSCode-win32-x64-zip.zip
set DOWNLOAD_URL=https://update.code.visualstudio.com/latest/win32-x64-zip/stable


REM Create VSCodePortable directory if it doesn't exist
if not exist "%VSCODE_DIR%" mkdir "%VSCODE_DIR%"

REM Create Projects directory if it doesn't exist
if not exist "%PROJECTS_DIR%" mkdir "%PROJECTS_DIR%"

REM Download VS Code ZIP
echo Downloading VS Code Portable...
powershell -Command "Invoke-WebRequest -Uri %DOWNLOAD_URL% -OutFile %VSCODE_ZIP%"

REM Extract ZIP
echo Extracting VS Code...
powershell -Command "Expand-Archive -Path %VSCODE_ZIP% -DestinationPath %VSCODE_DIR% -Force"

REM Create data folder for portable mode
if not exist "%VSCODE_DATA%" mkdir "%VSCODE_DATA%"

REM Clean up ZIP file
del %VSCODE_ZIP%

echo VS Code Portable setup complete!
echo To launch, run: %VSCODE_DIR%\Code.exe

pause
