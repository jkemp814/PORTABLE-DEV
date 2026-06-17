@echo off
setlocal

set ROOT_DIR=%~dp0
set VSCODE_DIR=%ROOT_DIR%VSCodePortable-Windows
set VSCODE_DATA=%VSCODE_DIR%\data
set PROJECTS_DIR=%ROOT_DIR%Projects
set VSCODE_ZIP=VSCode-win32-x64-zip.zip
set DOWNLOAD_URL=https://update.code.visualstudio.com/latest/win32-x64-zip/stable

if not exist "%VSCODE_DIR%" mkdir "%VSCODE_DIR%"
if not exist "%PROJECTS_DIR%" mkdir "%PROJECTS_DIR%"

REM Force use of MSI-installed PowerShell 7
set PWSH=C:\Program Files\PowerShell\7\pwsh.exe

echo Downloading VS Code Portable...
"%PWSH%" -NoLogo -NoProfile -Command "Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%VSCODE_ZIP%'"

echo Extracting VS Code...
"%PWSH%" -NoLogo -NoProfile -Command "Expand-Archive -Path '%VSCODE_ZIP%' -DestinationPath '%VSCODE_DIR%' -Force"

if not exist "%VSCODE_DATA%" mkdir "%VSCODE_DATA%"

REM Copy seed User configs (settings, keybindings, extensions list)
set SEED_USER_DIR=%ROOT_DIR%Toolchest\VSCode\User
set TARGET_USER_DIR=%VSCODE_DIR%\data\user-data\User
if exist "%SEED_USER_DIR%" (
	if not exist "%TARGET_USER_DIR%" mkdir "%TARGET_USER_DIR%"
	copy "%SEED_USER_DIR%\*.json" "%TARGET_USER_DIR%\" >nul 2>nul
	copy "%SEED_USER_DIR%\*.txt" "%TARGET_USER_DIR%\" >nul 2>nul
	echo User configs seeded from Toolchest/VSCode/User
)

del "%VSCODE_ZIP%"

echo VS Code Portable setup complete!
echo To launch, run: %VSCODE_DIR%\Code.exe
pause
